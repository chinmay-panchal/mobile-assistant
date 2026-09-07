class SvgSanitizer {
  /// Cleans and sanitizes raw SVG code:
  /// - Strips markdown code blocks (```xml, ```svg, ```)
  /// - Extracts the `<svg ... </svg>` block if surrounding text exists
  /// - Ensures standard xmlns attribute is present
  static String? cleanSvg(String? rawSvg) {
    if (rawSvg == null) return null;
    String svg = rawSvg.trim();
    if (svg.isEmpty) return null;

    // Strip markdown code fences if present
    if (svg.startsWith('```')) {
      // Remove opening ```xml or ```svg or ```
      final firstNewline = svg.indexOf('\n');
      if (firstNewline != -1) {
        svg = svg.substring(firstNewline + 1);
      } else {
        svg = svg.replaceAll(RegExp(r'^```[a-zA-Z]*'), '');
      }
      // Remove closing ```
      svg = svg.replaceAll(RegExp(r'```$'), '').trim();
    }

    // Locate <svg and </svg> tags
    final lower = svg.toLowerCase();
    final svgStart = lower.indexOf('<svg');
    final svgEnd = lower.lastIndexOf('</svg>');

    if (svgStart == -1 || svgEnd == -1 || svgEnd <= svgStart) {
      // Not a valid SVG fragment
      return null;
    }

    svg = svg.substring(svgStart, svgEnd + 6).trim();

    // Ensure xmlns is present on <svg ...>
    final firstTagEnd = svg.indexOf('>');
    if (firstTagEnd != -1) {
      final openingTag = svg.substring(0, firstTagEnd);
      if (!openingTag.contains('xmlns')) {
        svg = '<svg xmlns="http://www.w3.org/2000/svg"${svg.substring(4)}';
      }
    }

    return svg;
  }

  /// Returns true if the string appears to be valid SVG code.
  static bool hasValidSvg(String? rawSvg) {
    return cleanSvg(rawSvg) != null;
  }
}
