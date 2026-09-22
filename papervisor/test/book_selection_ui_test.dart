import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/paper_creation/widgets/book_selection_sheet.dart';

void main() {
  group('BookSelectionSheet UI Tests', () {
    final sampleBooks = [
      {
        'id': 'b-1',
        'name': 'Organic Chemistry',
        'pdf_url': '/storage/books/b1.pdf',
        'workspace': {'id': 'ws-1', 'name': 'Class 12th'},
        'subject': {'id': 'sub-1', 'name': 'Chemistry'},
        'chapters': [
          {'id': 'ch-1', 'name': 'Haloalkanes'},
          {'id': 'ch-2', 'name': 'Alcohols'},
        ],
      },
      {
        'id': 'b-2',
        'name': 'Physics Part 1',
        'pdf_url': null,
        'workspace': {'id': 'ws-1', 'name': 'Class 12th'},
        'subject': {'id': 'sub-2', 'name': 'Physics'},
        'chapters': [
          {'id': 'ch-3', 'name': 'Electrostatics'},
        ],
      },
    ];

    testWidgets('renders books with uppercase names, metadata chips, and selection', (WidgetTester tester) async {
      Map<String, dynamic>? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSelectionSheet(
              books: sampleBooks,
              onSelect: (b) => selected = b,
            ),
          ),
        ),
      );

      // Verify Header
      expect(find.text('Select Source Book'), findsOneWidget);
      expect(find.text('Choose a book to generate examination questions from'), findsOneWidget);

      // Verify Books rendered in uppercase
      expect(find.text('ORGANIC CHEMISTRY'), findsOneWidget);
      expect(find.text('PHYSICS PART 1'), findsOneWidget);

      // Verify Subject & Workspace badges
      expect(find.text('CHEMISTRY'), findsOneWidget);
      expect(find.text('CLASS 12TH'), findsWidgets);
      expect(find.text('2 Ch.'), findsOneWidget);
      expect(find.text('1 Ch.'), findsOneWidget);

      // Preview button should be present for book 1 (which has pdf_url)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Verify Continue button
      expect(find.text('Continue to Step 1'), findsOneWidget);

      // Tap on second book
      await tester.tap(find.text('PHYSICS PART 1'));
      await tester.pumpAndSettle();

      // Tap Continue to Step 1
      await tester.tap(find.text('Continue to Step 1'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!['id'], 'b-2');
    });
  });
}
