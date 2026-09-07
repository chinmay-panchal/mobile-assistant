import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/utils/text_sanitizer.dart';
import '../core/utils/svg_sanitizer.dart';
import '../features/paper_creation/models/custom_element.dart';

class PdfExportService {
  static pw.Font? _baseFont;
  static pw.Font? _boldFont;
  static pw.Font? _italicFont;
  static pw.Font? _boldItalicFont;
  static List<pw.Font>? _fallbackFonts;

  static Future<pw.ThemeData> _loadTheme() async {
    if (_baseFont != null && _boldFont != null) {
      return pw.ThemeData.withFont(
        base: _baseFont!,
        bold: _boldFont!,
        italic: _italicFont,
        boldItalic: _boldItalicFont,
        fontFallback: _fallbackFonts ?? [],
      );
    }

    try {
      final results = await Future.wait([
        PdfGoogleFonts.notoSansRegular(),
        PdfGoogleFonts.notoSansBold(),
        PdfGoogleFonts.notoSansItalic(),
        PdfGoogleFonts.notoSansBoldItalic(),
        PdfGoogleFonts.notoSansMathRegular(),
        PdfGoogleFonts.notoSansSymbolsRegular(),
        PdfGoogleFonts.notoSansSymbols2Regular(),
      ]);

      _baseFont = results[0];
      _boldFont = results[1];
      _italicFont = results[2];
      _boldItalicFont = results[3];
      _fallbackFonts = [results[4], results[5], results[6]];

      return pw.ThemeData.withFont(
        base: _baseFont!,
        bold: _boldFont!,
        italic: _italicFont,
        boldItalic: _boldItalicFont,
        fontFallback: _fallbackFonts!,
      );
    } catch (e) {
      print('[PdfExportService] Warning: Failed to load Google Fonts ($e). Falling back to base theme.');
      return pw.ThemeData.base();
    }
  }

