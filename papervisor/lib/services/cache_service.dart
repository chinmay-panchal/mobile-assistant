import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight caching service for Workspaces, Subjects, Books, and Chapters.
/// Provides both fast in-memory access and persistent disk storage via SharedPreferences.
///
/// NOTE: Per requirements, Paper lists and Wizard Steps 1-5 are never cached here.
class CacheService {
  CacheService._internal();
  static final CacheService instance = CacheService._internal();
  factory CacheService() => instance;

  // In-memory cache for instant synchronous access
  final Map<String, List<Map<String, dynamic>>> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Default TTL: 1 hour (data is refreshed in background when stale)
  static const Duration defaultTtl = Duration(hours: 1);

  // ---------------------------------------------------------------------------
  // Workspaces Caching
  // ---------------------------------------------------------------------------
  static const String keyWorkspaces = 'cache_workspaces';

  Future<void> cacheWorkspaces(List<Map<String, dynamic>> workspaces) async {
    await _saveList(keyWorkspaces, workspaces);
  }

  Future<List<Map<String, dynamic>>?> getWorkspaces() async {
    return _loadList(keyWorkspaces);
  }

  List<Map<String, dynamic>>? getWorkspacesSync() {
    return _memoryCache[keyWorkspaces];
  }

  Future<void> invalidateWorkspaces() async {
    await _removeKey(keyWorkspaces);
  }

  // ---------------------------------------------------------------------------
  // Subjects Caching (keyed by workspaceId)
  // ---------------------------------------------------------------------------
  static String keySubjects(String workspaceId) =>
      'cache_subjects_$workspaceId';

  Future<void> cacheSubjects(
    String workspaceId,
    List<Map<String, dynamic>> subjects,
  ) async {
    await _saveList(keySubjects(workspaceId), subjects);
  }

  Future<List<Map<String, dynamic>>?> getSubjects(String workspaceId) async {
    return _loadList(keySubjects(workspaceId));
  }

  List<Map<String, dynamic>>? getSubjectsSync(String workspaceId) {
    return _memoryCache[keySubjects(workspaceId)];
  }

  Future<void> invalidateSubjects(String workspaceId) async {
    await _removeKey(keySubjects(workspaceId));
  }

  Future<void> invalidateAllSubjects() async {
    await _removeKeysStartingWith('cache_subjects_');
  }

  // ---------------------------------------------------------------------------
  // Books Caching (keyed by subjectId and all-books)
  // ---------------------------------------------------------------------------
  static String keyBooks(String subjectId) => 'cache_books_$subjectId';
  static const String keyAllBooks = 'cache_books_all';

  Future<void> cacheBooks(
    String subjectId,
    List<Map<String, dynamic>> books,
  ) async {
    await _saveList(keyBooks(subjectId), books);
  }

  Future<List<Map<String, dynamic>>?> getBooks(String subjectId) async {
    return _loadList(keyBooks(subjectId));
  }

  List<Map<String, dynamic>>? getBooksSync(String subjectId) {
    return _memoryCache[keyBooks(subjectId)];
  }

  Future<void> cacheAllBooks(List<Map<String, dynamic>> books) async {
    await _saveList(keyAllBooks, books);
  }

  Future<List<Map<String, dynamic>>?> getAllBooks() async {
    return _loadList(keyAllBooks);
  }

  List<Map<String, dynamic>>? getAllBooksSync() {
    return _memoryCache[keyAllBooks];
  }

  Future<void> invalidateBooks(String subjectId) async {
    await _removeKey(keyBooks(subjectId));
    await _removeKey(keyAllBooks);
  }

  Future<void> invalidateAllBooks() async {
    await _removeKeysStartingWith('cache_books_');
  }

  // ---------------------------------------------------------------------------
  // Chapters Caching (keyed by bookId)
  // ---------------------------------------------------------------------------
  static String keyChapters(String bookId) => 'cache_chapters_$bookId';

  Future<void> cacheChapters(
    String bookId,
    List<Map<String, dynamic>> chapters,
  ) async {
    await _saveList(keyChapters(bookId), chapters);
  }

  Future<List<Map<String, dynamic>>?> getChapters(String bookId) async {
    return _loadList(keyChapters(bookId));
  }

  List<Map<String, dynamic>>? getChaptersSync(String bookId) {
    return _memoryCache[keyChapters(bookId)];
  }

  Future<void> invalidateChapters(String bookId) async {
    await _removeKey(keyChapters(bookId));
  }

  Future<void> invalidateAllChapters() async {
    await _removeKeysStartingWith('cache_chapters_');
  }

  // ---------------------------------------------------------------------------
  // Papers Caching (AI Generated JSON Papers & Saved PDF Papers, keyed by subjectId)
  // ---------------------------------------------------------------------------
  static String keyPapers(String subjectId) => 'cache_papers_$subjectId';

