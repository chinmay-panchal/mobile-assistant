import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'pdf_search_service.dart';

class ClarificationRequest {
  final bool isAmbiguous;
  final String? question;
  final List<String>? options;
  final int stepIndex;
  final int totalSteps;

  ClarificationRequest({
    required this.isAmbiguous,
    this.question,
    this.options,
    this.stepIndex = 1,
    this.totalSteps = 1,
  });

  factory ClarificationRequest.fromJson(Map<String, dynamic> json) {
    return ClarificationRequest(
      isAmbiguous: json['is_ambiguous'] as bool? ?? false,
      question: json['question'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      stepIndex: json['step_index'] as int? ?? 1,
      totalSteps: json['total_steps'] as int? ?? 1,
    );
  }
}

class LLMClarificationService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const List<String> _candidateModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  /// Trusted brand and official exam-board domains that provide genuine, free downloadable PDFs.
  static const List<String> _trustedDomains = [
    'cbse.gov.in',
    'cbseacademic.nic.in',
    'ncert.nic.in',
    'selfstudys.com',
    'mycbseguide.com',
    'aglasem.com',
    'mathongo.com',
    'allen.in',
    'allen.ac.in',
    'resonance.ac.in',
    'pw.live',
    'physicswallah.live',
    'fiitjee.com',
    'oswalpublishers.com',
    'oswaal360.com',
    'nta.ac.in',
    'jeeadv.ac.in',
    'jeemain.nta.nic.in',
    'upsc.gov.in',
    'ssc.nic.in',
    'iimcat.ac.in',
  ];

  /// Unwanted document types to strictly penalize/exclude.
  static const List<String> _unwantedKeywords = [
    'pre-board',
    'pre board',
    'preboard',
    'pre-boards',
    'preboards',
    'syllabus',
    'answer key',
    'answer-key',
    'answerkey',
    'solution key',
    'solutions key',
    'exam rules',
    'rules',
    'guidelines',
    'instructions',
    'handbook',
    'template',
    'template book',
    'sample book',
    'brochure',
    'prospectus',
    'admit card',
    'admit',
    'timetable',
    'time table',
    'datesheet',
    'date sheet',
    'preview',
    'seminar',
    'webinar',
    'workshop',
    'conference',
    'presentation',
    'disclosure',
    'contract',
    'tender',
    'notification',
    'notice',
    'public notice',
    'public_notice',
    'press release',
    'press_release',
    'press-release',
    'circular',
    'advisory',
    'corrigendum',
    'announcement',
    'schedule',
    'merit list',
    'result',
    'cutoff',
    'fee',
    'admission form',
    'journal',
    'student list',
    'student-list',
    'student_list',
    'student',
    'batch',
    'seat matrix',
    'seat-matrix',
    'seat_matrix',
    'seats',
    'allotment',
    'counselling',
    'admission list',
    'enrolment',
    'enrollment',
    'candidate list',
    'rank list',
    'handbook',
    'formula book',
    'formula sheet',
    'cheat sheet',
    'revision notes',
    'template',
    'sample paper',
    'sample-paper',
    'sample_paper',
    'sample-papers',
    'sample_papers',
    'sample question paper',
    'sample_question_paper',
    'sqp',
    'specimen paper',
    'specimen copy',
    'specimen',
    'model test paper',
    'model paper',
    'model_paper',
    'model-paper',
    'mock test',
    'mock paper',
    'mock_paper',
    'mock-paper',
  ];

  /// Words too generic to count as "the user asked for this" in relevance
  /// matching — every exam PDF says "question" and "paper".
  static const Set<String> _relevanceStopWords = {
    'question',
    'questions',
    'paper',
    'papers',
    'pdf',
    'the',
    'of',
    'for',
    'exam',
    'exams',
    'year',
    'full',
    'complete',
    'download',
    'free',
    'with',
    'and',
    'a',
    'university',
    'institute',
    'technology',
    'college',
    'board',
    'state',
    'national',
    'common',
    'entrance',
    'test',
    'admission',
    'department',
    'engineering',
    'medical',
    'management',
    'science',
    'arts',
    'commerce',
    'law',
    'ug',
    'pg',
  };

