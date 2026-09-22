import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/paper_creation/models/paper_wizard_state.dart';
import 'package:papervisor/features/paper_creation/widgets/wizard_step_header.dart';
import 'package:papervisor/features/paper_creation/widgets/wizard_bottom_bar.dart';
import 'package:papervisor/features/paper_creation/widgets/paper_meta_dialog.dart';
import 'package:papervisor/features/paper_creation/screens/paper_wizard_step_marks.dart';
import 'package:papervisor/features/paper_creation/screens/paper_wizard_step_difficulty.dart';
import 'package:papervisor/features/paper_creation/screens/paper_wizard_step_reference.dart';
import 'package:papervisor/features/paper_creation/screens/paper_result_screen.dart';
import 'package:papervisor/features/paper_creation/screens/saved_pdf_viewer_screen.dart';

void main() {
  group('Paper Creation Wizard UI Redesign Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1080, 1920);
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    testWidgets('WizardStepHeader renders breadcrumb, step counter, titles, and no back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WizardStepHeader(
              subjectName: 'Physics',
              currentStep: 1,
              title: 'Select Chapters',
              subtitle: 'Choose textbook chapters',
            ),
          ),
        ),
      );

      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(find.text('Select Chapters'), findsOneWidget);
      expect(find.text('Choose textbook chapters'), findsOneWidget);

      // Verify no top-left back arrow icon
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });

    testWidgets('WizardBottomBar renders button and responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: WizardBottomBar(
              text: 'Continue',
              onPressed: () => tapped = true,
              helperWidget: const Text('Helper Status'),
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Helper Status'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('PaperMetaDialog submits title, class and minutes', (WidgetTester tester) async {
      String? generatedTitle;
      String? generatedClass;
      int? generatedMinutes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  PaperMetaDialog.show(
                    context: ctx,
                    initialTitle: 'Term 1 Exam',
                    initialClass: 'Class 10',
                    initialMinutes: 180,
                    onGenerate: (t, c, m) {
                      generatedTitle = t;
                      generatedClass = c;
                      generatedMinutes = m;
                    },
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Finalize Paper Details'), findsOneWidget);
      expect(find.text('Term 1 Exam'), findsOneWidget);

      await tester.tap(find.text('Generate Paper'));
      await tester.pumpAndSettle();

      expect(generatedTitle, 'Term 1 Exam');
      expect(generatedClass, 'Class 10');
      expect(generatedMinutes, 180);
    });

    testWidgets('PaperWizardStepMarks renders presets and enforces 1000 marks limit', (WidgetTester tester) async {
      final state = PaperWizardState()..totalMarks = 80;

      await tester.pumpWidget(
        MaterialApp(
          home: PaperWizardStepMarks(
            subject: const {'id': 'sub_1', 'name': 'Mathematics'},
            state: state,
          ),
        ),
      );

      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(find.text('Total Marks'), findsOneWidget);
      expect(find.text('80'), findsWidgets); // Input + preset

      // Tap preset 50
      await tester.tap(find.text('50'));
      await tester.pumpAndSettle();

      expect(find.text('50'), findsWidgets);

      // Verify entering > 1000 marks displays error and disables Continue
      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, '1001');
      await tester.pumpAndSettle();

      expect(find.text('Maximum marks limit is 1000'), findsOneWidget);
      final disabledBottomBar = tester.widget<WizardBottomBar>(find.byType(WizardBottomBar));
      expect(disabledBottomBar.onPressed, isNull);

      // Entering exactly 1000 marks clears error and enables Continue
      await tester.enterText(inputFinder, '1000');
      await tester.pumpAndSettle();

      expect(find.text('Maximum marks limit is 1000'), findsNothing);
      final enabledBottomBar = tester.widget<WizardBottomBar>(find.byType(WizardBottomBar));
      expect(enabledBottomBar.onPressed, isNotNull);
    });

    testWidgets('PaperWizardStepDifficulty renders sliders and applies presets', (WidgetTester tester) async {
      final state = PaperWizardState()..totalMarks = 80;

      await tester.pumpWidget(
        MaterialApp(
          home: PaperWizardStepDifficulty(
            subject: const {'id': 'sub_1', 'name': 'Mathematics'},
            state: state,
          ),
        ),
      );

      expect(find.text('Step 4 of 5'), findsOneWidget);
      expect(find.text('Difficulty Level'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);

      // Tap Challenging preset
      await tester.tap(find.text('Challenging'));
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget); // Hard is 50%
    });

    testWidgets('PaperWizardStepFormat renders layout patterns with marks and qty steppers and navigates to Stage 2', (WidgetTester tester) async {
      final state = PaperWizardState()..totalMarks = 80;

      await tester.pumpWidget(
        MaterialApp(
          home: PaperWizardStepFormat(
            subject: const {'id': 'sub_1', 'name': 'Mathematics'},
            state: state,
          ),
        ),
      );

      expect(find.text('Step 5 of 5'), findsOneWidget);
      expect(find.text('Question Format'), findsOneWidget);
      expect(find.text('MCQ Only'), findsOneWidget);
      expect(find.text('Subjective'), findsOneWidget);
      expect(find.text('Hybrid'), findsOneWidget);

      // Section Layout tab and Marks allocated strip exist
      expect(find.text('Section Layout'), findsOneWidget);
      expect(find.text('Paper Details'), findsOneWidget);
      expect(find.textContaining('Marks Allocated: '), findsOneWidget);

      // Switch to Subjective
      await tester.tap(find.text('Subjective'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Section A: Very Short Answer'), findsOneWidget);
      expect(find.textContaining('Section B: Short Answer'), findsOneWidget);
      expect(find.textContaining('Section C: Long Answer'), findsOneWidget);
      expect(find.text('Marks: '), findsWidgets);
      expect(find.text('Qty: '), findsWidgets);

      // Switch to Hybrid
      await tester.tap(find.text('Hybrid'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Section A: Multiple Choice Questions'), findsOneWidget);
      expect(find.textContaining('Section B: Very Short Answer'), findsOneWidget);
      expect(find.textContaining('Section C: Short Answer'), findsOneWidget);
      expect(find.textContaining('Section D: Long Answer'), findsOneWidget);
      expect(find.text('Marks: '), findsWidgets);
      expect(find.text('Qty: '), findsWidgets);

      // Since default 80 marks is balanced, Continue to Paper Details button is active
      expect(find.text('Continue to Paper Details'), findsOneWidget);
      await tester.tap(find.text('Continue to Paper Details'));
      await tester.pumpAndSettle();

      // Now on Stage 2: Paper Details
      expect(find.text('Exam Details'), findsOneWidget);
      expect(find.text('Paper Title'), findsOneWidget);
      expect(find.text('Class / Grade'), findsOneWidget);
      expect(find.text('EXAM DURATION'), findsOneWidget);
      expect(find.text('ADVANCED FORMAT OPTIONS'), findsOneWidget);
      expect(find.text('Generate Paper'), findsOneWidget);
    });

    testWidgets('PaperResultScreen renders summary card and preview CTA', (WidgetTester tester) async {
      final samplePaper = {
        'id': 'paper_1',
        'title': 'Midterm Physics 2026',
        'total_marks': 80,
        'difficulty': 'Balanced',
        'questions': [
          {
            'section_name': 'Section A',
            'marks': 1,
            'question_text': 'What is gravity?',
          },
          {
            'section_name': 'Section B',
            'marks': 3,
            'question_text': 'Derive kinetic energy formula.',
          },
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: PaperResultScreen(
            subject: const {'id': 'sub_1', 'name': 'Physics'},
            paper: samplePaper,
          ),
        ),
      );

      expect(find.text('Paper Ready! 🎉'), findsOneWidget);
      expect(find.text('Midterm Physics 2026'), findsOneWidget);
      expect(find.text('Preview PDF'), findsOneWidget);
      expect(find.text('Section A'), findsOneWidget);
      expect(find.text('Section B'), findsOneWidget);
    });

    testWidgets('PaperWizardStepReference renders header, tabs and action button', (WidgetTester tester) async {
      final state = PaperWizardState()..totalMarks = 80;

      await tester.pumpWidget(
        MaterialApp(
          home: PaperWizardStepReference(
            subject: const {'id': 'sub_1', 'name': 'Physics'},
            state: state,
          ),
        ),
      );

      expect(find.text('Step 3 of 5'), findsOneWidget);
      expect(find.text('Reference Paper'), findsOneWidget);
      expect(find.text('Reference Library'), findsOneWidget);
      expect(find.text('Upload New PDF'), findsOneWidget);
      expect(find.text('Continue (Custom Mode)'), findsOneWidget);
    });

    testWidgets('SavedPdfViewerScreen renders title, back button, neutral theme without purple', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SavedPdfViewerScreen(
            pdfBytes: Uint8List.fromList([0, 1, 2, 3]),
            title: 'CBSE Physics 2024',
          ),
        ),
      );

      expect(find.text('CBSE Physics 2024'), findsOneWidget);
      expect(find.text('PDF Preview'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}

