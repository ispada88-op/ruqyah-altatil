import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// google_fonts only uses a bundled file when its name is exactly
/// `<FamilyWithoutSpaces>-<Variant>.ttf`; a typo silently falls back to a
/// network download (and to a system font when offline). Lock the names in.
void main() {
  const expected = [
    'Tajawal-Regular.ttf',
    'Tajawal-Medium.ttf',
    'Tajawal-Bold.ttf',
    'Amiri-Regular.ttf',
    'Amiri-Bold.ttf',
    'NotoNaskhArabic-Regular.ttf',
    'OFL-Tajawal.txt',
    'OFL-Amiri.txt',
    'OFL-NotoNaskhArabic.txt',
  ];

  test('bundled font files exist with google_fonts naming', () {
    for (final name in expected) {
      final f = File('assets/google_fonts/$name');
      expect(f.existsSync(), isTrue, reason: name);
      expect(f.lengthSync(), greaterThan(1000), reason: name);
    }
  });

  test('assets/google_fonts/ is declared in pubspec.yaml', () {
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('- assets/google_fonts/'));
  });
}
