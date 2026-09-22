import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Card showing the status of the uploaded whole book PDF or providing a clean upload affordance.
class BookPdfCard extends StatelessWidget {
  final Map<String, dynamic>? document;
  final VoidCallback? onPreview;
  final VoidCallback? onUpload;

  const BookPdfCard({
    super.key,
    this.document,
    this.onPreview,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (document != null) {
      return _buildUploadedDocumentCard(context, document!);
    } else {
      return _buildUploadPromptCard(context);
    }
  }

  Widget _buildUploadedDocumentCard(BuildContext context, Map<String, dynamic> doc) {
    final status = (doc['status'] ?? '').toString().toUpperCase();
    final isReady = status == 'READY';
    final isProcessing = status == 'PROCESSING' || status == 'UPLOADED' || status == 'EMBEDDING';
    final isFailed = status == 'FAILED';

    Color statusColor;
    Color statusBgColor;
    String statusLabel;

    if (isReady) {
      statusColor = const Color(0xFF059669);
      statusBgColor = const Color(0xFFECFDF5);
      statusLabel = 'Ready to read';
    } else if (status == 'UPLOADED') {
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFFFBEB);
      statusLabel = 'Uploading…';
    } else if (status == 'PROCESSING') {
      statusColor = const Color(0xFF4F46E5);
      statusBgColor = const Color(0xFFEEF2FF);
      statusLabel = 'Extracting pages…';
    } else if (status == 'EMBEDDING') {
      statusColor = const Color(0xFF0284C7);
      statusBgColor = const Color(0xFFF0F9FF);
      statusLabel = 'Indexing content…';
    } else if (isFailed) {
      statusColor = const Color(0xFFDC2626);
      statusBgColor = const Color(0xFFFEF2F2);
      statusLabel = 'Processing failed';
    } else {
      statusColor = const Color(0xFF64748B);
      statusBgColor = const Color(0xFFF1F5F9);
      statusLabel = 'Processing…';
    }

    double progress = 0.0;
    if (status == 'UPLOADED') progress = 0.25;
    if (status == 'PROCESSING') progress = 0.50;
    if (status == 'EMBEDDING') progress = 0.75;
    if (status == 'READY') progress = 1.0;

    final fileName = (doc['filename'] ?? 'Book PDF').toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isReady ? onPreview : null,
        borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
            border: Border.all(
              color: isReady ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // PDF Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // File Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AuthTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isProcessing) ...[
                                    SizedBox(
                                      width: 8,
                                      height: 8,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          statusColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ] else if (isReady) ...[
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 10,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Open Arrow / Action
                  if (isReady) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AuthTheme.primary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AuthTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Processing progress bar
              if (isProcessing && progress > 0.0 && progress < 1.0) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 0.75 ? AuthTheme.primary : const Color(0xFFF59E0B),
                    ),
                    minHeight: 5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPromptCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onUpload,
        borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Whole Book PDF',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AuthTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enables page range auto-fill across chapters',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AuthTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AuthTheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
