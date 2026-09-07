import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Thrown when a downloaded file is not a valid PDF.
class PdfValidationException implements Exception {
  final String message;
  const PdfValidationException(this.message);

  @override
  String toString() => 'PdfValidationException: $message';
}

/// Downloads a file from [url], validates it is a real PDF, and saves it
/// to the application documents directory. If [url] is an HTML landing page,
/// it attempts to parse and extract direct PDF download links from the page.
class PdfDownloadService {
  final Dio _dio;

  PdfDownloadService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 20),
        ),
      ) {
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  /// Downloads the file at [url] and returns the local file path on success.
  Future<String> download(
    String url, {
    int maxHtmlDepth = 2,
    String? targetYear,
    String? prompt,
    Future<Map<String, dynamic>?> Function(Uint8List, String)? verifyContent,
  }) async {
    // Universal low floor to save API calls on obvious stubs.
    const int absoluteMinPages = 3;

    debugPrint(
      '[PdfDownloadService] Downloading: $url (Target year: $targetYear | Prompt: "${prompt ?? ''}")',
    );

    Response<Uint8List> response;
    try {
      response = await _dio.get<Uint8List>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } catch (e) {
      debugPrint('[PdfDownloadService] Dio error for $url: $e');
      throw PdfValidationException('Network error downloading $url: $e');
    }

    if (response.statusCode == null || response.statusCode! >= 400) {
      debugPrint('[PdfDownloadService] HTTP ${response.statusCode} — skipping');
      throw PdfValidationException(
        'Server returned HTTP ${response.statusCode} for $url',
      );
    }

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw PdfValidationException('Empty response body from $url');
    }

    final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
    final hasPdfContentType = contentType.contains('application/pdf');

    // Magic bytes: %PDF- → [0x25, 0x50, 0x44, 0x46, 0x2D]
    final hasPdfMagicBytes =
        bytes.length >= 5 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46 &&
        bytes[4] == 0x2D;

    debugPrint(
      '[PdfDownloadService] HTTP status: ${response.statusCode} | File size: ${bytes.length} bytes | Content-Type: $contentType | PDF Magic (%PDF-): $hasPdfMagicBytes',
    );

    if (hasPdfContentType || hasPdfMagicBytes) {
      // --- Validate minimum file size: real exam papers are never < 100KB ---
      const int minFileSizeBytes = 100 * 1024; // 100 KB
      if (bytes.length < minFileSizeBytes) {
        debugPrint(
          '[PdfDownloadService] REJECTED — file too small (${bytes.length} bytes < $minFileSizeBytes). Likely a stub or 1-page PDF.',
        );
        throw PdfValidationException(
          'PDF from $url is too small (${bytes.length} bytes). Expected a full exam paper (≥100KB).',
        );
      }

      // --- Validate minimum page count (universal low floor) ---
      final int pageCount = _extractPdfPageCount(bytes);
      debugPrint('[PdfDownloadService] Estimated PDF page count: $pageCount');
      if (pageCount > 0 && pageCount < absoluteMinPages) {
        debugPrint(
          '[PdfDownloadService] REJECTED — PDF from $url has only $pageCount pages. Too short to be a full exam paper.',
        );
        throw PdfValidationException(
          'PDF from $url has only $pageCount pages. Expected full paper (≥$absoluteMinPages pages).',
        );
      }

      // --- Gemini Verification Gate ---
      if (verifyContent != null && prompt != null && prompt.isNotEmpty) {
        debugPrint(
          '[PdfDownloadService] Passing PDF to Gemini for completeness verification...',
        );
        final verification = await verifyContent(bytes, prompt);
        if (verification != null) {
          final bool isComplete = verification['isComplete'] as bool? ?? false;
          final reason =
              verification['reason'] as String? ?? 'No reason provided';

          if (!isComplete) {
            debugPrint('[PdfDownloadService] REJECTED by Gemini: $reason');
            throw PdfValidationException('Gemini rejected PDF: $reason');
          }
          debugPrint('[PdfDownloadService] Gemini approved PDF: $reason');
        } else {
          // Outage / Fallback safety net
          debugPrint(
            '[PdfDownloadService] Gemini verification API failed. Falling back to strict page count heuristic (≥8).',
          );
          if (pageCount > 0 && pageCount < 8) {
            debugPrint(
              '[PdfDownloadService] REJECTED by fallback heuristic: $pageCount pages < 8',
            );
            throw PdfValidationException(
              'Verification API failed, and PDF only has $pageCount pages (requires ≥8 for fallback).',
            );
          }
        }
      }

      // --- Save valid PDF to disk ---
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      debugPrint(
        '[PdfDownloadService] SUCCESS: Saved valid PDF to ${file.path}',
      );
      return file.path;
    }

    // --- HTML Page Fallback: Extract PDF links inside HTML content ---
    if (maxHtmlDepth > 0 &&
        (contentType.contains('text/html') || contentType.isEmpty)) {
      debugPrint(
        '[PdfDownloadService] HTML page detected. Extracting PDF download links from HTML...',
      );
      final htmlContent = latin1.decode(bytes);
      final extractedPdfUrl = _extractBestPdfUrl(
        htmlContent,
        url,
        targetYear,
        prompt: prompt,
      );

      if (extractedPdfUrl != null && extractedPdfUrl != url) {
        debugPrint(
          '[PdfDownloadService] Extracted PDF link from HTML: $extractedPdfUrl',
        );
        return await download(
          extractedPdfUrl,
          maxHtmlDepth: maxHtmlDepth - 1,
          targetYear: targetYear,
          prompt: prompt,
          verifyContent: verifyContent,
        );
      }
    }

    debugPrint(
      '[PdfDownloadService] VALIDATION FAILED — not a PDF and no PDF link found',
    );
    throw PdfValidationException(
      'Response from $url is not a PDF (Content-Type: $contentType).',
    );
  }

  /// Extracts the total page count from raw PDF bytes.
  int _extractPdfPageCount(Uint8List bytes) {
    try {
      final latin1String = latin1.decode(bytes);

      // Method 1: Page tree /Count in PDF trailer/catalog dictionary
      final countMatch = RegExp(
        r'/Type\s*/Pages.*?/Count\s+(\d+)',
      ).firstMatch(latin1String);
      final catalogCount = countMatch != null
          ? int.tryParse(countMatch.group(1) ?? '0') ?? 0
          : 0;

      // Method 2: Count raw /Type /Page objects throughout the document
      final rawPageCount = RegExp(
        r'/Type\s*/Page\b',
      ).allMatches(latin1String).length;

      debugPrint(
        '[PdfDownloadService] Page count extraction -> Catalog /Count: $catalogCount | /Type /Page objects: $rawPageCount => Final estimated pages: ${catalogCount > 0 ? catalogCount : rawPageCount}',
      );

      if (catalogCount > 0) return catalogCount;
      if (rawPageCount > 0) return rawPageCount;
      return 0;
    } catch (e) {
      debugPrint('[PdfDownloadService] Error counting PDF pages: $e');
      return 0;
    }
  }

  /// Parses HTML text to extract the most relevant PDF download URL.
  String? _extractBestPdfUrl(
    String html,
    String baseUrl,
    String? targetYear, {
    String? prompt,
  }) {
    final Set<String> rawCandidates = {};

    // 1. Direct href ending in .pdf
    final pdfHrefRegex = RegExp(
      r'''href=["']([^"']+\.pdf(?:\?[^"']*)?)["']''',
      caseSensitive: false,
    );
    for (final m in pdfHrefRegex.allMatches(html)) {
      final href = m.group(1);
      if (href != null && href.isNotEmpty) rawCandidates.add(href);
    }

    // 2. Direct PDF endpoint links (e.g. /sitepdfs/..., /get-pdf/..., /download-pdf/...)
    final endpointRegex = RegExp(
      r'''href=["']([^"']*(?:sitepdfs|get-pdf|download-pdf|download_pdf|viewpdf)[^"']*)["']''',
      caseSensitive: false,
    );
    for (final m in endpointRegex.allMatches(html)) {
      final href = m.group(1);
      if (href != null && href.isNotEmpty) rawCandidates.add(href);
    }

    // 3. source="..." attributes (e.g. <div class="PDFFlip" source="..."> or <embed source="...">)
    final sourceRegex = RegExp(
      r'''source=["']([^"']*(?:\.pdf|sitepdfs)[^"']*)["']''',
      caseSensitive: false,
    );
    for (final m in sourceRegex.allMatches(html)) {
      final src = m.group(1);
      if (src != null && src.isNotEmpty) rawCandidates.add(src);
    }

    // 4. data-pdf or data-url attributes
    final dataPdfRegex = RegExp(
      r'''(?:data-pdf|data-url)=["']([^"']*(?:\.pdf|sitepdfs)[^"']*)["']''',
      caseSensitive: false,
    );
    for (final m in dataPdfRegex.allMatches(html)) {
      final dp = m.group(1);
      if (dp != null && dp.isNotEmpty) rawCandidates.add(dp);
    }

    // 5. JavaScript download function calls: downloadFile("...")
    final jsDownloadRegex = RegExp(
      r'''downloadFile\(["']([^"']+)["']\)''',
      caseSensitive: false,
    );
    for (final m in jsDownloadRegex.allMatches(html)) {
      final jsUrl = m.group(1);
      if (jsUrl != null && jsUrl.isNotEmpty) rawCandidates.add(jsUrl);
    }

    // 6. Intermediate paper links (e.g. <a ... class="gotopdfpage" href="..."> or <div class="download-pdf"><a href="...">)
    final intermediatePageRegex = RegExp(
      r'''<a[^>]+href=["']([^"']+)["'][^>]*class=["'][^"']*gotopdfpage''',
      caseSensitive: false,
    );
    for (final m in intermediatePageRegex.allMatches(html)) {
      final link = m.group(1);
      if (link != null && link.isNotEmpty) rawCandidates.add(link);
    }

    final intermediateDivRegex = RegExp(
      r'''class=["'][^"']*(?:download-pdf|download_pdf)[^"']*["'][^>]*>\s*<a[^>]+href=["']([^"']+)["']''',
      caseSensitive: false,
    );
    for (final m in intermediateDivRegex.allMatches(html)) {
      final link = m.group(1);
      if (link != null && link.isNotEmpty) rawCandidates.add(link);
    }

    final List<String> candidateUrls = [];
    for (final href in rawCandidates) {
      final unescaped = href.replaceAll('&amp;', '&');
      candidateUrls.add(unescaped);
    }

    if (candidateUrls.isEmpty) return null;

    final baseUri = Uri.parse(baseUrl);

    // Score candidates based on question paper indicators, target year, subject, and class
    String? bestUrl;
    int maxScore = -99999;

    final unwantedKw = [
      'syllabus',
      'brochure',
      'prospectus',
      'timetable',
      'datesheet',
      'admit',
      'result',
      'analysis',
      'zoology',
      'botany',
      'chapter',
      'register',
      'user/register',
      'login',
      'formula',
      'formulae',
      'cheat sheet',
      'cheatsheet',
      'shortcut',
      'tips and tricks',
      'revision notes',
      'ebook',
      'e-book',
      'toolkit',
      'preview',
      'sample',
      'specimen',
      'sqp',
    ];

    final promptLower = prompt?.toLowerCase() ?? '';
    final bool wantsMath =
        promptLower.contains('math') || promptLower.contains('mathematics');
    final bool wantsClass10 =
        promptLower.contains('10') ||
        promptLower.contains('class 10') ||
        promptLower.contains('10th');
    final bool wantsClass12 =
        promptLower.contains('12') ||
        promptLower.contains('class 12') ||
        promptLower.contains('12th');

    for (final rawHref in candidateUrls) {
      final hrefLower = rawHref.toLowerCase();

      // Skip unwanted PDF files or login redirect links
      if (unwantedKw.any((kw) => hrefLower.contains(kw))) continue;

      int score = 0;

      // Target year enforcement inside HTML extracted links
      if (targetYear != null) {
        if (hrefLower.contains(targetYear)) {
          score += 15000;
        } else {
          final candidateYears = RegExp(
            r'(?<!\d)(19\d{2}|20\d{2})(?!\d)',
          ).allMatches(hrefLower).map((m) => m.group(1)).toSet();
          if (candidateYears.isNotEmpty &&
              !candidateYears.contains(targetYear)) {
            score -= 15000; // Penalize link for wrong year!
          }
        }
      }

      // Subject matching
      if (wantsMath) {
        if (hrefLower.contains('math') || hrefLower.contains('mathematics')) {
          score += 20000;
        } else {
          // Penalize links that explicitly name another subject (like agriculture, hindi, physics, etc.)
          final otherSubjects = [
            'agriculture',
            'hindi',
            'english',
            'sanskrit',
            'physics',
            'chemistry',
            'biology',
            'history',
            'geography',
            'political',
            'economics',
            'sociology',
            'psychology',
            'accountancy',
            'business',
            'painting',
            'music',
            'home_science',
            'physical_education',
          ];
          if (otherSubjects.any((s) => hrefLower.contains(s))) {
            score -= 20000;
          }
        }
      }

      // Class matching
      if (wantsClass10) {
        if (RegExp(
          r'\b(x|class\s*10|10th|_10_|_x_|\/x\/|\/10\/)\b',
        ).hasMatch(hrefLower)) {
          score += 15000;
        }
        if (RegExp(
          r'\b(xii|class\s*12|12th|_12_|_xii_|\/xii\/|\/12\/)\b',
        ).hasMatch(hrefLower)) {
          score -= 20000;
        }
      } else if (wantsClass12) {
        if (RegExp(
          r'\b(xii|class\s*12|12th|_12_|_xii_|\/xii\/|\/12\/)\b',
        ).hasMatch(hrefLower)) {
          score += 15000;
        }
        if (RegExp(
          r'\b(x|class\s*10|10th|_10_|_x_|\/x\/|\/10\/)\b',
        ).hasMatch(hrefLower)) {
          score -= 20000;
        }
      }

      if (hrefLower.contains('sitepdfs') ||
          hrefLower.endsWith('.pdf') ||
          hrefLower.contains('.pdf?')) {
        score += 5000;
      }
      if (hrefLower.contains('question') ||
          hrefLower.contains('paper') ||
          hrefLower.contains('pyq')) {
        score += 2000;
      }
      if (hrefLower.contains('full') || hrefLower.contains('official')) {
        score += 1000;
      }

      if (score > maxScore) {
        maxScore = score;
        bestUrl = rawHref;
      }
    }

    if (bestUrl == null) {
      if (maxScore < 0 && targetYear != null) {
        return null; // Don't pick an explicitly wrong-year link
      }
      bestUrl = candidateUrls.first;
    }

    // Resolve relative URL to absolute URL
    try {
      final resolved = baseUri.resolve(bestUrl);
      return resolved.toString();
    } catch (_) {
      return bestUrl;
    }
  }
}