  Future<void> cachePapers(
    String subjectId,
    List<Map<String, dynamic>> papers,
  ) async {
    await _saveList(keyPapers(subjectId), papers);
  }

  Future<List<Map<String, dynamic>>?> getPapers(String subjectId) async {
    return _loadList(keyPapers(subjectId));
  }

  List<Map<String, dynamic>>? getPapersSync(String subjectId) {
    return _memoryCache[keyPapers(subjectId)];
  }

  Future<void> invalidatePapers(String subjectId) async {
    await _removeKey(keyPapers(subjectId));
  }

  Future<void> invalidateAllPapers() async {
    await _removeKeysStartingWith('cache_papers_');
  }

  // ---------------------------------------------------------------------------
  // Reference Papers Caching (Uploaded Reference PDFs, keyed by subjectId)
  // ---------------------------------------------------------------------------
  static String keyReferencePapers(String subjectId) =>
      'cache_ref_papers_$subjectId';

  Future<void> cacheReferencePapers(
    String subjectId,
    List<Map<String, dynamic>> papers,
  ) async {
    await _saveList(keyReferencePapers(subjectId), papers);
  }

  Future<List<Map<String, dynamic>>?> getReferencePapers(
    String subjectId,
  ) async {
    return _loadList(keyReferencePapers(subjectId));
  }

  List<Map<String, dynamic>>? getReferencePapersSync(String subjectId) {
    return _memoryCache[keyReferencePapers(subjectId)];
  }

  Future<void> invalidateReferencePapers(String subjectId) async {
    await _removeKey(keyReferencePapers(subjectId));
  }

  Future<void> invalidateAllReferencePapers() async {
    await _removeKeysStartingWith('cache_ref_papers_');
  }

  // ---------------------------------------------------------------------------
  // Single Paper Detail Caching (keyed by paperId, for editable JSON papers)
  // ---------------------------------------------------------------------------
  static String keyPaperDetail(String paperId) => 'cache_paper_detail_$paperId';

  Future<void> cachePaperDetail(
    String paperId,
    Map<String, dynamic> paper,
  ) async {
    await _saveMap(keyPaperDetail(paperId), paper);
  }

  Future<Map<String, dynamic>?> getPaperDetail(String paperId) {
    return _loadMap(keyPaperDetail(paperId));
  }

  Map<String, dynamic>? getPaperDetailSync(String paperId) {
    return _memoryMapCache[keyPaperDetail(paperId)];
  }

  Future<void> invalidatePaperDetail(String paperId) async {
    await _removeMapKey(keyPaperDetail(paperId));
  }

  // ---------------------------------------------------------------------------
  // Precise Paper Mutations Across All Types (JSON, Saved PDF, Reference PDF)
  // ---------------------------------------------------------------------------
  /// Updates a paper in all cached subject lists and detail cache
  /// (e.g. when an editable JSON paper is edited or saved to a PDF with pdf_url).
  Future<void> updatePaperInCaches(
    String paperId,
    Map<String, dynamic> updatedPaper,
  ) async {
    // 1. Update single detail cache
    await cachePaperDetail(paperId, updatedPaper);

    // 2. Update any subject paper list containing this paper
    final matchingKeys = _memoryCache.keys
        .where((k) => k.startsWith('cache_papers_'))
        .toList();

    for (final key in matchingKeys) {
      final list = _memoryCache[key];
      if (list != null) {
        final index = list.indexWhere((p) => p['id']?.toString() == paperId);
        if (index != -1) {
          list[index] = Map<String, dynamic>.from(updatedPaper);
          await _saveList(key, list);
        }
      }
    }
  }

  /// Removes an AI paper from all cached subject lists and detail cache
  Future<void> removePaperFromAllCaches(String paperId) async {
    await invalidatePaperDetail(paperId);

    try {
      final prefs = await SharedPreferences.getInstance();
      final diskKeys = prefs
          .getKeys()
          .where((k) => k.startsWith('cache_papers_'))
          .toList();
      for (final key in diskKeys) {
        if (!_memoryCache.containsKey(key)) {
          await _loadList(key);
        }
      }
    } catch (_) {}

    final matchingKeys = _memoryCache.keys
        .where((k) => k.startsWith('cache_papers_'))
        .toList();

    for (final key in matchingKeys) {
      final list = _memoryCache[key];
      if (list != null) {
        final initialLen = list.length;
        list.removeWhere((p) => p['id']?.toString() == paperId);
        if (list.length != initialLen) {
          await _saveList(key, list);
        }
      }
    }
  }

