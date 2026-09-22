import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../repositories/past_downloads_repository.dart';

/// Card displayed when a PYQ PDF has been downloaded successfully or is ready to view.
class ExploreResultCard extends StatelessWidget {
  final DownloadedPdf pdf;
  final VoidCallback onOpenPdf;
  final VoidCallback onDismiss;

  const ExploreResultCard({
    super.key,
    required this.pdf,
    required this.onOpenPdf,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AuthTheme.radiusField),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PYQ PDF Ready',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF065F46),
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onDismiss,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: Color(0xFF065F46),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // PDF Icon Squircle
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AuthTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AuthTheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Source
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdf.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Downloaded and verified • Ready to view',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AuthTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Open Button
                Container(
                  decoration: BoxDecoration(
                    gradient: AuthTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                    boxShadow: AuthTheme.buttonShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                      onTap: onOpenPdf,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Open',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
