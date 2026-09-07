/// Shared state object passed through every wizard step.
/// Mutable by each step before navigation.
class PaperWizardState {
  String? bookId;
  List<String> selectedChapterIds = [];
  int totalMarks = 80;

  /// null = CUSTOM mode, non-null = REFERENCE mode
  String? referencePaperId;

  /// 'EASY' | 'MEDIUM' | 'HARD' | 'MIXED'
  String difficulty = 'MEDIUM';

  /// Difficulty percentages
  int easyPercentage = 25;
  int mediumPercentage = 50;
  int hardPercentage = 25;

  /// Built from the Format step (CUSTOM mode only)
  List<Map<String, dynamic>> questionConfigs = [];

  /// Academic level e.g. "Class 8", "Semester II"
  String className = '';

  /// Exam duration in minutes e.g. 180 for 3 hours
  int timeAllowedMinutes = 180;

  /// Numerical questions percentage settings
  bool enableNumericalPercentage = false;
  int numericalPercentage = 0;

  /// Chapter weightage settings
  bool enableChapterWeightage = false;
  Map<String, int> chapterWeightages = {};

  int get totalChapterWeightage {
    int sum = 0;
    for (final id in selectedChapterIds) {
      sum += chapterWeightages[id] ?? 0;
    }
    return sum;
  }

  /// Distribute 100% evenly across all currently selected chapters.
  void recalculateDefaultWeightages() {
    chapterWeightages.clear();
    if (selectedChapterIds.isEmpty) return;
    final int count = selectedChapterIds.length;
    final int base = 100 ~/ count;
    final int remainder = 100 % count;
    for (int i = 0; i < count; i++) {
      chapterWeightages[selectedChapterIds[i]] = base + (i < remainder ? 1 : 0);
    }
  }

  /// Dynamically adjust one chapter's percentage and proportionally adapt
  /// the remaining selected chapters so the total always strictly equals 100%.
  void updateChapterWeightage(String changedChapterId, int newWeight) {
    newWeight = newWeight.clamp(0, 100);
    if (!selectedChapterIds.contains(changedChapterId)) return;

    if (selectedChapterIds.length == 1) {
      chapterWeightages[changedChapterId] = 100;
      return;
    }

    final otherIds = selectedChapterIds.where((id) => id != changedChapterId).toList();
    final int remaining = 100 - newWeight;

    // Sum of other chapters' current weightages
    int sumOthers = 0;
    for (final id in otherIds) {
      sumOthers += chapterWeightages[id] ?? 0;
    }

    chapterWeightages[changedChapterId] = newWeight;

    if (sumOthers > 0) {
      int allocated = 0;
      final Map<String, double> exactValues = {};
      for (final id in otherIds) {
        final currentVal = chapterWeightages[id] ?? 0;
        final double exact = remaining * (currentVal / sumOthers);
        exactValues[id] = exact;
        final int floored = exact.floor();
        chapterWeightages[id] = floored;
        allocated += floored;
      }

      int diff = remaining - allocated;
      final sortedByFraction = List<String>.from(otherIds)
        ..sort((a, b) {
          final fracA = exactValues[a]! - (chapterWeightages[a] ?? 0);
          final fracB = exactValues[b]! - (chapterWeightages[b] ?? 0);
          return fracB.compareTo(fracA);
        });

      for (int i = 0; i < diff && i < sortedByFraction.length; i++) {
        chapterWeightages[sortedByFraction[i]] = (chapterWeightages[sortedByFraction[i]] ?? 0) + 1;
      }
    } else {
      final int base = remaining ~/ otherIds.length;
      final int rem = remaining % otherIds.length;
      for (int i = 0; i < otherIds.length; i++) {
        chapterWeightages[otherIds[i]] = base + (i < rem ? 1 : 0);
      }
    }
  }

  bool get isReferenceMode => referencePaperId != null;

  String get generationMode => isReferenceMode ? 'REFERENCE' : 'CUSTOM';
}

