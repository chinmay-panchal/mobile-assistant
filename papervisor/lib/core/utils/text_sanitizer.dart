/// Utility class to sanitize text strings, fix control character corruptions (\u0002, \u0005, etc.),
/// and convert raw LaTeX math ($...$) into clean, readable Unicode text.
class TextSanitizer {
  /// Sanitizes text by replacing control characters and corrupted symbols.
  /// 
  /// Fixes:
  /// - `\u0002` -> `°` (Degree symbol e.g., 60°C, 30°)
  /// - `\u0005` -> `µ` (Micro symbol e.g., 15.0 µF, 10 µC)
  /// - `̉` (U+0309 combining hook) -> `Ω` (Ohm symbol e.g., 200 Ω, 484 Ω)
  /// - Removes non-printable ASCII/Unicode control characters that trigger cross-box [X] glyph errors.
  static String sanitizeText(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // 1. Fix common corrupted symbol control codes from API/PDF text generators
    result = result.replaceAll('\u0002', '°'); // U+0002 -> Degree symbol °
    result = result.replaceAll('\u0005', 'µ'); // U+0005 -> Micro symbol µ
    result = result.replaceAll('̉', ' Ω');       // U+0309 -> Ohm symbol Ω

    // 2. Remove any remaining non-printable control characters (U+0000 - U+001F, except \n, \r, \t)
    result = result.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'), '');

    return result;
  }

  /// Converts LaTeX math expressions (enclosed in $...$ or $$...$$) and LaTeX symbols
  /// into clean, readable Unicode text for display and PDF rendering.
  static String cleanLaTeX(String input) {
    if (input.isEmpty) return input;

    // First sanitize any control characters
    String text = sanitizeText(input);

    // 1. Handle common LaTeX fractions: \frac{a}{b} -> (a / b)
    text = text.replaceAllMapped(
      RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'),
      (match) => '(${match.group(1)} / ${match.group(2)})',
    );

    // 2. Handle vector unit vectors and bold symbols
    text = text.replaceAll(r'\mathbf{\hat{i}}', 'î');
    text = text.replaceAll(r'\mathbf{\hat{j}}', 'ĵ');
    text = text.replaceAll(r'\mathbf{\hat{k}}', 'k̂');
    text = text.replaceAll(r'\hat{i}', 'î');
    text = text.replaceAll(r'\hat{j}', 'ĵ');
    text = text.replaceAll(r'\hat{k}', 'k̂');
    text = text.replaceAllMapped(
      RegExp(r'\\mathbf\{([^{}]+)\}'),
      (match) => match.group(1) ?? '',
    );

    // 3. Convert Greek letters & math symbols
    text = text.replaceAll(r'\lambda', 'λ');
    text = text.replaceAll(r'\sigma', 'σ');
    text = text.replaceAll(r'\varepsilon_0', 'ε₀');
    text = text.replaceAll(r'\epsilon_0', 'ε₀');
    text = text.replaceAll(r'\varepsilon', 'ε');
    text = text.replaceAll(r'\epsilon', 'ε');
    text = text.replaceAll(r'\pi', 'π');
    text = text.replaceAll(r'\theta', 'θ');
    text = text.replaceAll(r'\phi', 'ϕ');
    text = text.replaceAll(r'\omega', 'ω');
    text = text.replaceAll(r'\Omega', 'Ω');
    text = text.replaceAll(r'\mu', 'µ');
    text = text.replaceAll(r'\Delta', 'Δ');
    text = text.replaceAll(r'\delta', 'δ');
    text = text.replaceAll(r'\alpha', 'α');
    text = text.replaceAll(r'\beta', 'β');
    text = text.replaceAll(r'\gamma', 'γ');
    text = text.replaceAll(r'\times', '×');
    text = text.replaceAll(r'\cdot', '·');
    text = text.replaceAll(r'\pm', '±');
    text = text.replaceAll(r'\infty', '∞');
    text = text.replaceAll(r'\ln', 'ln');

    // 4. Remove LaTeX inline math delimiters: $...$ -> content
    // Double dollars $$...$$
    text = text.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$'),
      (match) => match.group(1) ?? '',
    );
    // Single dollars $...$
    text = text.replaceAllMapped(
      RegExp(r'\$(.*?)\$'),
      (match) => match.group(1) ?? '',
    );

    return text.trim();
  }
}
