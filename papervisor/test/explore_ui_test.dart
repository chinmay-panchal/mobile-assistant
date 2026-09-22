import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/explore/repositories/past_downloads_repository.dart';
import 'package:papervisor/features/explore/widgets/explore_header.dart';
import 'package:papervisor/features/explore/widgets/explore_empty_state.dart';
import 'package:papervisor/features/explore/widgets/explore_input_composer.dart';
import 'package:papervisor/features/explore/widgets/explore_loading_card.dart';
import 'package:papervisor/features/explore/widgets/explore_error_banner.dart';
import 'package:papervisor/features/explore/widgets/explore_clarification_card.dart';
import 'package:papervisor/features/explore/widgets/explore_result_card.dart';
import 'package:papervisor/features/explore/widgets/history_delete_dialog.dart';

void main() {
  group('Explore PYQs UI Component Tests', () {
    testWidgets('ExploreHeader renders title, subtitle, history button without any back button', (WidgetTester tester) async {
      bool historyTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreHeader(
              downloadCount: 3,
              onHistoryTap: () => historyTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('PYQ Explorer'), findsOneWidget);
      expect(find.text('Find previous year questions'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Download badge
      // Confirm NO back button exists
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.history_rounded));
      expect(historyTapped, isTrue);
    });

    testWidgets('ExploreEmptyState renders illustration, title, subtitle and suggestion chips', (WidgetTester tester) async {
      String selectedSuggestion = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreEmptyState(
              onSuggestionSelected: (val) => selectedSuggestion = val,
            ),
          ),
        ),
      );

      expect(find.text('Find any PYQ'), findsOneWidget);
      expect(find.text('Search previous year questions from your subjects, exams and topics.'), findsOneWidget);
      expect(find.text('Popular searches'), findsOneWidget);
      expect(find.text('Find Physics PYQs'), findsOneWidget);

      await tester.tap(find.text('Find Physics PYQs'));
      expect(selectedSuggestion, equals('Find Physics PYQs'));
    });

    testWidgets('ExploreInputComposer accepts text and triggers submit', (WidgetTester tester) async {
      final ctrl = TextEditingController();
      final node = FocusNode();
      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreInputComposer(
              controller: ctrl,
              focusNode: node,
              isLoading: false,
              onSubmit: () => submitted = true,
            ),
          ),
        ),
      );

      expect(find.text('Ask for a PYQ (e.g. Physics 2024)...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Engineering Mathematics 2023');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      expect(submitted, isTrue);
    });

    testWidgets('ExploreLoadingCard renders searching indicators', (WidgetTester tester) async {
      late AnimationController anim;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                final vsync = tester;
                anim = AnimationController(vsync: vsync, duration: const Duration(seconds: 1));
                return Stack(
                  children: [
                    ExploreLoadingCard(pulseCtrl: anim),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Searching for your PYQ PDF…'), findsOneWidget);
      expect(find.text('Evaluating candidates and extracting documents'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ExploreErrorBanner displays message and triggers dismiss', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreErrorBanner(
              message: 'Could not find papers for that year',
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Could not find papers for that year'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, isTrue);
    });

    testWidgets('ExploreClarificationCard renders options and submits selected choice', (WidgetTester tester) async {
      String chosen = '';
      final dummyRequest = _DummyClarificationRequest(
        question: 'Which semester did you mean?',
        options: ['Semester 3', 'Semester 5'],
        stepIndex: 1,
        totalSteps: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreClarificationCard(
              request: dummyRequest,
              onSubmit: (opt) => chosen = opt,
            ),
          ),
        ),
      );

      expect(find.text('Which semester did you mean?'), findsOneWidget);
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('Semester 3'), findsOneWidget);
      expect(find.text('Semester 5'), findsOneWidget);

      await tester.tap(find.text('Semester 3'));
      expect(chosen, equals('Semester 3'));
    });

    testWidgets('ExploreResultCard renders ready document and triggers open', (WidgetTester tester) async {
      bool opened = false;
      bool dismissed = false;
      final pdf = DownloadedPdf(
        title: 'Computer Networks Endsem 2024',
        sourceUrl: 'https://example.com/cn.pdf',
        localPath: '/tmp/cn.pdf',
        downloadedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreResultCard(
              pdf: pdf,
              onOpenPdf: () => opened = true,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('PYQ PDF Ready'), findsOneWidget);
      expect(find.text('Computer Networks Endsem 2024'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);

      await tester.tap(find.text('Open'));
      expect(opened, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, isTrue);
    });

    testWidgets('HistoryDeleteDialog shows dialog and handles delete callback', (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  HistoryDeleteDialog.showItemDelete(
                    context: context,
                    pdfTitle: 'Maths 2024',
                    onConfirm: () async => confirmed = true,
                  );
                },
                child: const Text('Delete Item'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete Item'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this PDF?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });
  });
}

class _DummyClarificationRequest {
  final String question;
  final List<String> options;
  final int stepIndex;
  final int totalSteps;

  _DummyClarificationRequest({
    required this.question,
    required this.options,
    required this.stepIndex,
    required this.totalSteps,
  });
}