  /// Calls [generateContent] with fallback across supported Gemini models.
  Future<GenerateContentResponse?> _generateContentWithFallback(
    List<Content> contents, {
    GenerationConfig? config,
  }) async {
    if (_apiKey.isEmpty) return null;

    for (final modelName in _candidateModels) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: config,
        );
        final response = await model.generateContent(contents);
        if (response.text != null && response.text!.isNotEmpty) {
          debugPrint(
            '[LLMClarification] Gemini success with model: $modelName',
          );
          return response;
        }
      } catch (e) {
        debugPrint(
          '[LLMClarification] Model $modelName failed at generateContent: $e',
        );
      }
    }
    return null;
  }

  /// Simple intelligent questioner (like Claude UI).
  /// Asks ONLY high-level essential questions (exam type or year) without deep details.
  Future<ClarificationRequest?> checkAmbiguity(String prompt) async {
    final promptLower = prompt.toLowerCase().trim();
    final hasYear = RegExp(
      r'(?<!\d)(19\d{2}|20\d{2})(?!\d)',
    ).hasMatch(promptLower);

    // Deterministic Rule 0: "CAT" is a highly overloaded acronym — India's
    // MBA entrance exam, the COPD Assessment Test, computer-adaptive-testing
    // research papers, etc. Unlike other exam names, "cat" alone (even with
    // a year) isn't enough to know what the user means, so confirm
    // explicitly rather than guessing.
    final mentionsCatAcronym = RegExp(r'\bcat\b').hasMatch(promptLower);
    final hasCatContext =
        promptLower.contains('iim') ||
        promptLower.contains('mba') ||
        promptLower.contains('common admission') ||
        promptLower.contains('management admission');

    if (mentionsCatAcronym && !hasCatContext) {
      debugPrint(
        '[LLMClarification] Deterministic: "CAT" is ambiguous without exam context.',
      );
      return ClarificationRequest(
        isAmbiguous: true,
        question: 'Which "CAT" do you mean?',
        options: [
          'Common Admission Test (CAT) — IIM MBA entrance',
          'Something else',
        ],
      );
    }

    // Detect whether an exam, board, or class/grade level is present in the prompt
    final hasExamOrClass =
        promptLower.contains('cbse') ||
        promptLower.contains('icse') ||
        promptLower.contains('isc') ||
        promptLower.contains('state board') ||
        promptLower.contains('jee') ||
        promptLower.contains('neet') ||
        promptLower.contains('gate') ||
        promptLower.contains('cat') ||
        promptLower.contains('upsc') ||
        promptLower.contains('ssc') ||
        promptLower.contains('nda') ||
        promptLower.contains('cds') ||
        promptLower.contains('cuet') ||
        promptLower.contains('clat') ||
        promptLower.contains('gujcet') ||
        promptLower.contains('mhcet') ||
        promptLower.contains('kcet') ||
        promptLower.contains('wbjee') ||
        promptLower.contains('bitsat') ||
        RegExp(r'\b(class|grade|std|standard)\s*(\d{1,2}|x|xi|xii|ix)\b').hasMatch(promptLower) ||
        RegExp(r'\b(\d{1,2})(th|st|nd|rd)\b').hasMatch(promptLower) ||
        promptLower.contains('matric') ||
        promptLower.contains('intermediate');

    // Specific exam indicators that don't need exam category clarification
    final hasSpecificExam =
        promptLower.contains('jee main') ||
        RegExp(r'jee\s+adv').hasMatch(promptLower) ||
        promptLower.contains('neet') ||
        promptLower.contains('gate cs') ||
        promptLower.contains('gate me') ||
        promptLower.contains('gate ee') ||
        promptLower.contains('gate da') ||
        promptLower.contains('upsc gs') ||
        promptLower.contains('upsc csat') ||
        promptLower.contains('ssc cgl') ||
        (promptLower.contains('cbse') && (promptLower.contains('10') || promptLower.contains('12')));

    // Deterministic Rule 1: If prompt has BOTH specific exam AND year (e.g. "jee main 2025", "neet 2024"),
    // it is 100% UNAMBIGUOUS. Return false immediately without invoking LLM!
    if (hasYear && hasSpecificExam) {
      debugPrint(
        '[LLMClarification] Fast-path: Prompt has specific exam + year -> NOT ambiguous.',
      );
      return ClarificationRequest(isAmbiguous: false);
    }

    if (_apiKey.isEmpty) {
      if (!hasExamOrClass) {
        final subjectLabel = promptLower.replaceAll(RegExp(r'\d+'), '').trim();
        final cap = subjectLabel.isNotEmpty
            ? subjectLabel[0].toUpperCase() + subjectLabel.substring(1)
            : 'this subject';
        return ClarificationRequest(
          isAmbiguous: true,
          question: 'Which exam or class do you need for $cap?',
          options: [
            'CBSE Class 10',
            'CBSE Class 12',
            'ICSE Class 10',
            'JEE Main',
          ],
        );
      }
      return null;
    }

    try {
      final config = GenerationConfig(responseMimeType: 'application/json');
      const systemPrompt = '''
You are an intelligent assistant helping a student find past year exam question (PYQ) papers.
Analyze the user prompt (e.g. "maths 2026", "JEE", "GATE", "10th CBSE", "UPSC", "physics").

Determine if the prompt is AMBIGUOUS or MISSING ESSENTIAL HIGH-LEVEL DETAILS needed to pinpoint the paper.

A prompt is AMBIGUOUS if:
1. Missing Exam Board, Level, or Class: e.g. "maths", "maths 2026", "physics", "science 2024" — only a generic subject is mentioned without specifying which board, exam, or grade/class (CBSE Class 10, CBSE Class 12, ICSE Class 10, JEE Main, etc.).
   -> Ask: "Which exam or class do you need for [Subject]?" and provide common options (e.g. ["CBSE Class 10", "CBSE Class 12", "ICSE Class 10", "JEE Main"]).
2. Missing Exam Variant or Category: e.g. "JEE" (could be JEE Main or JEE Advanced), "CAT" (IIM MBA vs other).
3. Missing Exam Stream or Branch: e.g. "GATE" (could be Computer Science, Mechanical, Electrical, Civil).
4. Missing Year: e.g. "JEE Advanced Maths Paper", "CBSE Class 10 Science" (year is unspecified).

STRICT INSTRUCTIONS:
- If a user provides a subject without specifying the exam board or grade/class, you MUST set is_ambiguous = true.
- Keep the question SIMPLE and HIGH-LEVEL (e.g., "Which exam or class do you need for Maths?").
- DO NOT ask granular details like shift, session, slot, morning/evening, or set numbers.
- Whenever `is_ambiguous` is true, you MUST ALWAYS return 3 to 4 concise, relevant options in the JSON array!
- If the prompt is complete and specific (e.g., "JEE Main 2024", "NEET 2025", "GATE 2025 Computer Science", "CBSE 10 Maths 2024", "GUJCET 2026"), set `is_ambiguous` = false.

Return JSON:
{
  "is_ambiguous": boolean,
  "question": string | null,
  "options": [string] | null
}
''';

      final response = await _generateContentWithFallback([
        Content.text('$systemPrompt\n\nUser Prompt: "$prompt"'),
      ], config: config);

      final text = response?.text;
      if (text == null || text.isEmpty) return null;

      final data = jsonDecode(text) as Map<String, dynamic>;
      final result = ClarificationRequest.fromJson(data);

      // Post-check Rule 2: Only override if prompt ALREADY has an exam/class AND a year, and question is redundantly asking for year
      if (result.isAmbiguous) {
        final isSolelyAskingYear = (result.question?.toLowerCase().contains('which year') ?? false) ||
            (result.question?.toLowerCase().trim() == 'which year?');
        if (hasYear && hasExamOrClass && isSolelyAskingYear) {
          debugPrint(
            '[LLMClarification] Override: Prompt already contains year and exam ($prompt). Setting isAmbiguous = false.',
          );
          return ClarificationRequest(isAmbiguous: false);
        }
        if (hasSpecificExam &&
            (result.question?.toLowerCase().contains('which jee') ?? false)) {
          debugPrint(
            '[LLMClarification] Override: Prompt already contains specific exam variant ($prompt). Setting isAmbiguous = false.',
          );
          return ClarificationRequest(isAmbiguous: false);
        }
      }

      if (result.isAmbiguous &&
          (result.options == null || result.options!.isEmpty)) {
        List<String> fallbackOpts = ["Option 1", "Option 2", "Option 3"];
        String fallbackQ = "Which paper do you need?";

        if (!hasExamOrClass) {
          final subjectLabel = promptLower.replaceAll(RegExp(r'\d+'), '').trim();
          final cap = subjectLabel.isNotEmpty
              ? subjectLabel[0].toUpperCase() + subjectLabel.substring(1)
              : 'this subject';
          fallbackQ = "Which exam or class do you need for $cap?";
          fallbackOpts = [
            "CBSE Class 10",
            "CBSE Class 12",
            "ICSE Class 10",
            "JEE Main",
          ];
        } else if (promptLower.contains('gate')) {
          fallbackQ = "Which GATE branch do you need?";
          fallbackOpts = [
            "Computer Science (CS)",
            "Mechanical (ME)",
            "Electrical (EE)",
            "Data Science & AI (DA)",
          ];
        } else if (promptLower.contains('jee')) {
          fallbackQ = "Which JEE exam paper do you need?";
          fallbackOpts = ["JEE Main", "JEE Advanced"];
        } else if (promptLower.contains('upsc')) {
          fallbackQ = "Which UPSC paper do you need?";
          fallbackOpts = ["General Studies (GS)", "CSAT Paper 2"];
        }

        return ClarificationRequest(
          isAmbiguous: true,
          question: result.question ?? fallbackQ,
          options: fallbackOpts,
          stepIndex: result.stepIndex,
          totalSteps: result.totalSteps,
        );
      }

      debugPrint(
        '[LLMClarification] checkAmbiguity -> isAmbiguous: ${result.isAmbiguous}',
      );
      return result;
    } catch (e) {
      debugPrint('[LLMClarification] checkAmbiguity error: $e');
      return null;
    }
  }

  /// Verifies if a downloaded PDF is a complete exam paper based on the user's prompt.
  /// Uses Gemini to inspect the inline PDF bytes and ensure it's not a partial excerpt.
  Future<Map<String, dynamic>?> verifyPdfCompleteness(
    Uint8List pdfBytes,
    String prompt,
  ) async {
    if (_apiKey.isEmpty) return null;

    try {
      final config = GenerationConfig(responseMimeType: 'application/json');
      const systemPrompt = '''
You are an expert exam paper verifier.
The user wanted to download a question paper for: "\$prompt"
We have downloaded a PDF. You must inspect the PDF and determine if it is a full, complete question paper for the exact exam requested.
Criteria for rejection (isComplete = false):
1. It is only a syllabus, brochure, or informational pamphlet.
2. It is a partial excerpt (e.g., only "Part 1" or just "Physics" when the exam has multiple subjects).
3. If the paper states it contains a specific number of questions (e.g., 75 or 100), but the document visibly ends after 10 or 15 questions.
4. It is just an answer key with no questions.
5. Some documents are free previews that only show the first page or two of real content, with the remaining pages being promotional material telling the reader to download an app, subscribe, or pay to unlock the rest. If ANY page past the first contains app-download prompts, subscription upsells, watermarks-only, or 'unlock full solution' messaging instead of actual exam questions, mark isComplete: false and say why in the reason.
6. The document is clearly for a DIFFERENT year or a DIFFERENT subject than what the user explicitly requested in their prompt.
7. It is an official Sample Question Paper (SQP), specimen paper, model paper, or mock/practice paper released by the exam board BEFORE the actual exam to illustrate format and pattern — even if it looks complete, well-formatted, and comes from an official source. Look for markers like "Sample Question Paper," "SQP," "Specimen," or a stated academic year range like "2025-26" (spanning two years signals a pattern-setting document for the upcoming session, not a completed exam from a single past year). This must be rejected unless the user's prompt explicitly asked for a sample/practice paper.
8. It is a "Pre-Board" exam, school preliminary test, or school internal practice test (e.g. titled "Pre-Board Examination", "Pre-Board", "Preliminary Exam") conducted by an individual school rather than an official centralized board examination paper, unless the user explicitly requested a pre-board paper.

Criteria for acceptance (isComplete = true):
- It contains the complete set of questions expected for this exam.
- Minor missing pages at the very end (like a missing rough work page) are acceptable, but all questions must be present.
- The exam name, subject, and year (if specified) match the user's prompt.

Return a JSON object strictly in this format:
{
  "isComplete": boolean,
  "reason": "Brief 1-sentence explanation of why it is complete or incomplete."
}
''';

      final response = await _generateContentWithFallback([
        Content.multi([
          TextPart('$systemPrompt\n\nUser Prompt: "$prompt"'),
          DataPart('application/pdf', pdfBytes),
        ]),
      ], config: config);

      final text = response?.text;
      if (text == null || text.isEmpty) return null;

      final data = jsonDecode(text) as Map<String, dynamic>;
      debugPrint(
        '[LLMClarification] verifyPdfCompleteness -> isComplete: ${data['isComplete']}, reason: ${data['reason']}',
      );
      return data;
    } catch (e) {
      debugPrint('[LLMClarification] verifyPdfCompleteness error: $e');
      return null;
    }
  }

  /// Enhances simple user prompts by correcting exam name spelling/typos (e.g., 'jee adv' -> 'JEE Advanced')
  /// and appending "question paper" to optimize search results.
  Future<String> enhancePrompt(String prompt) async {
    if (_apiKey.isEmpty) {
      return '$prompt question paper';
    }

    try {
      final config = GenerationConfig(responseMimeType: 'text/plain');
      const systemPrompt = '''
You are an exam search query corrector.
The user wants to search for past year question papers (PYQs).
They may have made typos or used abbreviations (e.g., "jee adv" -> "JEE Advanced", "neet pg" -> "NEET PG").
Your job:
1. Correct the spelling of the exam name and capitalize properly.
2. Explicitly expand known regional university/board acronyms to their full official names when confidence is reasonable (e.g., "GTU" -> "Gujarat Technological University").
3. DO NOT expand globally or nationally recognized acronyms that are universally used over their full forms (e.g., MUST keep "GATE", "JEE", "NEET", "CAT", "UPSC" as acronyms).
4. Keep the subject, semester, and year details exactly as provided, unchanged. Only correct/expand the institution/exam name.
5. Output ONLY the corrected exam name and year/semester/subject. Do not add conversational text.
''';

      final response = await _generateContentWithFallback([
        Content.text('$systemPrompt\n\nUser Prompt: "$prompt"'),
      ], config: config);

      final text = response?.text?.trim();
      if (text != null && text.isNotEmpty) {
        debugPrint(
          '[LLMClarification] enhancePrompt corrected "$prompt" to "$text"',
        );
        final lower = text.toLowerCase();
        if (lower.contains('question paper') || lower.contains('paper')) {
          return text;
        }
        return '$text question paper';
      }
    } catch (e) {
      debugPrint('[LLMClarification] enhancePrompt error: $e');
    }

    final promptLower = prompt.toLowerCase();
    if (promptLower.contains('question paper') || promptLower.contains('paper')) {
      return prompt;
    }
    return '$prompt question paper';
  }

  /// Synthesizes a clean search query by combining the original prompt and the user's
  /// selected clarification option, discarding irrelevant/garbage text from the original prompt.
  Future<String> synthesizePrompt(
    String originalPrompt,
    String? clarificationQuestion,
    String selectedOption,
  ) async {
    if (_apiKey.isEmpty) {
      return '$originalPrompt $selectedOption'.trim();
    }

    try {
      final config = GenerationConfig(responseMimeType: 'text/plain');
      const systemPrompt = '''
You are a search query synthesizer.
The user originally typed an ambiguous search prompt for an exam paper.
We asked them a clarification question and they selected an option.
Your job is to combine the relevant parts of their original prompt with their selected option to form a clean, single search phrase.
- DROP completely irrelevant or garbage words from their original prompt (e.g., "dog", "asdf").
- KEEP relevant subject or modifier words from the original prompt (e.g., "physics", "2024").
- DO NOT add extra conversational text. ONLY output the final clean search phrase.
''';

      final promptText =
          '''
Original Prompt: "$originalPrompt"
Clarification Question: "${clarificationQuestion ?? 'Which option?'}"
Selected Option: "$selectedOption"
''';

      final response = await _generateContentWithFallback([
        Content.text('$systemPrompt\n\n$promptText'),
      ], config: config);

      final text = response?.text?.trim();
      if (text != null && text.isNotEmpty) {
        debugPrint(
          '[LLMClarification] Synthesized prompt: "$text" (from "$originalPrompt" + "$selectedOption")',
        );
        return text;
      }
    } catch (e) {
      debugPrint('[LLMClarification] synthesizePrompt error: $e');
    }

    // Fallback: Just append if LLM fails
    return '$originalPrompt $selectedOption'.trim();
  }

  /// Ranks search candidates cleanly using Target Year precision, Trusted Domains priority,
  /// prompt-relevance matching, and strict document filtering (excluding syllabus, answer
  /// key, rules, template books, etc.).
  Future<List<PdfSearchResult>> evaluateAndRankCandidates(
    String prompt,
    List<PdfSearchResult> candidates,
  ) async {
    if (candidates.isEmpty) return candidates;

    final promptLower = prompt.toLowerCase();
    final bool userWantsAnswerKey =
        promptLower.contains('answer key') || promptLower.contains('solution');
    final bool userAskedForPG =
        promptLower.contains('pg') ||
        promptLower.contains('postgraduate') ||
        promptLower.contains('mds') ||
        promptLower.contains('ss');

    // Extract target year from user prompt (e.g. 2025, 2024, 2023)
    final yearMatch = RegExp(
      r'(?<!\d)(19\d{2}|20\d{2})(?!\d)',
    ).firstMatch(promptLower);
    final String? targetYear = yearMatch?.group(1);
    if (targetYear != null) {
      debugPrint(
        '[LLMClarification] Target year specified in prompt: $targetYear',
      );
    }

    // Score candidates deterministically
    final scored = candidates.map((c) {
      int score = _scoreCandidate(
        c,
        userWantsAnswerKey,
        targetYear,
        userAskedForPG,
        promptLower,
      );
      return MapEntry(c, score);
    }).toList();

    // Filter out candidates with very negative scores (unwanted documents,
    // wrong year, or no relevance to what the user actually asked for)
    final listToRank = scored.where((e) => e.value > -1000).toList();

    if (listToRank.isEmpty) {
      debugPrint(
        '[LLMClarification] All candidates were rejected during scoring.',
      );
      return [];
    }

    listToRank.sort((a, b) => b.value.compareTo(a.value)); // Higher score first

    debugPrint(
      '[LLMClarification] Evaluating ${candidates.length} candidates for prompt: "$prompt"',
    );
    for (int i = 0; i < listToRank.length; i++) {
      final entry = listToRank[i];
      debugPrint(
        '[LLMClarification] Rank #${i + 1}: Score ${entry.value} | Title: ${entry.key.title} | URL: ${entry.key.url}',
      );
    }

    final sortedCandidates = listToRank.map((e) => e.key).toList();
    if (listToRank.isNotEmpty) {
      debugPrint(
        '[LLMClarification] Ranker finished. Top candidate score: ${listToRank.first.value} URL: ${listToRank.first.key.url}',
      );
    }

    return sortedCandidates;
  }

  int _scoreCandidate(
    PdfSearchResult c,
    bool userWantsAnswerKey,
    String? targetYear,
    bool userAskedForPG,
    String promptLower,
  ) {
    int score = 0;
    final urlLower = c.url.toLowerCase();
    final titleLower = c.title.toLowerCase();
    final combinedText = '$urlLower $titleLower';

    // 0. Relevance check: does this candidate actually mention what the user
    // asked for? Strips generic words ("question", "paper", "pdf", years,
    // etc.) and requires at least one of the remaining distinguishing terms
    // — the exam name itself — to appear. Without this, a structurally
    // perfect-looking PDF for a completely different exam (e.g. a clerical
    // recruitment paper) can outscore the real one just by coincidentally
    // containing "question paper" and a matching year in its upload path.
    final promptTerms = promptLower
        .split(RegExp(r'[\s\-_/,]+'))
        .map((w) => w.trim())
        .where(
          (w) =>
              w.length >= 3 &&
              !_relevanceStopWords.contains(w) &&
              !RegExp(r'^\d+$').hasMatch(w),
        )
        .toSet();

    final expandedTerms = <String>{...promptTerms};
    if (promptTerms.contains('math') ||
        promptTerms.contains('maths') ||
        promptTerms.contains('mathematics')) {
      expandedTerms.addAll(['math', 'maths', 'mathematics']);
    }

    if (expandedTerms.isNotEmpty) {
      final matchedTerms = expandedTerms
          .where((t) => combinedText.contains(t))
          .length;
      if (matchedTerms == 0) {
        return -20000; // No overlap at all with what was actually asked for.
      }
      score += matchedTerms * 4000;
    }

    // 1. NEET UG vs PG Distinction (-15,000 Penalty for PG/SS/MDS papers when user asked for UG NEET)
    if (!userAskedForPG) {
      final pgKeywords = [
        'neet_pg',
        'neet-pg',
        'neet pg',
        '_pg_',
        'neet_ss',
        'neet-ss',
        'neet_mds',
        'neet-mds',
      ];
      for (final kw in pgKeywords) {
        if (urlLower.contains(kw) || titleLower.contains(kw)) {
          return -15000;
        }
      }
    }

    // 1b. JEE Main vs JEE Advanced Distinction — same class of bug as NEET
    // UG/PG. jeeadv.ac.in is JEE Advanced's official domain; "advanced" in a
    // title/URL means it's the wrong exam if the user specifically asked for
    // Main.
    final bool userWantsAdvanced = RegExp(r'adv').hasMatch(promptLower);
    final bool userWantsMain =
        promptLower.contains('jee main') ||
        (promptLower.contains('jee') && !userWantsAdvanced);

    if (userWantsMain && !userWantsAdvanced) {
      if (urlLower.contains('jeeadv') ||
          titleLower.contains('advanced') ||
          urlLower.contains('advanced')) {
        return -15000;
      }
    }

    // 1c. Class / Grade level mismatch penalty (-25,000 Penalty)
    final bool userWantsClass10 = RegExp(r'\b(class\s*10|10th|grade\s*10|class\s*x)\b').hasMatch(promptLower) ||
        (promptLower.contains('10') && !promptLower.contains('12'));
    final bool userWantsClass12 = RegExp(r'\b(class\s*12|12th|grade\s*12|class\s*xii)\b').hasMatch(promptLower) ||
        (promptLower.contains('12') && !promptLower.contains('10'));

    if (userWantsClass10) {
      final hasClass12Indicator = RegExp(r'\b(class\s*12|12th|grade\s*12|class\s*xii|math-12|physics-12|chem-12|biology-12)\b').hasMatch(combinedText);
      final hasClass9Indicator = RegExp(r'\b(class\s*(?:9|ix)|9th|grade\s*(?:9|ix))\b').hasMatch(combinedText);
      final hasClass11Indicator = RegExp(r'\b(class\s*(?:11|xi)|11th|grade\s*(?:11|xi))\b').hasMatch(combinedText);
      if ((hasClass12Indicator || hasClass9Indicator || hasClass11Indicator) &&
          !RegExp(r'\b(class\s*10|10th|class\s*x)\b').hasMatch(combinedText)) {
        return -25000; // Strictly disqualify wrong class papers
      }
    } else if (userWantsClass12) {
      final hasClass10Indicator = RegExp(r'\b(class\s*10|10th|grade\s*10|class\s*x|math-10)\b').hasMatch(combinedText);
      final hasClass9Indicator = RegExp(r'\b(class\s*(?:9|ix)|9th|grade\s*(?:9|ix))\b').hasMatch(combinedText);
      final hasClass11Indicator = RegExp(r'\b(class\s*(?:11|xi)|11th|grade\s*(?:11|xi))\b').hasMatch(combinedText);
      if ((hasClass10Indicator || hasClass9Indicator || hasClass11Indicator) &&
          !RegExp(r'\b(class\s*12|12th|class\s*xii)\b').hasMatch(combinedText)) {
        return -25000;
      }
    }

    // 1d. Exam Board Mismatch Check (-25,000 Penalty)
    final bool userWantsCbse = promptLower.contains('cbse');
    if (userWantsCbse) {
      // If user specifically asked for CBSE, penalize teacher recruitment / state government job exams
      final nonCbseExamKeywords = [
        'pgt',
        'tgt',
        'prt',
        'tet',
        'ctet',
        'bpsc',
        'rpsc',
        'mpsc',
        'upsssc',
        'kvs recruitment',
        'nvs recruitment',
        'dsssb',
        'adda247',
      ];
      for (final kw in nonCbseExamKeywords) {
        if (titleLower.contains(kw) || urlLower.contains(kw)) {
          return -25000; // Completely different exam (e.g. UP PGT teacher exam instead of CBSE)
        }
      }
    }

    // 1e. Specific Exam / Board Cross-Pollution Filter (-25,000 Penalty)
    if (promptLower.contains('gujcet')) {
      final foreignBoards = ['upmsp', 'up-board', 'cbse', 'icse', 'bpsc', 'wbjee', 'mht cet', 'keam'];
      if (foreignBoards.any((b) => combinedText.contains(b)) && !combinedText.contains('gujcet')) {
        return -25000;
      }
    }
    if (promptLower.contains('upsc') || promptLower.contains('civil services')) {
      final foreignExams = ['gate', 'cbse', 'icse', 'jee', 'neet', 'cat', 'civil_engg', 'civil engg'];
      if (foreignExams.any((e) => combinedText.contains(e)) &&
          !combinedText.contains('civil services') &&
          !combinedText.contains('cse') &&
          !combinedText.contains('upsc')) {
        return -25000;
      }
    }

    // 2. Target Year Precision Matching (+10,000 Boost for matching year, -15,000 Penalty for wrong year)
    if (targetYear != null) {
      // Check if candidate explicitly states a DIFFERENT question paper year (e.g. "Question Paper 2022")
      final specificPaperYearMatch = RegExp(
        r'(?:question\s+paper|board\s+exam|solved\s+paper|paper)\s*[:\-]?\s*(19\d{2}|20\d{2})',
      ).firstMatch('$titleLower $urlLower');
      if (specificPaperYearMatch != null &&
          specificPaperYearMatch.group(1) != targetYear) {
        return -15000; // Explicitly a paper for a different year
      }

      final hasTargetYear =
          urlLower.contains(targetYear) || titleLower.contains(targetYear);
      final candidateYears = RegExp(
        r'(?<!\d)(19\d{2}|20\d{2})(?!\d)',
      ).allMatches('$urlLower $titleLower').map((m) => m.group(1)).toSet();

      if (hasTargetYear) {
        score += 10000; // Massive boost for matching the requested year
      } else if (candidateYears.isNotEmpty &&
          !candidateYears.contains(targetYear)) {
        return -15000; // Disqualify PDFs that explicitly belong to a DIFFERENT year
      }
    }

    // 3. Direct PDF URL Priority (+25,000 Boost)
    if (urlLower.endsWith('.pdf') ||
        urlLower.contains('.pdf?') ||
        urlLower.contains('/pdf/') ||
        urlLower.contains('sitepdfs')) {
      score += 25000;
    }

    // 4. Strict Exclusion Check for Unwanted Document Types
    for (final kw in _unwantedKeywords) {
      if (kw.contains('answer key') && userWantsAnswerKey) {
        continue; // Allow answer key if user explicitly asked for it
      }
      if ((kw.contains('pre-board') || kw.contains('preboard') || kw.contains('pre board')) &&
          (promptLower.contains('pre-board') || promptLower.contains('preboard') || promptLower.contains('pre board'))) {
        continue; // Allow pre-board only if user explicitly asked for it
      }

      final titleMatch = titleLower.contains(kw);
      final urlMatch = urlLower.contains(kw);
      if (!titleMatch && !urlMatch) continue;

      // Trusted official domains sometimes get scraped with a mislabeled title
      final isTrustedDomain = _trustedDomains.any((d) => urlLower.contains(d));
      if (isTrustedDomain && !urlMatch) {
        continue;
      }

      return -25000; // Immediate disqualification
    }

    // 4.5 Gated Content, E-Commerce, Spam & News Article Domains (-25,000 Disqualification)
    final blockedDomains = [
      'askfilo.com',
      'collegedunia.com',
      'zollege.in',
      'indiatoday.in',
      'timesofindia',
      'hindustantimes.com',
      'ndtv.com',
      'news18.com',
      'indianexpress.com',
      'livemint.com',
      'jagranjosh.com',
      'scribd.com',
      'shiksha.com',
      'notopedia.com',
      'careers360.com',
      'universitykart.com',
      'affairscloud.com',
      'flipkart.com',
      'amazon.',
      'm.media-amazon.com',
    ];
    for (final domain in blockedDomains) {
      if (urlLower.contains(domain)) {
        return -25000; // Disqualify 403-blocked, spam, or e-commerce sites
      }
    }

    // 5. Trusted Domain Priority (+20,000 Boost)
    for (final domain in _trustedDomains) {
      if (urlLower.contains(domain)) {
        score += 20000;
        break;
      }
    }

    // 6. Full paper / complete paper indicators (+20,000 Boost)
    final fullPaperKeywords = [
      'full paper',
      'full_paper',
      'complete paper',
      'complete_paper',
      'official paper',
      'official_paper',
      'full question paper',
      'complete question paper',
      '75 questions',
      '180 questions',
      '200 questions',
      '300 marks',
      '720 marks',
      'all subjects',
      'pcm',
      'pcb',
      'neet_ug',
      'neet-ug',
      'neet ug',
      'full test',
    ];

    for (final kw in fullPaperKeywords) {
      if (titleLower.contains(kw) || urlLower.contains(kw)) {
        score += 20000;
        break;
      }
    }

    // 7. Question Paper positive indicators (+15,000 Boost)
    final paperKeywords = [
      'question paper',
      'question_paper',
      'qp',
      'pyq',
      'previous year',
      'master_qp',
      'questionbank',
      'exam_paper',
      'paper 1',
      'paper 2',
      'paper-1',
      'paper-2',
      'shift 1',
      'shift 2',
      'shift-1',
      'shift-2',
      'slot-1',
      'slot-2',
    ];

    for (final kw in paperKeywords) {
      if (titleLower.contains(kw) || urlLower.contains(kw)) {
        score += 15000;
        break;
      }
    }

    // 8. Penalty for partial, memory-based, or single-subject excerpt papers (-8,000 Penalty)
    // Split into structural indicators (always bad) vs subject names (only
    // bad if the user didn't specifically ask for that subject).
    final structuralPartialKeywords = [
      'memory based',
      'memory_based',
      'memory-based',
      'recalled',
      'part 1',
      'part-1',
      'part 2',
      'part-2',
      'excerpt',
      'analysis',
      'subject wise',
      'chapter wise',
      'topic wise',
      'unit wise',
      'sample paper',
      'sample question paper',
      'sample_question_paper',
      'sqp',
      'specimen paper',
      'specimen copy',
      'mock',
      'organic-chemistry',
      'block-elements',
      'user/register',
    ];

    for (final kw in structuralPartialKeywords) {
      if (titleLower.contains(kw) || urlLower.contains(kw)) {
        score -= 8000;
      }
    }

    final subjectKeywords = {
      'zoology': 'zoology',
      'botany': 'botany',
      'biology': 'biology',
      'physics': 'physics',
      'chemistry': 'chemistry',
      'mathematics': 'mathematics',
      'maths': 'maths',
      'only physics': 'physics',
      'only chemistry': 'chemistry',
      'only maths': 'maths',
    };

    subjectKeywords.forEach((kw, subject) {
      final userAskedForThisSubject =
          promptLower.contains(subject) || promptLower.contains('math');

      if (!userAskedForThisSubject &&
          (titleLower.contains(kw) || urlLower.contains(kw))) {
        score -= 8000;
      }
    });

    return score;
  }
}
