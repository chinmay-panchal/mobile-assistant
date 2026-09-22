import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/subjects/widgets/subject_detail_header.dart';
import 'package:papervisor/features/subjects/widgets/subject_detail_tabs.dart';
import 'package:papervisor/features/subjects/widgets/book_card.dart';
import 'package:papervisor/features/subjects/widgets/add_book_tile.dart';
import 'package:papervisor/features/subjects/widgets/book_form_sheet.dart';
import 'package:papervisor/features/subjects/widgets/book_delete_dialog.dart';
import 'package:papervisor/features/subjects/widgets/paper_card.dart';
import 'package:papervisor/features/subjects/widgets/paper_delete_dialog.dart';
import 'package:papervisor/features/subjects/widgets/detail_empty_state.dart';
import 'package:papervisor/features/subjects/widgets/detail_loading_state.dart';
import 'package:papervisor/features/subjects/constants/subject_detail_assets.dart';

void main() {
  group('Subject Detail UI Redesign Widget Tests', () {
    testWidgets('SubjectDetailHeader renders title, live counts, and subject icon badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SubjectDetailHeader(
              subjectName: 'Mathematics',
              bookCount: 24,
              paperCount: 8,
            ),
          ),
        ),
      );

      expect(find.text('MATHEMATICS'), findsOneWidget);
      expect(find.text('24 Books · 8 Papers'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });

    testWidgets('SubjectDetailTabs renders Books and Papers tab segments with count badges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return SubjectDetailTabs(
                    controller: DefaultTabController.of(context),
                    bookCount: 12,
                    paperCount: 4,
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Books'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Papers'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('BookCard renders book title, subtitle and triggers tap and popup actions', (WidgetTester tester) async {
      bool cardTapped = false;
      bool editTapped = false;
      bool deleteTapped = false;

      final sampleBook = {
        'id': 'book-1',
        'title': 'Advanced Calculus',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookCard(
              book: sampleBook,
              index: 0,
              onTap: () => cardTapped = true,
              onEdit: () => editTapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ADVANCED CALCULUS'), findsOneWidget);
      expect(find.text('Chapters & study material'), findsOneWidget);

      await tester.tap(find.text('ADVANCED CALCULUS'));
      expect(cardTapped, isTrue);

      // Open three-dot menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Edit Book'), findsOneWidget);
      expect(find.text('Delete Book'), findsOneWidget);

      await tester.tap(find.text('Edit Book'));
      expect(editTapped, isTrue);
      expect(deleteTapped, isFalse);
    });

    testWidgets('AddBookTile renders Add Book and triggers callback', (WidgetTester tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddBookTile(onTap: () => addTapped = true),
          ),
        ),
      );

      expect(find.text('Add Book'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.text('Add Book'));
      expect(addTapped, isTrue);
    });

    testWidgets('BookFormSheet allows inputting book name and submitting for Add', (WidgetTester tester) async {
      String submittedName = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BookFormSheet.show(
                    context: context,
                    title: 'Add Book',
                    subtitle: 'Give your book a name to get started.',
                    submitButtonText: 'Add Book',
                    onSubmit: (name) async {
                      submittedName = name;
                    },
                  );
                },
                child: const Text('Open Add Book'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Add Book'));
      await tester.pumpAndSettle();

      expect(find.text('Add Book'), findsNWidgets(2)); // Title & Button
      expect(find.text('Book name'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Modern Algebra');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Book').last);
      await tester.pumpAndSettle();

      expect(submittedName, equals('Modern Algebra'));
    });

    testWidgets('BookFormSheet pre-fills initial name for Edit Book', (WidgetTester tester) async {
      String editedName = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BookFormSheet.show(
                    context: context,
                    title: 'Edit Book',
                    subtitle: 'Update the name of your book.',
                    submitButtonText: 'Save Changes',
                    initialName: 'Linear Algebra',
                    onSubmit: (name) async {
                      editedName = name;
                    },
                  );
                },
                child: const Text('Open Edit Book'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Edit Book'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Book'), findsOneWidget);
      expect(find.text('Linear Algebra'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Linear Algebra 2nd Ed');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(editedName, equals('Linear Algebra 2nd Ed'));
    });

    testWidgets('BookDeleteDialog renders confirmation and triggers delete', (WidgetTester tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BookDeleteDialog.show(
                    context: context,
                    bookName: 'Organic Chemistry',
                    onConfirmDelete: () async {
                      deleted = true;
                    },
                  );
                },
                child: const Text('Open Delete Book'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Delete Book'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Book?'), findsOneWidget);
      expect(find.textContaining('Organic Chemistry'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('PaperCard renders AI Paper badge, marks and responds to tap & delete', (WidgetTester tester) async {
      bool paperTapped = false;
      bool deleteTapped = false;

      final sampleAiPaper = {
        'id': 'paper-101',
        'title': 'Mid-Term Exam Paper',
        'total_marks': 50,
        'is_ai': true,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaperCard(
              paper: sampleAiPaper,
              onTap: () => paperTapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Mid-Term Exam Paper'), findsOneWidget);
      expect(find.text('AI Paper'), findsOneWidget);
      expect(find.text('50 Marks'), findsOneWidget);

      await tester.tap(find.text('Mid-Term Exam Paper'));
      expect(paperTapped, isTrue);

      await tester.tap(find.byTooltip('Delete Paper'));
      expect(deleteTapped, isTrue);
    });

    testWidgets('PaperCard responsively renders 1000 marks without overflow on narrow screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sample1000MarksPaper = {
        'id': 'paper-1000',
        'title': 'CBSE Comprehensive Board Exam All Units Paper',
        'total_marks': 1000,
        'is_ai': true,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaperCard(
              paper: sample1000MarksPaper,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('1000 Marks'), findsOneWidget);
      expect(find.text('AI Paper'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PaperDeleteDialog displays confirmation and triggers delete', (WidgetTester tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PaperDeleteDialog.show(
                    context: context,
                    paperTitle: 'Final Exam 2024',
                    isAi: true,
                    onConfirmDelete: () async {
                      deleted = true;
                    },
                  );
                },
                child: const Text('Open Delete Paper'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Delete Paper'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Paper?'), findsOneWidget);
      expect(find.textContaining('Final Exam 2024'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('DetailEmptyState renders illustration and triggers action callback', (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailEmptyState(
              illustrationAsset: SubjectDetailAssets.emptyBooks,
              title: 'No books yet',
              subtitle: 'Add a book to start organizing your study material.',
              buttonText: 'Add Book',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No books yet'), findsOneWidget);
      expect(find.text('Add a book to start organizing your study material.'), findsOneWidget);
      expect(find.text('Add Book'), findsOneWidget);

      await tester.tap(find.text('Add Book'));
      expect(actionTapped, isTrue);
    });

    testWidgets('DetailLoadingState renders skeleton list items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DetailLoadingState(count: 3),
          ),
        ),
      );
      expect(find.byType(DetailLoadingState), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('DetailEmptyState for papers renders button and responds to tap', (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetailEmptyState(
              illustrationAsset: SubjectDetailAssets.emptyPapers,
              title: 'No papers yet',
              subtitle: 'Create your first paper to get started.',
              buttonText: 'Create Paper with AI',
              buttonIcon: Icons.auto_awesome_rounded,
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No papers yet'), findsOneWidget);
      expect(find.text('Create your first paper to get started.'), findsOneWidget);
      expect(find.text('Create Paper with AI'), findsOneWidget);

      await tester.tap(find.text('Create Paper with AI'));
      expect(actionTapped, isTrue);
    });
  });
}
