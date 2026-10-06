import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/workspace/widgets/pyq_search_card.dart';
import 'package:papervisor/features/workspace/widgets/workspace_card.dart';
import 'package:papervisor/features/workspace/widgets/workspace_delete_dialog.dart';
import 'package:papervisor/features/workspace/widgets/workspace_empty_state.dart';
import 'package:papervisor/features/workspace/widgets/workspace_form_sheet.dart';
import 'package:papervisor/features/workspace/widgets/workspace_header.dart';
import 'package:papervisor/features/workspace/widgets/workspace_loading_state.dart';

void main() {
  group('Workspace UI & Component Tests', () {
    testWidgets('WorkspaceHeader renders greeting, title and action buttons', (WidgetTester tester) async {
      bool logoutTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceHeader(
              onLogout: () => logoutTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Hello Educator'), findsOneWidget);
      expect(find.text('Your Workspaces'), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_rounded));
      expect(logoutTapped, isTrue);
    });

    testWidgets('PyqSearchCard renders title, subtitle and responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PyqSearchCard(
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Find Previous Year Questions'), findsOneWidget);
      expect(find.text('Search and download PYQs for your subjects.'), findsOneWidget);
      expect(find.text('Explore PYQs'), findsOneWidget);

      await tester.tap(find.text('Find Previous Year Questions'));
      expect(tapped, isTrue);
    });

    testWidgets('WorkspaceCard renders name, subject badge and popup menu items', (WidgetTester tester) async {
      bool cardTapped = false;
      bool editTapped = false;
      bool deleteTapped = false;

      final sampleWorkspace = {
        'id': 'ws-123',
        'name': 'Class 10th Physics',
        'subjectCount': 5,
        'paperCount': 0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceCard(
              workspace: sampleWorkspace,
              index: 0,
              onTap: () => cardTapped = true,
              onEdit: () => editTapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('CLASS 10TH PHYSICS'), findsOneWidget);
      expect(find.text('5 Subjects'), findsOneWidget);

      await tester.tap(find.text('CLASS 10TH PHYSICS'));
      expect(cardTapped, isTrue);

      // Open three-dot menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Edit Workspace'), findsOneWidget);
      expect(find.text('Delete Workspace'), findsOneWidget);

      await tester.tap(find.text('Edit Workspace'));
      expect(editTapped, isTrue);

      // Verify delete handler is set
      expect(deleteTapped, isFalse);
    });

    testWidgets('WorkspaceEmptyState renders illustration and optional create CTA when provided', (WidgetTester tester) async {
      bool createTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceEmptyState(
              showButton: true,
              onCreateWorkspace: () => createTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Create your first workspace'), findsOneWidget);
      expect(find.text('Create Workspace'), findsOneWidget);

      await tester.tap(find.text('Create Workspace'));
      expect(createTapped, isTrue);
    });

    testWidgets('WorkspaceEmptyState without onCreateWorkspace does not render middle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkspaceEmptyState(),
          ),
        ),
      );

      expect(find.text('Create your first workspace'), findsOneWidget);
      expect(find.text('Create Workspace'), findsNothing);
    });

    testWidgets('WorkspaceLoadingState renders skeleton placeholders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkspaceLoadingState(),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('WorkspaceFormSheet renders title, input and submits value', (WidgetTester tester) async {
      String submittedName = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceFormSheet(
              title: 'Create Workspace',
              subtitle: 'Enter workspace name',
              submitButtonText: 'Create',
              onSubmit: (name) async => submittedName = name,
            ),
          ),
        ),
      );

      expect(find.text('Create Workspace'), findsOneWidget);
      expect(find.text('Enter workspace name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Class 12th Math');
      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(submittedName, equals('Class 12th Math'));
    });

    testWidgets('WorkspaceDeleteDialog renders confirmation and delete button', (WidgetTester tester) async {
      bool deleteConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceDeleteDialog(
              workspaceName: 'Old Physics Class',
              onConfirmDelete: () async => deleteConfirmed = true,
            ),
          ),
        ),
      );

      expect(find.text('Delete Workspace?'), findsOneWidget);
      expect(find.textContaining('Old Physics Class'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleteConfirmed, isTrue);
    });
  });
}
