import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../utils/svg_sanitizer.dart';

class SvgDiagramViewer extends StatelessWidget {
  final String? rawSvg;
  final String? title;
  final String? caption;
  final double maxHeight;
  final bool enableZoomOnTap;

  const SvgDiagramViewer({
    super.key,
    required this.rawSvg,
    this.title,
    this.caption,
    this.maxHeight = 220,
    this.enableZoomOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final cleaned = SvgSanitizer.cleanSvg(rawSvg);
    if (cleaned == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header bar with badge and optional title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.primaryLight.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.hub_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    title?.isNotEmpty == true ? title! : 'Diagram',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (enableZoomOnTap)
                    GestureDetector(
                      onTap: () => _openFullscreen(context, cleaned, title),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Zoom',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // SVG Content
            InkWell(
              onTap: enableZoomOnTap ? () => _openFullscreen(context, cleaned, title) : null,
              child: Container(
                constraints: BoxConstraints(maxHeight: maxHeight),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: SvgPicture.string(
                  cleaned,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_outlined, color: Colors.orange, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          'Unable to render diagram',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Optional Caption
            if (caption != null && caption!.trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                alignment: Alignment.center,
                child: Text(
                  caption!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String svgCode, String? diagramTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              diagramTitle?.isNotEmpty == true ? diagramTitle! : 'Diagram Preview',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          body: SafeArea(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(32),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SvgPicture.string(
                    svgCode,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
