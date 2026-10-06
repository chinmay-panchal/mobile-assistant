import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/paper_creation/screens/paper_editor_screen.dart';

void main() {
  testWidgets('PaperEditorScreen merges duplicate OR sections and syncs marks', (WidgetTester tester) async {
    final samplePaper = {
      'title': 'Sample Test Paper',
      'class_name': 'Grade 10',
      'time_allowed_minutes': 60,
      'total_marks': 10,
      'questions': [
        {
          'id': '1',
          'section_name': 'Section A',
          'question_text': 'Question 1',
          'marks': 2,
        },
        {
          'id': '2',
          'section_name': 'Section B',
          'question_text': 'Question 2',
          'marks': 3,
        },
        {
          'id': '3',
          'section_name': 'Section C',
          'question_text': 'Question 3 Main',
          'marks': 5,
        },
        {
          'id': '4',
          'section_name': 'Section C (OR)',
          'question_text': 'Question 3 Alternative',
          'marks': 5,
        },
      ],
      'content': {
        'sections': [
          {'name': 'Section A', 'marks_per_question': 2},
          {'name': 'Section B', 'marks_per_question': 3},
          {'name': 'Section C', 'marks_per_question': 5},
          {'name': 'Section C (OR)', 'marks_per_question': 5},
        ],
      },
    };

    await tester.pumpWidget(
      MaterialApp(
        home: PaperEditorScreen(paper: samplePaper),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sections list only has Section A, Section B, Section C (not a separate Section C (OR) row)
    expect(find.text('Section A'), findsWidgets);
    expect(find.text('Section B'), findsWidgets);
    expect(find.text('Section C'), findsWidgets);
    // Section C (OR) should NOT appear as an input field initial value
    expect(find.widgetWithText(TextFormField, 'Section C (OR)'), findsNothing);

    // Verify badge indicating merged OR section is present
    expect(find.text('Merged with OR Alternate Section'), findsOneWidget);

    // Verify calculated total marks is 2 + 3 + 5 = 10 (not 15 with double-counted Section C (OR))
    expect(find.text('10'), findsWidgets);
  });
}
