import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papervisor/services/cache_service.dart';
import 'package:papervisor/services/paper_service.dart';
import 'package:papervisor/services/reference_paper_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.instance.clearAll();
  });

  group('Paper Caching Tests across 3 Paper Types', () {
    final cacheService = CacheService.instance;
    final paperService = PaperService();
    final refService = ReferencePaperService();

    test('Type 1: Editable JSON Paper caching, update and detail lookup', () async {
      const subjectId = 'subj-101';
      final draftPaper = {
        'id': 'paper-json-1',
        'title': 'Midterm Physics Draft',
        'subject_id': subjectId,
        'is_ai': true,
        'pdf_url': null,
        'total_marks': 50,
        'sections': [
          {
            'name': 'Section A',
            'questions': [{'text': 'What is velocity?', 'marks': 5}]
          }
        ],
      };

      // 1. Add newly generated JSON paper to cache
      await paperService.addCachedPaper(subjectId, draftPaper);

      // Verify sync in-memory retrieval
      final syncPapers = paperService.getCachedPapersSync(subjectId);
      expect(syncPapers, isNotNull);
      expect(syncPapers!.length, equals(1));
      expect(syncPapers.first['id'], equals('paper-json-1'));
      expect(syncPapers.first['pdf_url'], isNull);

      // Verify single paper detail cache
      final detail = paperService.getCachedPaperDetailSync('paper-json-1');
      expect(detail, isNotNull);
      expect(detail!['total_marks'], equals(50));

      // 2. Simulate editing in PaperEditorScreen
      final editedPaper = Map<String, dynamic>.from(draftPaper);
      editedPaper['title'] = 'Midterm Physics (Edited)';
      editedPaper['total_marks'] = 60;

      await paperService.updatePaperInCache('paper-json-1', editedPaper);

      // Verify updated values in subject list and detail cache
      final updatedList = paperService.getCachedPapersSync(subjectId);
      expect(updatedList!.first['title'], equals('Midterm Physics (Edited)'));
      expect(updatedList.first['total_marks'], equals(60));

      final updatedDetail = paperService.getCachedPaperDetailSync('paper-json-1');
      expect(updatedDetail!['title'], equals('Midterm Physics (Edited)'));
      expect(updatedDetail['total_marks'], equals(60));
    });

    test('Type 2: AI Saved PDF transition updates cache with pdf_url', () async {
      const subjectId = 'subj-102';
      final draftPaper = {
        'id': 'paper-saved-pdf-1',
        'title': 'Math Final Exam',
        'subject_id': subjectId,
        'is_ai': true,
        'pdf_url': null,
        'total_marks': 100,
      };

      await cacheService.cachePapers(subjectId, [draftPaper]);
      expect(paperService.getCachedPapersSync(subjectId)!.first['pdf_url'], isNull);

      // When saved as PDF
      final finalizedPaper = Map<String, dynamic>.from(draftPaper);
      finalizedPaper['pdf_url'] = 'https://storage.googleapis.com/papers/math_final.pdf';

      await cacheService.updatePaperInCaches('paper-saved-pdf-1', finalizedPaper);

      // Verified updated state in list
      final cachedList = paperService.getCachedPapersSync(subjectId);
      expect(cachedList!.first['pdf_url'], equals('https://storage.googleapis.com/papers/math_final.pdf'));
    });

    test('Type 3: Reference Paper caching and removal', () async {
      const subjectId = 'subj-103';
      final refPaper = {
        'id': 'ref-pyq-1',
        'title': 'CBSE 2024 Past Paper',
        'subject_id': subjectId,
        'file_url': 'https://storage.googleapis.com/ref/cbse_2024.pdf',
        'year': 2024,
        'exam_type': 'Board Exam',
        'is_ai': false,
      };

      // Cache reference paper
      await cacheService.addCachedReferencePaper(subjectId, refPaper);

      final syncRefs = refService.getCachedReferencePapersSync(subjectId);
      expect(syncRefs, isNotNull);
      expect(syncRefs!.length, equals(1));
      expect(syncRefs.first['id'], equals('ref-pyq-1'));
      expect(syncRefs.first['is_ai'], isFalse);

      // Delete reference paper
      await cacheService.removeReferencePaperFromAllCaches('ref-pyq-1');
      final afterDelete = refService.getCachedReferencePapersSync(subjectId);
      expect(afterDelete!.isEmpty, isTrue);
    });

    test('Deleting AI paper removes it from all subject lists and details', () async {
      const subjectId = 'subj-104';
      final paper = {
        'id': 'paper-to-delete',
        'title': 'To Be Deleted',
        'subject_id': subjectId,
      };

      await paperService.addCachedPaper(subjectId, paper);
      expect(paperService.getCachedPapersSync(subjectId)!.length, equals(1));

      await cacheService.removePaperFromAllCaches('paper-to-delete');
      expect(paperService.getCachedPapersSync(subjectId)!.isEmpty, isTrue);
      expect(paperService.getCachedPaperDetailSync('paper-to-delete'), isNull);
    });

    test('clearAll clears all paper caches on logout', () async {
      const subjectId = 'subj-105';
      await paperService.addCachedPaper(subjectId, {'id': 'paper-p1', 'title': 'Test'});
      await cacheService.addCachedReferencePaper(subjectId, {'id': 'ref-r1', 'title': 'Ref'});

      expect(paperService.getCachedPapersSync(subjectId), isNotNull);
      expect(refService.getCachedReferencePapersSync(subjectId), isNotNull);

      await cacheService.clearAll();

      expect(paperService.getCachedPapersSync(subjectId), isNull);
      expect(refService.getCachedReferencePapersSync(subjectId), isNull);
    });
  });
}