  static Future<Uint8List> generatePaperPdf(
    PdfPageFormat format,
    Map<String, dynamic> subject,
    Map<String, dynamic> paper, {
    Uint8List? logoBytes,
    String? className,
    int? timeAllowedMinutes,
    List<CustomElement>? customElements,
  }) async {
    final theme = await _loadTheme();
    final pdf = pw.Document(theme: theme);

    final String subjectName = subject['name'] ?? 'Subject';
    final String title = paper['title'] ?? 'Generated Paper';
    final int marks = paper['total_marks'] ?? 0;
    final List<dynamic> questions = paper['questions'] ?? [];

    String _convertToRoman(String input) {
      const romanNumerals = {
        1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V',
        6: 'VI', 7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X',
        11: 'XI', 12: 'XII'
      };
      return input.replaceAllMapped(RegExp(r'\b(\d+)\b'), (match) {
        int? num = int.tryParse(match.group(1) ?? '');
        if (num != null && romanNumerals.containsKey(num)) {
          return romanNumerals[num]!;
        }
        return match.group(0)!;
      });
    }

    final String rawClass = (className?.isNotEmpty == true
        ? className!
        : (paper['class_name'] as String? ?? ''));
    final String resolvedClass = _convertToRoman(rawClass);
    final int resolvedMinutes = timeAllowedMinutes ??
        (paper['time_allowed_minutes'] as int? ?? 0);

    // Convert minutes → display string e.g. "3 Hours" or "1 Hr 30 Min"
    String formatDuration(int minutes) {
      if (minutes <= 0) return '';
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (h == 0) return '$m Min';
      if (m == 0) return h == 1 ? '1 Hour' : '$h Hours';
      return '$h Hr $m Min';
    }

    final String durationStr = formatDuration(resolvedMinutes);

    // Group questions by section
    final Map<String, List<dynamic>> sections = {};
    for (final q in questions) {
      final sectionName = q['section_name'] ?? 'General';
      sections.putIfAbsent(sectionName, () => []).add(q);
    }

    // Pre-rasterize question SVGs to PNG bytes for 100% reliable PDF rendering (avoids Helvetica Unicode/Latin1 errors)
    final Map<dynamic, Uint8List> rasterizedSvgs = {};
    for (final q in questions) {
      final rawSvg = q['visual_svg']?.toString();
      final cleanedSvg = SvgSanitizer.cleanSvg(rawSvg);
      if (cleanedSvg != null) {
        final pngBytes = await _rasterizeSvgToPng(cleanedSvg);
        if (pngBytes != null) {
          rasterizedSvgs[q] = pngBytes;
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (pw.Context context) {
            if (customElements == null || customElements.isEmpty) {
              return pw.SizedBox.shrink();
            }
            // Filter elements belonging to this specific page (context.pageNumber is 1-indexed)
            final pageElements = customElements.where((e) => e.pageIndex == context.pageNumber - 1).toList();
            if (pageElements.isEmpty) return pw.SizedBox.shrink();
            
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: pageElements.map((el) {
                  return pw.Positioned(
                    left: el.relativeX * format.width,
                    top: el.relativeY * format.height,
                    child: _buildPdfCustomElement(el),
                  );
                }).toList(),
              ),
            );
          },
        ),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              '${context.pageNumber}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> content = [];

          // Decode logo image if provided
          pw.MemoryImage? logoImage;
          if (logoBytes != null) {
            logoImage = pw.MemoryImage(logoBytes);
          }

          // ── Header block (Vedantu style) ──
          content.add(
            pw.Stack(
              children: [
                // Centered title / subject / class column
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Breathing room so text doesn't collide with logo
                    if (logoImage != null) pw.SizedBox(height: 8),
                    // Paper title (bold, largest)
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 6),
                    // Subject name
                    pw.Text(
                      subjectName,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    // Class / Semester (only if provided)
                    if (resolvedClass.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        resolvedClass,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                    pw.SizedBox(height: 14),
                    // Time Allowed — left | Max. Marks — right
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          durationStr.isNotEmpty
                              ? 'Time allowed: $durationStr'
                              : '',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Max. Marks: $marks',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 14),
                  ],
                ),
                // Logo — pinned to top-right corner
                if (logoImage != null)
                  pw.Positioned(
                    top: 0,
                    right: 0,
                    child: pw.Image(
                      logoImage,
                      width: 120,
                      height: 60,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
              ],
            ),
          );

          // Sections
          sections.forEach((sectionName, sectionQuestions) {
            content.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
                child: pw.Text(
                  sectionName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            int displayQuestionNumber = 0;
            String? currentChoiceGroup;

            for (var i = 0; i < sectionQuestions.length; i++) {
              final q = sectionQuestions[i];
              final qText = TextSanitizer.cleanLaTeX((q['question_text'] ?? 'No text provided').toString());
              final qMarks = q['marks'] ?? 1;
              final List<dynamic> options = q['mcq_options'] ?? q['options'] ?? [];
              final String? altLabel = q['alternative_label'];
              final String? choiceGroup = q['choice_group'];

              bool isNewQuestion = false;

              if (choiceGroup == null) {
                // Standalone question
                isNewQuestion = true;
                currentChoiceGroup = null;
              } else if (choiceGroup != currentChoiceGroup) {
                // First of a new choice group
                isNewQuestion = true;
                currentChoiceGroup = choiceGroup;
              }

              if (isNewQuestion) {
                displayQuestionNumber++;
              } else {
                content.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Center(
                      child: pw.Text('OR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                );
              }

              final String questionPrefix = (choiceGroup != null && altLabel != null) 
                  ? '$displayQuestionNumber$altLabel.' 
                  : '$displayQuestionNumber.';

              content.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('$questionPrefix ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Expanded(
                            child: pw.Text(qText),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text('[$qMarks]'),
                        ],
                      ),
                      _buildPdfSvg(
                        pngBytes: rasterizedSvgs[q],
                        rawSvg: q['visual_svg']?.toString(),
                        title: q['visual_title']?.toString(),
                        caption: q['visual_caption']?.toString(),
                      ),
                      if (options.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 16),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: options.map((opt) {
                              final sanitizedOpt = TextSanitizer.cleanLaTeX(opt.toString());
                              return pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 4),
                                child: pw.Text('- $sanitizedOpt'),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
          });

          return content;
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfCustomElement(CustomElement el) {
    if (el.type == CustomElementType.text && el.text != null) {
      return pw.Text(
        el.text!,
        style: pw.TextStyle(
          fontSize: el.fontSize * el.scale,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      );
    } else if (el.type == CustomElementType.image && el.imageBytes != null) {
      return pw.Image(
        pw.MemoryImage(el.imageBytes!),
        width: 120 * el.scale, // apply the scale factor
        fit: pw.BoxFit.contain,
      );
    }
    return pw.SizedBox.shrink();
  }

  static pw.Widget _buildPdfSvg({
    Uint8List? pngBytes,
    String? rawSvg,
    String? title,
    String? caption,
  }) {
    pw.Widget? diagramWidget;

    if (pngBytes != null) {
      diagramWidget = pw.ConstrainedBox(
        constraints: const pw.BoxConstraints(maxHeight: 180, maxWidth: 320),
        child: pw.Image(
          pw.MemoryImage(pngBytes),
          fit: pw.BoxFit.contain,
        ),
      );
    } else {
      final cleaned = SvgSanitizer.cleanSvg(rawSvg);
      if (cleaned == null) return pw.SizedBox.shrink();

      try {
        diagramWidget = pw.ConstrainedBox(
          constraints: const pw.BoxConstraints(maxHeight: 180, maxWidth: 300),
          child: pw.SvgImage(
            svg: cleaned,
            fit: pw.BoxFit.contain,
            customFontLookup: (fontFamily, fontStyle, fontWeight) => _baseFont,
          ),
        );
      } catch (e) {
        return pw.SizedBox.shrink();
      }
    }

    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (title != null && title.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                title.trim(),
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
              ),
            ),
          diagramWidget,
          if (caption != null && caption.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                caption.trim(),
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ),
        ],
      ),
    );
  }

  static Future<Uint8List?> _rasterizeSvgToPng(String svgString) async {
    try {
      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      double srcWidth = pictureInfo.size.width;
      double srcHeight = pictureInfo.size.height;

      if (srcWidth <= 0 || srcHeight <= 0) {
        srcWidth = 400;
        srcHeight = 250;
      }

      // High-resolution scale for sharp print output
      const double targetWidth = 900.0;
      final double scale = (targetWidth / srcWidth).clamp(1.0, 4.0);
      final int renderWidth = (srcWidth * scale).round();
      final int renderHeight = (srcHeight * scale).round();

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      // Clean white background for print clarity
      final ui.Paint bgPaint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, renderWidth.toDouble(), renderHeight.toDouble()),
        bgPaint,
      );

      canvas.scale(scale, scale);
      canvas.drawPicture(pictureInfo.picture);
      pictureInfo.picture.dispose();

      final ui.Picture rasterPicture = recorder.endRecording();
      final ui.Image image = await rasterPicture.toImage(renderWidth, renderHeight);
      rasterPicture.dispose();

      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('[PdfExportService] Warning: SVG rasterization failed ($e). Falling back to vector SvgImage.');
      return null;
    }
  }
}

