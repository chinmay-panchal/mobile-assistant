import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/subjects/widgets/subject_header.dart';
import 'package:papervisor/features/subjects/widgets/add_subject_tile.dart';
import 'package:papervisor/features/subjects/widgets/subject_card.dart';
import 'package:papervisor/features/subjects/widgets/subject_empty_state.dart';
import 'package:papervisor/features/subjects/widgets/subject_loading_state.dart';
import 'package:papervisor/features/subjects/widgets/subject_form_sheet.dart';
import 'package:papervisor/features/subjects/widgets/subject_delete_dialog.dart';

void main() {
  group('Subject UI Redesign Widget Tests', () {
    testWidgets('SubjectHeader renders workspace name, count badge, and titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SubjectHeader(
              workspaceName: 'Engineering Prep',
              subjectCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('ENGINEERING PREP'), findsOneWidget);
      expect(find.text('5 Subjects'), findsOneWidget);
      expect(find.text('Your Subjects'), findsOneWidget);
      expect(find.text('Organize your subjects and study material in one place.'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });

    testWidgets('AddSubjectTile renders plus icon, action text, and responds to tap', (WidgetTester tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddSubjectTile(
              onTap: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Subject'), findsOneWidget);
      expect(find.text('Create a new subject'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.text('Add Subject'));
      expect(addTapped, isTrue);
    });

    testWidgets('SubjectCard renders subject name in uppercase, book count, and popup actions', (WidgetTester tester) async {
      bool cardTapped = false;
      bool editTapped = false;
      bool deleteTapped = false;

      final sampleSubject = {
        'id': 'sub-101',
        'name': 'Mathematics',
        'bookCount': 12,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubjectCard(
              subject: sampleSubject,
              index: 0,
              onTap: () => cardTapped = true,
              onEdit: () => editTapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('MATHEMATICS'), findsOneWidget);
      expect(find.text('12 books'), findsOneWidget);
      // Unified common education icon
      expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);

      await tester.tap(find.text('MATHEMATICS'));
      expect(cardTapped, isTrue);

      // Open three-dot menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Edit Subject'), findsOneWidget);
      expect(find.text('Delete Subject'), findsOneWidget);

      await tester.tap(find.text('Edit Subject'));
      expect(editTapped, isTrue);
      expect(deleteTapped, isFalse);
    });

    testWidgets('SubjectEmptyState renders illustration and triggers add CTA', (WidgetTester tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubjectEmptyState(
              onAddSubject: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No subjects yet'), findsOneWidget);
      expect(find.text('Add your first subject to start organizing your books and papers.'), findsOneWidget);
      expect(find.text('Add Subject'), findsOneWidget);

      await tester.tap(find.text('Add Subject'));
      expect(addTapped, isTrue);
    });

    testWidgets('SubjectLoadingState renders skeleton cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SubjectLoadingState(),
          ),
        ),
      );

      expect(find.byType(SubjectLoadingState), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('SubjectFormSheet allows entering subject name and submitting', (WidgetTester tester) async {
      String submittedName = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SubjectFormSheet.show(
                    context: context,
                    title: 'Add Subject',
                    subtitle: 'Give your subject a name to get started.',
                    submitButtonText: 'Add',
                    onSubmit: (name) async {
                      submittedName = name;
                    },
                  );
                },
                child: const Text('Open Add'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add Subject'), findsOneWidget);
      expect(find.text('Give your subject a name to get started.'), findsOneWidget);
      expect(find.text('Subject name'), findsOneWidget);

      // Enter name and submit
      await tester.enterText(find.byType(TextField), 'Physics');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(submittedName, equals('Physics'));
    });

    testWidgets('SubjectFormSheet pre-fills initial name for editing', (WidgetTester tester) async {
      String editedName = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SubjectFormSheet.show(
                    context: context,
                    title: 'Edit Subject',
                    subtitle: 'Update the name of your subject.',
                    submitButtonText: 'Save Changes',
                    initialName: 'Chemistry',
                    onSubmit: (name) async {
                      editedName = name;
                    },
                  );
                },
                child: const Text('Open Edit'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Subject'), findsOneWidget);
      expect(find.text('Update the name of your subject.'), findsOneWidget);
      expect(find.text('Chemistry'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Advanced Chemistry');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(editedName, equals('Advanced Chemistry'));
    });

    testWidgets('SubjectDeleteDialog displays warning and handles confirm delete', (WidgetTester tester) async {
      bool deleteConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SubjectDeleteDialog.show(
                    context: context,
                    subjectName: 'Computer Science',
                    onConfirmDelete: () async {
                      deleteConfirmed = true;
                    },
                  );
                },
                child: const Text('Open Delete'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Subject?'), findsOneWidget);
      expect(find.textContaining('Computer Science'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteConfirmed, isTrue);
    });
  });
}
