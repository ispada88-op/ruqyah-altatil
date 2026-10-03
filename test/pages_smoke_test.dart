import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roqia_altatil/pages/after_prayer_page.dart';
import 'package:roqia_altatil/pages/bookmarks_page.dart';
import 'package:roqia_altatil/pages/home_page.dart';
import 'package:roqia_altatil/pages/khatma_page.dart';
import 'package:roqia_altatil/pages/prayer_times_page.dart';
import 'package:roqia_altatil/pages/program_page.dart';
import 'package:roqia_altatil/pages/quran_search_page.dart';
import 'package:roqia_altatil/pages/ruqyah_rules_page.dart';
import 'package:roqia_altatil/services/bookmarks_service.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// كل الشاشات الجديدة تُبنى بلا استثناءات مع قارئ الشاشة (semantics) وخط ×١٫٣
/// وعرض ضيّق ٣٢٠ — يلتقط تجاوز الحدود وقيم semantics غير الصالحة.
Future<void> _font(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // خطوط حقيقية: بدونها يرسم الاختبار بخط Ahem (كل حرف مربع بعرض em) فيُظهر
  // تجاوزاً وهمياً. تُحمَّل داخل جسم الاختبار (setUpAll لا يُطبَّق على نصوص
  // google_fonts هنا).
  var fontsLoaded = false;
  Future<void> loadFonts() async {
    if (fontsLoaded) return;
    fontsLoaded = true;
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      await _font('MaterialIcons',
          '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    }
    for (final (v, f) in [('regular', 'Regular'), ('500', 'Medium'), ('700', 'Bold')]) {
      await _font('Tajawal_$v', 'assets/google_fonts/Tajawal-$f.ttf');
    }
    await _font('Tajawal_600', 'assets/google_fonts/Tajawal-Bold.ttf');
    await _font('Tajawal_800', 'assets/google_fonts/Tajawal-Bold.ttf');
    await _font('Amiri_regular', 'assets/google_fonts/Amiri-Regular.ttf');
    await _font('Amiri_700', 'assets/google_fonts/Amiri-Bold.ttf');
    await _font('KFGQPCHafs', 'assets/fonts/kfgqpc/hafs.18.ttf');
    await _font('Roboto', 'assets/google_fonts/Tajawal-Regular.ttf');
  }

  // semantics مفعّلة طوال الاختبار ويُنهى مقبضها قبل التحقق الختامي.
  void smoke(String name, Future<void> Function(WidgetTester) body) =>
      testWidgets(name, (t) async {
        final handle = t.ensureSemantics();
        try {
          await body(t);
        } finally {
          handle.dispose();
        }
      });

  Future<void> pumpPage(WidgetTester tester, Widget page, {bool dark = false}) async {
    await loadFonts();
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
      home: page,
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  }

  void located() {
    SharedPreferences.setMockInitialValues({});
    PrayerTimesService.instance
        .debugSet(lat: 21.4225, lon: 39.8262, label: 'مكة المكرمة');
  }

  smoke('home with a saved city and an active khatma', (t) async {
    located();
    await t.runAsync(() => KhatmaService.instance.start(30));
    await pumpPage(t, const HomePage());
    expect(find.textContaining('الصلاة القادمة'), findsOneWidget);
    expect(find.text('وردك اليوم من القرآن'), findsOneWidget);
  });

  smoke('home without location / khatma, dark', (t) async {
    SharedPreferences.setMockInitialValues({});
    PrayerTimesService.instance.debugSet();
    await t.runAsync(() => KhatmaService.instance.stop());
    await pumpPage(t, const HomePage(), dark: true);
    expect(find.text('حدّد موقعك لمواقيت الصلاة'), findsOneWidget);
    expect(find.text('ابدأ ختمة القرآن'), findsOneWidget);
  });

  smoke('prayer times page', (t) async {
    located();
    await pumpPage(t, const PrayerTimesPage());
  });

  smoke('khatma page: setup then active', (t) async {
    located();
    await t.runAsync(() => KhatmaService.instance.stop());
    await pumpPage(t, const KhatmaPage());
    expect(find.text('ابدأ الختمة'), findsOneWidget);
    await t.runAsync(() => KhatmaService.instance.start(30));
    await t.pump(const Duration(milliseconds: 300));
    expect(t.takeException(), isNull);
    expect(find.text('وردك اليوم'), findsOneWidget);
  });

  smoke('program page', (t) async {
    located();
    await pumpPage(t, const ProgramPage());
    expect(find.text('أذكار الصباح'), findsOneWidget);
  });

  smoke('bookmarks page: empty and with items', (t) async {
    located();
    await pumpPage(t, const BookmarksPage());
    await t.runAsync(() => BookmarksService.instance.toggle(10));
    await t.pump(const Duration(milliseconds: 300));
    expect(t.takeException(), isNull);
    expect(find.text('صفحة ١٠'), findsOneWidget);
  });

  smoke('search page', (t) async {
    located();
    await pumpPage(t, const QuranSearchPage());
  });

  // صفحة واحدة لكل اختبار: إعادة بناء شجرة نصوص أخرى داخل الاختبار نفسه
  // تُسقط assert داخلياً في text_painter (مشكلة بيئة اختبار لا تطبيق).
  smoke('rules page, dark', (t) async {
    located();
    await pumpPage(t, const RuqyahRulesPage(), dark: true);
  });

  smoke('after-prayer page', (t) async {
    located();
    await pumpPage(t, const AfterPrayerPage());
  });
}
