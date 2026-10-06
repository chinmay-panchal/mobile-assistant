/// A single search result item.
class PdfSearchResult {
  final String title;
  final String url;

  const PdfSearchResult({required this.title, required this.url});
}

/// Standalone PDF search helper (external search disabled).
class PdfSearchService {
  Future<List<PdfSearchResult>> search(
    String prompt, {
    bool isExpanded = false,
    int maxResults = 25,
  }) async {
    return [];
  }
}
