import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roqia_altatil/theme.dart';

/// خلفية الـAppBar شفافة، فلو تُرك أسلوب شريط النظام للحساب التلقائي لعدّها
/// Flutter داكنة ورسم الساعة والبطارية بيضاء فوق الخلفية الكريمية (غير مقروءة).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('light theme: dark status-bar and navigation icons', () {
    final s = lightTheme.appBarTheme.systemOverlayStyle;
    expect(s, isNotNull);
    expect(s!.statusBarIconBrightness, Brightness.dark);
    expect(s.systemNavigationBarIconBrightness, Brightness.dark);
    expect(s.statusBarColor, Colors.transparent);
  });

  test('dark theme: light status-bar and navigation icons', () {
    final s = darkTheme.appBarTheme.systemOverlayStyle;
    expect(s, isNotNull);
    expect(s!.statusBarIconBrightness, Brightness.light);
    expect(s.systemNavigationBarIconBrightness, Brightness.light);
  });
}
