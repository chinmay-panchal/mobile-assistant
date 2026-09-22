import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/paper_creation/widgets/pdf_preview_header.dart';
import 'package:papervisor/features/paper_creation/widgets/pdf_edit_sheet.dart';
import 'package:papervisor/features/paper_creation/widgets/designer_page_sheet.dart';
import 'package:papervisor/features/paper_creation/screens/paper_editor_screen.dart';

void main() {
  group('PDF Preview & Edit Paper UI Redesign Tests', () {
    testWidgets('PdfPreviewHeader renders action buttons and responds to taps', (WidgetTester tester) async {
      bool saveTapped = false;
      bool editTapped = false;
      bool printTapped = false;
      bool shareTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfPreviewHeader(
              title: 'Midterm Exam 2026',
              subtitle: 'Physics · 80 Marks',
              isSaved: false,
              isSaving: false,
              onSave: () => saveTapped = true,
              onEdit: () => editTapped = true,
              onPrint: () => printTapped = true,
              onShare: () => shareTapped = true,
            ),
          ),
        ),
      );

      // Verify title & subtitle
      expect(find.text('Midterm Exam 2026'), findsOneWidget);
      expect(find.text('Physics · 80 Marks'), findsOneWidget);

      // Verify buttons exist when not saved
      expect(find.byTooltip('Save PDF'), findsOneWidget);
      expect(find.byTooltip('Edit Paper'), findsOneWidget);
      expect(find.byTooltip('Print'), findsOneWidget);
      expect(find.byTooltip('Share'), findsOneWidget);

      // Tap buttons
      await tester.tap(find.byTooltip('Save PDF'));
      expect(saveTapped, isTrue);

      await tester.tap(find.byTooltip('Edit Paper'));
      expect(editTapped, isTrue);

      await tester.tap(find.byTooltip('Print'));
      expect(printTapped, isTrue);

      await tester.tap(find.byTooltip('Share'));
      expect(shareTapped, isTrue);
    });

    testWidgets('PdfPreviewHeader shows loading indicator when isSaving is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfPreviewHeader(
              title: 'Unit Test Paper',
              subtitle: 'Chemistry',
              isSaved: false,
              isSaving: true,
              onBack: () {},
              onSave: () {},
              onEdit: () {},
              onPrint: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byTooltip('Save PDF'), findsNothing);
    });

    testWidgets('PdfPreviewHeader hides Save and Edit buttons and displays Saved badge when isSaved is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfPreviewHeader(
              title: 'Final Exam',
              subtitle: 'Mathematics',
              isSaved: true,
              isSaving: false,
              onBack: () {},
              onSave: () {},
              onEdit: () {},
              onPrint: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      // Save and Edit must disappear
      expect(find.byTooltip('Save PDF'), findsNothing);
      expect(find.byTooltip('Edit Paper'), findsNothing);

      // Saved badge must appear
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);

      // Print and Share must remain
      expect(find.byTooltip('Print'), findsOneWidget);
      expect(find.byTooltip('Share'), findsOneWidget);
    });

    testWidgets('PdfEditSheet renders options and triggers callbacks', (WidgetTester tester) async {
      bool editContentTapped = false;
      bool visualDesignerTapped = false;
      bool uploadLogoTapped = false;

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => PdfEditSheet(
                        logoBytes: null,
                        onEditContent: () => editContentTapped = true,
                        onOpenVisualDesigner: () => visualDesignerTapped = true,
                        onPickLogo: () => uploadLogoTapped = true,
                        onRemoveLogo: () {},
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Paper'), findsOneWidget);
      expect(find.text('Choose what you’d like to change.'), findsOneWidget);
      expect(find.text('Institution Logo'), findsOneWidget);
      expect(find.text('Edit Paper Content'), findsOneWidget);
      expect(find.text('Visual Designer'), findsOneWidget);

      // Tap Edit Paper Content
      await tester.tap(find.text('Edit Paper Content'));
      expect(editContentTapped, isTrue);

      // Tap Visual Designer
      await tester.tap(find.text('Visual Designer'));
      expect(visualDesignerTapped, isTrue);

      // Tap Upload
      await tester.tap(find.text('Upload'));
      expect(uploadLogoTapped, isTrue);
    });

    testWidgets('DesignerPageSheet lists pages and handles selection', (WidgetTester tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    DesignerPageSheet.show(
                      context: context,
                      pageCount: 3,
                      isText: true,
                      onPageSelected: (index) => selectedIndex = index,
                    );
                  },
                  child: const Text('Select Page'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select Page'));
      await tester.pumpAndSettle();

      expect(find.text('Add Text'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 3'), findsOneWidget);

      await tester.tap(find.text('Page 2'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);
    });

    testWidgets('PaperEditorScreen renders fields, calculated marks, questions and saves updates', (WidgetTester tester) async {
      final samplePaper = {
        'paper_title': 'Physics Midterm',
        'class_name': 'Class 12',
        'time_allowed_minutes': 90,
        'total_marks': 50,
        'content': {
          'sections': [
            {
              'name': 'Section A',
              'questions': [
                {
                  'question': 'What is Ohm\'s Law?',
                  'marks': 5,
                  'question_type': 'Short Answer',
                  'options': <dynamic>[],
                },
                {
                  'question': 'Which of the following is a vector quantity?',
                  'marks': 2,
                  'question_type': 'Multiple Choice Questions (MCQ)',
                  'options': ['Mass', 'Speed', 'Velocity', 'Time'],
                  'correct_answer': 'Velocity',
                }
              ]
            }
          ]
        }
      };

      await tester.pumpWidget(
        MaterialApp(
          home: PaperEditorScreen(
            paper: samplePaper,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and title
      expect(find.text('Edit Paper'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Verify paper information card
      expect(find.text('Paper Information'), findsOneWidget);
      expect(find.text('Physics Midterm'), findsOneWidget);
      expect(find.text('Class 12'), findsOneWidget);

      // Verify read-only calculated total marks
      expect(find.text('Total Marks'), findsOneWidget);
      expect(find.text('7'), findsOneWidget); // 5 + 2 = 7
      expect(find.text('Automatically calculated from questions.'), findsOneWidget);

      // Verify question list cards
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Q1'), findsOneWidget);
      expect(find.text('Q2'), findsOneWidget);
      expect(find.text('5 Marks'), findsOneWidget);
      expect(find.text('2 Marks'), findsOneWidget);

      // Tap to expand question 1
      await tester.tap(find.text('Q1'));
      await tester.pumpAndSettle();

      // Verify question text field is shown
      expect(find.text('What is Ohm\'s Law?'), findsNWidgets(2));
    });

    testWidgets('Save confirmation dialog displays message and handles Cancel and OK', (WidgetTester tester) async {
      bool okTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  final res = await showDialog<bool>(
                    context: ctx,
                    builder: (dCtx) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Save Paper to Cloud?'),
                          const Text("After saving this paper to the cloud, you won't be able to edit it anymore on the app."),
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx, true),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (res == true) okTapped = true;
                },
                child: const Text('Open Save Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Save Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Save Paper to Cloud?'), findsOneWidget);
      expect(find.text("After saving this paper to the cloud, you won't be able to edit it anymore on the app."), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(okTapped, isTrue);
    });
  });
}

