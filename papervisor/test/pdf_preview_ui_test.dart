import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/paper_creation/widgets/pdf_preview_header.dart';
import 'package:papervisor/features/paper_creation/widgets/pdf_edit_sheet.dart';
import 'package:papervisor/features/paper_creation/widgets/designer_page_sheet.dart';
import 'package:papervisor/features/paper_creation/screens/paper_editor_screen.dart';
import 'package:papervisor/features/paper_creation/screens/pdf_preview_screen.dart';
import 'package:papervisor/features/paper_creation/widgets/preview_walkthrough_overlay.dart';
import 'package:papervisor/features/paper_creation/models/custom_element.dart';

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

    testWidgets('PdfPreviewHeader opens popup menu with Edit content and Add new image/text', (WidgetTester tester) async {
      bool editContentTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfPreviewHeader(
              title: 'Midterm Exam 2026',
              subtitle: 'Physics · 80 Marks',
              isSaved: false,
              isSaving: false,
              onEditContent: () => editContentTapped = true,
              onVisualDesigner: () {},
              onPrint: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      // Verify edit button exists
      expect(find.byTooltip('Edit Paper'), findsOneWidget);

      // Tap edit button to open popup box
      await tester.tap(find.byTooltip('Edit Paper'));
      await tester.pumpAndSettle();

      // Verify popup options exist
      expect(find.text('Edit content'), findsOneWidget);
      expect(find.text('Visual Designer'), findsOneWidget);

      // Tap Edit content
      await tester.tap(find.text('Edit content'));
      await tester.pumpAndSettle();
      expect(editContentTapped, isTrue);
    });

    testWidgets('PdfPreviewHeader popup menu triggers Visual Designer callback', (WidgetTester tester) async {
      bool visualDesignerTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfPreviewHeader(
              title: 'Midterm Exam 2026',
              subtitle: 'Physics · 80 Marks',
              isSaved: false,
              isSaving: false,
              onEditContent: () {},
              onVisualDesigner: () => visualDesignerTapped = true,
              onPrint: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Edit Paper'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visual Designer'));
      await tester.pumpAndSettle();
      expect(visualDesignerTapped, isTrue);
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

    testWidgets('PaperEditorScreen back navigation without edits does NOT show discard dialog', (WidgetTester tester) async {
      final samplePaper = {
        'id': 'p1',
        'title': 'Test Paper',
        'class_name': 'Class 10',
        'time_allowed_minutes': 60,
        'total_marks': 50,
        'questions': [
          {'question_text': 'What is gravity?', 'marks': 5}
        ]
      };

      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => PaperEditorScreen(paper: samplePaper)),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Paper'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Discard dialog should NOT be shown
      expect(find.text('Discard Changes?'), findsNothing);
      expect(popped, isTrue);
    });

    testWidgets('PaperEditorScreen with backend sections paper back navigation without edits does NOT show discard dialog', (WidgetTester tester) async {
      final backendPaper = {
        'id': 'p2',
        'title': 'Sectioned Paper',
        'content': {
          'sections': [
            {
              'name': 'Section A',
              'questions': [
                {
                  'question': 'What is gravity?',
                  'marks': 5,
                }
              ]
            }
          ]
        }
      };

      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => PaperEditorScreen(paper: backendPaper)),
                  );
                  popped = true;
                },
                child: const Text('Open Sectioned'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sectioned'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Paper'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Discard dialog should NOT be shown
      expect(find.text('Discard Changes?'), findsNothing);
      expect(popped, isTrue);
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

    testWidgets('PdfPreviewScreen back navigation without edits does NOT show discard dialog', (WidgetTester tester) async {
      final samplePaper = {
        'id': 'preview-p1',
        'title': 'Sample Preview Paper',
        'total_marks': 50,
        'questions': [
          {'question_text': 'What is inertia?', 'marks': 5}
        ]
      };
      final sampleSubject = {
        'id': 'subj-1',
        'name': 'Physics',
      };

      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewScreen(
                        subject: sampleSubject,
                        paper: samplePaper,
                        isReadOnly: false,
                      ),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open Preview'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Preview'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sample Preview Paper'), findsOneWidget);

      // Trigger back navigation
      await Navigator.maybePop(tester.element(find.byType(PdfPreviewScreen)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Discard dialog should NOT appear because nothing was edited
      expect(find.text('Discard Changes?'), findsNothing);
      expect(popped, isTrue);
    });

    testWidgets('PaperEditorScreen back navigation WITH edits DOES show discard dialog', (WidgetTester tester) async {
      final samplePaper = {
        'id': 'p3',
        'title': 'Editable Paper',
        'questions': [
          {'question_text': 'Original question', 'marks': 5}
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => PaperEditorScreen(paper: samplePaper)),
                  );
                },
                child: const Text('Open To Edit'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open To Edit'));
      await tester.pumpAndSettle();

      // Make an edit in the title field
      await tester.enterText(find.byType(TextField).first, 'Edited Title');
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Discard dialog SHOULD appear because user edited the title!
      expect(find.text('Discard Changes?'), findsOneWidget);
      expect(find.text('Are you sure you want to go back? Your edits will be discarded.'), findsOneWidget);
    });

    testWidgets('PdfPreviewHeader renders walkthrough button when onStartTour is provided', (WidgetTester tester) async {
      bool tourStarted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfPreviewHeader(
              title: 'Midterm Exam 2026',
              subtitle: 'Physics · 80 Marks',
              isSaved: false,
              isSaving: false,
              onPrint: () {},
              onShare: () {},
              onStartTour: () => tourStarted = true,
            ),
          ),
        ),
      );

      expect(find.byTooltip('Preview Walkthrough'), findsOneWidget);
      await tester.tap(find.byTooltip('Preview Walkthrough'));
      expect(tourStarted, isTrue);
    });

    testWidgets('PreviewWalkthroughOverlay displays steps, pointing finger, next, back, and skip', (WidgetTester tester) async {
      bool dismissed = false;
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      final steps = [
        WalkthroughStep(
          key: key1,
          title: 'Save to Cloud',
          description: 'Saves your paper permanently to this subject.',
          icon: Icons.cloud_upload_outlined,
          accentColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          badgeText: 'Step 1 of 2 • Essential',
        ),
        WalkthroughStep(
          key: key2,
          title: 'Print Exam Paper',
          description: 'Directly print formatted paper.',
          icon: Icons.print_outlined,
          accentColor: const Color(0xFF4F46E5),
          iconBgColor: const Color(0xFFEEF2FF),
          badgeText: 'Step 2 of 2 • Output',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 100,
                  child: Container(
                    key: key1,
                    width: 40,
                    height: 40,
                    color: Colors.blue,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 200,
                  child: Container(
                    key: key2,
                    width: 40,
                    height: 40,
                    color: Colors.indigo,
                  ),
                ),
                PreviewWalkthroughOverlay(
                  steps: steps,
                  onDismiss: () => dismissed = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Step 1 rendered
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Save to Cloud'), findsOneWidget);
      expect(find.text('Saves your paper permanently to this subject.'), findsOneWidget);
      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(find.text('👆'), findsOneWidget); // Bobbing pointing finger
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('👉'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap Next to advance to Step 2
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Print Exam Paper'), findsOneWidget);
      expect(find.text('STEP 2 OF 2'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('🎉'), findsOneWidget);

      // Tap Back to return to Step 1
      await tester.tap(find.text('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Save to Cloud'), findsOneWidget);

      // Tap Skip to dismiss
      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('PreviewWalkthroughOverlay renders floatingWidget and customContent on step 2', (WidgetTester tester) async {
      final key = GlobalKey();
      final step = WalkthroughStep(
        key: key,
        title: 'Edit & Visual Designer',
        description: 'Two editing modes:',
        floatingWidget: Container(
          key: const ValueKey('open_popup_box'),
          child: const Text('Floating 2 Options Box'),
        ),
        customContent: const Text('Custom breakdown: text vs images'),
        icon: Icons.edit_outlined,
        accentColor: const Color(0xFF0D9488),
        iconBgColor: const Color(0xFFF0FDFA),
        badgeText: 'Step 2 of 4',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 150,
                  child: Container(
                    key: key,
                    width: 38,
                    height: 38,
                    color: Colors.teal,
                  ),
                ),
                PreviewWalkthroughOverlay(
                  steps: [step],
                  onDismiss: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const ValueKey('open_popup_box')), findsOneWidget);
      expect(find.text('Floating 2 Options Box'), findsOneWidget);
      expect(find.text('Custom breakdown: text vs images'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('Walkthrough distinguishes Edit content and Visual Designer sequentially across two steps', (WidgetTester tester) async {
      final key = GlobalKey();
      final step2 = WalkthroughStep(
        key: key,
        title: 'Option 1: Edit Content',
        description: 'Modify question statements, section titles, and marks.',
        floatingWidget: Container(
          key: const ValueKey('edit_floating_box_0'),
          child: const Text('Edit Content (Active)'),
        ),
        icon: Icons.edit_note_rounded,
        accentColor: const Color(0xFF2563EB),
        iconBgColor: const Color(0xFFEFF6FF),
        badgeText: 'Step 2 of 5 • Text & Marks',
      );
      final step3 = WalkthroughStep(
        key: key,
        title: 'Option 2: Visual Designer',
        description: 'Open a freeform canvas to drag & drop institution logos.',
        floatingWidget: Container(
          key: const ValueKey('edit_floating_box_1'),
          child: const Text('Visual Designer (Active)'),
        ),
        icon: Icons.design_services_rounded,
        accentColor: const Color(0xFF0D9488),
        iconBgColor: const Color(0xFFF0FDFA),
        badgeText: 'Step 3 of 5 • Drag & Drop',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 150,
                  child: SizedBox(key: key, width: 38, height: 38),
                ),
                PreviewWalkthroughOverlay(
                  steps: [step2, step3],
                  onDismiss: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Step 2 shows Option 1
      expect(find.text('Option 1: Edit Content'), findsOneWidget);
      expect(find.byKey(const ValueKey('edit_floating_box_0')), findsOneWidget);
      expect(find.text('Option 2: Visual Designer'), findsNothing);

      // Tap Next to advance to Step 3
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Step 3 shows Option 2
      expect(find.text('Option 2: Visual Designer'), findsOneWidget);
      expect(find.byKey(const ValueKey('edit_floating_box_1')), findsOneWidget);
      expect(find.text('Option 1: Edit Content'), findsNothing);
    });

    testWidgets('Visual Designer walkthrough steps through Text, Images, and Undo & Redo Controls (3 steps)', (WidgetTester tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      final key3 = GlobalKey();

      final steps = [
        WalkthroughStep(
          key: key1,
          title: 'Add Custom Text',
          description: 'Drag & drop text',
          icon: Icons.title_rounded,
          badgeText: 'Step 1 of 3',
        ),
        WalkthroughStep(
          key: key2,
          title: 'Add Images & Logos',
          description: 'Drag & drop images',
          icon: Icons.image_outlined,
          badgeText: 'Step 2 of 3',
        ),
        WalkthroughStep(
          key: key3,
          title: 'Undo & Redo Controls',
          description: '• Left arrow ↩️ (Undo)\n• Right arrow ↪️ (Redo)',
          icon: Icons.history_rounded,
          badgeText: 'Step 3 of 3',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(top: 10, left: 10, child: SizedBox(key: key1, width: 30, height: 30)),
                Positioned(top: 10, left: 50, child: SizedBox(key: key2, width: 30, height: 30)),
                Positioned(top: 10, left: 90, child: SizedBox(key: key3, width: 60, height: 30)),
                PreviewWalkthroughOverlay(
                  steps: steps,
                  onDismiss: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add Custom Text'), findsOneWidget);
      expect(find.text('STEP 1 OF 3'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add Images & Logos'), findsOneWidget);
      expect(find.text('STEP 2 OF 3'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Undo & Redo Controls'), findsOneWidget);
      expect(find.text('STEP 3 OF 3'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    test('CustomElement movement alters preview signature to trigger full PDF re-baking', () {
      final el1 = CustomElement(
        id: 'logo-1',
        type: CustomElementType.text,
        relativeX: 0.1000,
        relativeY: 0.2000,
        text: 'Exam Note',
      );

      String computeSignature(List<CustomElement> list) {
        final buffer = StringBuffer();
        for (final el in list) {
          buffer.write('${el.id}_${el.pageIndex}_${el.relativeX.toStringAsFixed(4)}_${el.relativeY.toStringAsFixed(4)}_${el.scale.toStringAsFixed(3)}_${el.fontSize}_${el.text}_');
        }
        return buffer.toString();
      }

      final sigBefore = computeSignature([el1]);

      // Shift element
      el1.relativeX = 0.4500;
      el1.relativeY = 0.5500;

      final sigAfter = computeSignature([el1]);

      expect(sigBefore != sigAfter, isTrue);
    });
  });
}