  /// Adds a newly generated paper to the subject's cached list
  Future<void> addCachedPaper(
    String subjectId,
    Map<String, dynamic> paper,
  ) async {
    final key = keyPapers(subjectId);
    final existingList = _memoryCache[key] ?? await getPapers(subjectId);
    final list = existingList != null
        ? List<Map<String, dynamic>>.from(existingList)
        : <Map<String, dynamic>>[];
    list.removeWhere((p) => p['id']?.toString() == paper['id']?.toString());
    list.insert(0, Map<String, dynamic>.from(paper));
    await cachePapers(subjectId, list);
    if (paper['id'] != null) {
      await cachePaperDetail(paper['id'].toString(), paper);
    }
  }

  /// Adds a newly uploaded reference paper to the subject's cached reference list
  Future<void> addCachedReferencePaper(
    String subjectId,
    Map<String, dynamic> refPaper,
  ) async {
    final key = keyReferencePapers(subjectId);
    final existingList =
        _memoryCache[key] ?? await getReferencePapers(subjectId);
    final list = existingList != null
        ? List<Map<String, dynamic>>.from(existingList)
        : <Map<String, dynamic>>[];
    list.removeWhere((p) => p['id']?.toString() == refPaper['id']?.toString());
    list.insert(0, Map<String, dynamic>.from(refPaper));
    await cacheReferencePapers(subjectId, list);
  }

  /// Removes a reference paper from all cached reference lists
  Future<void> removeReferencePaperFromAllCaches(String paperId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final diskKeys = prefs
          .getKeys()
          .where((k) => k.startsWith('cache_ref_papers_'))
          .toList();
      for (final key in diskKeys) {
        if (!_memoryCache.containsKey(key)) {
          await _loadList(key);
        }
      }
    } catch (_) {}

    final matchingKeys = _memoryCache.keys
        .where((k) => k.startsWith('cache_ref_papers_'))
        .toList();

    for (final key in matchingKeys) {
      final list = _memoryCache[key];
      if (list != null) {
        final initialLen = list.length;
        list.removeWhere((p) => p['id']?.toString() == paperId);
        if (list.length != initialLen) {
          await _saveList(key, list);
        }
      }
    }
  }

  // In-memory map cache for single paper detail
  final Map<String, Map<String, dynamic>> _memoryMapCache = {};

  Future<void> _saveMap(String key, Map<String, dynamic> map) async {
    _memoryMapCache[key] = Map<String, dynamic>.from(map);
    _cacheTimestamps[key] = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': map,
      });
      await prefs.setString(key, payload);
    } catch (e) {
      //       debugPrint('CacheService error saving map $key: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadMap(String key) async {
    if (_memoryMapCache.containsKey(key)) {
      return _memoryMapCache[key];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['data'] is Map) {
          final map = (decoded['data'] as Map).cast<String, dynamic>();
          _memoryMapCache[key] = map;
          if (decoded['timestamp'] is int) {
            _cacheTimestamps[key] = DateTime.fromMillisecondsSinceEpoch(
              decoded['timestamp'] as int,
            );
          }
          return map;
        }
      }
    } catch (e) {
      //       debugPrint('CacheService error loading map $key: $e');
    }
    return null;
  }

  Future<void> _removeMapKey(String key) async {
    _memoryMapCache.remove(key);
    _cacheTimestamps.remove(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      //       debugPrint('CacheService error removing map key $key: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Core Storage Helpers (Memory + SharedPreferences)
  // ---------------------------------------------------------------------------
  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async {
    // 1. Update in-memory cache
    _memoryCache[key] = List<Map<String, dynamic>>.from(list);
    _cacheTimestamps[key] = DateTime.now();

    // 2. Persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': list,
      });
      await prefs.setString(key, payload);
    } catch (e) {
      //       debugPrint('CacheService error saving $key: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> _loadList(String key) async {
    // 1. Check in-memory cache first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    // 2. Check persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['data'] is List) {
          final list = (decoded['data'] as List).cast<Map<String, dynamic>>();
          _memoryCache[key] = list;
          if (decoded['timestamp'] is int) {
            _cacheTimestamps[key] = DateTime.fromMillisecondsSinceEpoch(
              decoded['timestamp'] as int,
            );
          }
          return list;
        }
      }
    } catch (e) {
      //       debugPrint('CacheService error loading $key: $e');
    }
    return null;
  }

  Future<void> _removeKey(String key) async {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      //       debugPrint('CacheService error removing $key: $e');
    }
  }

  Future<void> _removeKeysStartingWith(String prefix) async {
    _memoryCache.removeWhere((k, _) => k.startsWith(prefix));
    _cacheTimestamps.removeWhere((k, _) => k.startsWith(prefix));
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (e) {
      //       debugPrint('CacheService error removing prefix $prefix: $e');
    }
  }

  /// Clear all cached data (e.g. on logout)
  Future<void> clearAll() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('cache_'))
          .toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (e) {
      //       debugPrint('CacheService error clearing all: $e');
    }
  }
}
