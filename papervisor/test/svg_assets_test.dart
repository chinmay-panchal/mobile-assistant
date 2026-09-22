import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  test('Empty subjects SVG parses validly with flutter_svg loader', () async {
    final illustrations = [
      'assets/subjects/illustrations/empty_subjects.svg',
      'assets/workspace/illustrations/empty_workspaces.svg',
      'assets/workspace/illustrations/pyq_banner.svg',
      'assets/subject_detail/illustrations/empty_papers.svg',
      'assets/auth/illustrations/signup_illustration.svg',
      'assets/auth/illustrations/login_illustration.svg',
      'assets/auth/illustrations/reset_password_illustration.svg',
    ];

    for (final path in illustrations) {
      final file = File(path);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final loader = SvgStringLoader(content);
        final bytes = await loader.loadBytes(null);
        expect(bytes, isNotNull, reason: 'Failed for $path');
      }
    }
  });
}
