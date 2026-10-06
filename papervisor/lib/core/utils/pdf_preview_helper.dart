import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/theme/auth_theme.dart';
import '../../features/paper_creation/screens/saved_pdf_viewer_screen.dart';
import '../../services/api_client.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper to download and preview remote PDFs in-app using [SavedPdfViewerScreen].
class PdfPreviewHelper {
  static String get defaultHost =>
      dotenv.env['HOST_URL'] ?? 'http://192.168.1.71:8000';

  /// Resolves the URL, displays a loading spinner, fetches binary bytes with auth,
  /// and pushes [SavedPdfViewerScreen] on success.
  static Future<void> openRemotePdf(
    BuildContext context, {
    required String urlPath,
    required String title,
  }) async {
    if (urlPath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No PDF available to preview.'),
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          color: AuthTheme.textPrimary,
          strokeWidth: 2.5,
        ),
      ),
    );

    try {
      final ApiClient apiClient = ApiClient();
      final token = await apiClient.getAccessToken();

      final String fullUrl = urlPath.startsWith('http')
          ? urlPath
          : '$defaultHost$urlPath';

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bytes = response.bodyBytes;
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedPdfViewerScreen(pdfBytes: bytes, title: title),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AuthTheme.error,
            content: Text(
              'Failed to load PDF (${response.statusCode})',
              style: const TextStyle(fontFamily: AuthTheme.fontFamily),
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AuthTheme.error,
          content: Text(
            'Error opening PDF preview: $e',
            style: const TextStyle(fontFamily: AuthTheme.fontFamily),
          ),
        ),
      );
    }
  }
}
