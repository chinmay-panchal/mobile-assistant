import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A single past PDF download entry persisted to local storage.
class DownloadedPdf {
  final String title;
  final String sourceUrl;
  final String localPath;
  final DateTime downloadedAt;

  const DownloadedPdf({
    required this.title,
    required this.sourceUrl,
    required this.localPath,
    required this.downloadedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'sourceUrl': sourceUrl,
        'localPath': localPath,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory DownloadedPdf.fromJson(Map<String, dynamic> json) => DownloadedPdf(
        title: json['title'] as String,
        sourceUrl: json['sourceUrl'] as String,
        localPath: json['localPath'] as String,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      );
}

/// Persists and retrieves past PDF downloads using [SharedPreferences].
class PastDownloadsRepository {
  static const _key = 'explore_past_downloads';

  /// Loads all past downloads from persistent storage, newest-first.
  Future<List<DownloadedPdf>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DownloadedPdf.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Prepends [entry] to the stored list and persists it.
  Future<void> add(DownloadedPdf entry) async {
    final existing = await loadAll();
    final updated = [entry, ...existing];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  /// Removes the entry matching [localPath] and persists the remaining list.
  Future<void> remove(String localPath) async {
    final existing = await loadAll();
    final updated = existing.where((e) => e.localPath != localPath).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  /// Clears all stored entries.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
