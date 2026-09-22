import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/books/widgets/book_header.dart';
import 'package:papervisor/features/books/widgets/book_pdf_card.dart';
import 'package:papervisor/features/books/widgets/chapter_card.dart';
import 'package:papervisor/features/books/widgets/add_chapter_tile.dart';
import 'package:papervisor/features/books/widgets/chapter_form_sheet.dart';
import 'package:papervisor/features/books/widgets/chapter_delete_dialog.dart';
import 'package:papervisor/features/books/widgets/chapter_empty_state.dart';
import 'package:papervisor/features/books/widgets/chapter_loading_state.dart';

void main() {
  group('Book Chapters UI Redesign Widget Tests', () {
    testWidgets('BookHeader renders title, subject, chapter count badge and handles callbacks', (WidgetTester tester) async {
      bool previewTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookHeader(
              bookTitle: 'Science Part 1',
              subjectName: 'Physics',
              chapterCount: 8,
              onPreviewBook: () => previewTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('SCIENCE PART 1'), findsOneWidget);
      expect(find.text('PHYSICS'), findsOneWidget);
      expect(find.text('8 Chapters'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.picture_as_pdf_rounded));
      expect(previewTapped, isTrue);
    });

    testWidgets('BookPdfCard renders uploaded document with Ready status and responds to tap', (WidgetTester tester) async {
      bool previewTapped = false;

      final sampleDoc = {
        'filename': 'NCERT_Physics_Grade10.pdf',
        'status': 'READY',
        'file_url': '/storage/documents/1/original.pdf',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookPdfCard(
              document: sampleDoc,
              onPreview: () => previewTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('NCERT_Physics_Grade10.pdf'), findsOneWidget);
      expect(find.text('Ready to read'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);

      await tester.tap(find.text('Open'));
      expect(previewTapped, isTrue);
    });

    testWidgets('BookPdfCard renders upload prompt card when no document is uploaded', (WidgetTester tester) async {
      bool uploadTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookPdfCard(
              document: null,
              onUpload: () => uploadTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Upload Whole Book PDF'), findsOneWidget);
      expect(find.text('Enables page range auto-fill across chapters'), findsOneWidget);

      await tester.tap(find.text('Upload Whole Book PDF'));
      expect(uploadTapped, isTrue);
    });

    testWidgets('ChapterCard renders formatted number, title, page range and handles popup menu', (WidgetTester tester) async {
      bool editTapped = false;
      bool previewPdfTapped = false;

      final sampleChapter = {
        'id': 'ch_1',
        'chapter_number': 1,
        'name': 'Light - Reflection and Refraction',
        'start_page': 160,
        'end_page': 190,
        'file_url': '/storage/documents/ch1.pdf',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChapterCard(
              chapter: sampleChapter,
              onEdit: () => editTapped = true,
              onDelete: () {},
              onPreviewPdf: () => previewPdfTapped = true,
            ),
          ),
        ),
      );

      // Verify formatted number, title, and pages
      expect(find.text('01'), findsOneWidget);
      expect(find.text('Light - Reflection and Refraction'), findsOneWidget);
      expect(find.text('Pages 160–190'), findsOneWidget);
      expect(find.text('PDF attached'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);

      // Tap Preview button
      await tester.tap(find.text('Preview'));
      expect(previewPdfTapped, isTrue);

      // Open three-dot menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Edit Chapter'), findsOneWidget);
      expect(find.text('Delete Chapter'), findsOneWidget);
      // Verify no divider (black line) between edit and delete
      expect(find.byType(PopupMenuDivider), findsNothing);

      // Tap Edit
      await tester.tap(find.text('Edit Chapter'));
      expect(editTapped, isTrue);
    });

    testWidgets('AddChapterTile renders action box and triggers tap', (WidgetTester tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddChapterTile(
              onTap: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Chapter'), findsOneWidget);
      expect(find.text('Create a new chapter for this book'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.text('Add Chapter'));
      expect(addTapped, isTrue);
    });

    testWidgets('ChapterEmptyState renders illustration and message without center button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChapterEmptyState(),
          ),
        ),
      );

      expect(find.text('No chapters yet'), findsOneWidget);
      expect(find.text('Add your first chapter to organize this book and prepare exam papers.'), findsOneWidget);
      expect(find.text('+ Add Chapter'), findsNothing);
    });

    testWidgets('ChapterLoadingState renders animated skeleton elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChapterLoadingState(),
          ),
        ),
      );

      expect(find.byType(ChapterLoadingState), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('ChapterDeleteDialog displays confirmation message and triggers delete callback', (WidgetTester tester) async {
      bool deleteConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ChapterDeleteDialog.show(
                      context: context,
                      chapterNumber: '3',
                      chapterName: 'Electricity',
                      onConfirmDelete: () async {
                        deleteConfirmed = true;
                      },
                    );
                  },
                  child: const Text('Show Delete Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Delete Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Chapter?'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to delete Chapter 3 ("Electricity")?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteConfirmed, isTrue);
    });

    testWidgets('ChapterFormSheet when book is uploaded shows start/end pages and hides chapter PDF', (WidgetTester tester) async {
      int? submittedNum;
      String? submittedTitle;
      int? submittedStart;
      int? submittedEnd;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ChapterFormSheet.showAdd(
                      context: context,
                      nextChapterNum: 4,
                      hasWholeBookPdf: true,
                      onSubmit: ({
                        required int chapterNumber,
                        required String title,
                        int? startPage,
                        int? endPage,
                        selectedPdfFile,
                      }) async {
                        submittedNum = chapterNumber;
                        submittedTitle = title;
                        submittedStart = startPage;
                        submittedEnd = endPage;
                      },
                    );
                  },
                  child: const Text('Open Add Chapter'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Add Chapter'));
      await tester.pumpAndSettle();

      expect(find.text('Add Chapter'), findsNWidgets(2));
      expect(find.text('Chapter Number'), findsOneWidget);
      expect(find.text('Chapter Name'), findsOneWidget);
      // Compulsory fields, no (Optional)
      expect(find.text('Start Page'), findsOneWidget);
      expect(find.text('End Page'), findsOneWidget);
      expect(find.text('Start Page (Optional)'), findsNothing);
      expect(find.text('End Page (Optional)'), findsNothing);
      // Chapter PDF must NOT be shown when book is already uploaded
      expect(find.text('Chapter PDF'), findsNothing);
      expect(find.text('Upload Chapter PDF'), findsNothing);

      // Enter chapter name, start page and end page
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Chemical Reactions and Equations'),
        'Magnetic Effects',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 1').last,
        '10',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 24'),
        '25',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Add Chapter').last);
      await tester.pumpAndSettle();

      expect(submittedNum, 4);
      expect(submittedTitle, 'Magnetic Effects');
      expect(submittedStart, 10);
      expect(submittedEnd, 25);
    });

    testWidgets('ChapterFormSheet when book is NOT uploaded hides start/end pages and shows chapter PDF', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ChapterFormSheet.showAdd(
                      context: context,
                      nextChapterNum: 1,
                      hasWholeBookPdf: false,
                      onSubmit: ({
                        required int chapterNumber,
                        required String title,
                        int? startPage,
                        int? endPage,
                        selectedPdfFile,
                      }) async {},
                    );
                  },
                  child: const Text('Open Add Chapter Without Book'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Add Chapter Without Book'));
      await tester.pumpAndSettle();

      // Start Page and End Page must NOT be shown
      expect(find.text('Start Page'), findsNothing);
      expect(find.text('End Page'), findsNothing);
      // Chapter PDF MUST be shown (and without Optional badge)
      expect(find.text('Chapter PDF'), findsOneWidget);
      expect(find.text('Upload Chapter PDF'), findsOneWidget);
      expect(find.text('Optional'), findsNothing);
    });

    testWidgets('ChapterFormSheet in Edit mode pre-fills fields and updates chapter', (WidgetTester tester) async {
      int? updatedNum;
      String? updatedTitle;

      final chapter = {
        'id': 'c1',
        'chapter_number': 2,
        'name': 'Acids, Bases and Salts',
        'start_page': 20,
        'end_page': 45,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ChapterFormSheet.showEdit(
                      context: context,
                      chapter: chapter,
                      hasWholeBookPdf: true,
                      onSubmit: ({
                        required int chapterNumber,
                        required String title,
                        int? startPage,
                        int? endPage,
                        selectedPdfFile,
                      }) async {
                        updatedNum = chapterNumber;
                        updatedTitle = title;
                      },
                    );
                  },
                  child: const Text('Open Edit Chapter'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Edit Chapter'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Chapter'), findsOneWidget);
      expect(find.text('Acids, Bases and Salts'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Edit chapter name
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Chemical Reactions and Equations'),
        'Acids, Bases and Salts (Revised)',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(updatedNum, 2);
      expect(updatedTitle, 'Acids, Bases and Salts (Revised)');
    });
  });
}
