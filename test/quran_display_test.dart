import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/verified_quran.dart';
import 'package:roqia_altatil/data/written_roqia_data.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:roqia_altatil/pages/mushaf_pages.dart';
import 'package:roqia_altatil/pages/written_roqia_page.dart';
import 'package:roqia_altatil/services/quran_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quran text must reach the screen exactly as in the verified source.
///
/// Until 1.0.6 a display "simplifier" deleted U+06D6–U+06ED. Besides pause
/// signs that range holds marks that change the recitation: small waw/yeh
/// (long vowels, e.g. «إِبْرَٰهِـۧمَ»), the pronounced small noon of «نُـۨجِى»,
/// iqlab meem, the four Hafs saktah signs, imalah/ishmam/tas-hil. These tests
/// pin the verbatim rendering.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(Widget child) => MaterialApp(
        home: Directionality(textDirection: TextDirection.rtl, child: child),
      );

  void tallView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 20000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String marker(int n) =>
      '﴿${n.toString().split('').map((d) => digits[int.parse(d)]).join()}﴾';

  testWidgets('Mushaf reader shows every ayah verbatim (Al-Anbiya)',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tallView(tester);
    final verses = (await tester
        .runAsync(() => QuranRepository.instance.surah(21)))!;
    expect(verses.length, 112);
    expect(verses[87], contains('ۨ'), reason: '«نُـۨجِى» small noon');

    await tester.pumpWidget(host(const MushafReaderPage(surah: 21)));
    await tester.pumpAndSettle();
    for (var i = 0; i < verses.length; i++) {
      expect(find.text('${verses[i]} ${marker(i + 1)}'), findsOneWidget,
          reason: '21:${i + 1} not rendered verbatim');
    }
    expect(find.text(QuranRepository.instance.basmala), findsOneWidget);
  });

  testWidgets('Mushaf reader: At-Tin shows the basmala once, as a heading',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tallView(tester);
    final verses = (await tester
        .runAsync(() => QuranRepository.instance.surah(95)))!;
    await tester.pumpWidget(host(const MushafReaderPage(surah: 95)));
    await tester.pumpAndSettle();
    expect(find.text('${verses.first} ${marker(1)}'), findsOneWidget);
    expect(find.textContaining('بِّس'), findsNothing,
        reason: '«بِّسْمِ» leaked into ayah 1');
    expect(find.text(QuranRepository.instance.basmala), findsOneWidget);
  });

  testWidgets('general ruqyah shows Al-Fatiha verbatim', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tallView(tester);
    await tester.pumpWidget(host(const GeneralRuqyahPage()));
    await tester.pumpAndSettle();
    for (final v in surahAlFatiha.verses) {
      expect(find.text(v.withMarker), findsOneWidget,
          reason: '1:${v.number} not rendered verbatim');
    }
  });

  testWidgets('written ruqyah shows its first surahs verbatim', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tallView(tester);
    await tester.pumpWidget(host(const WrittenRoqiaPage()));
    await tester.pumpAndSettle();
    final baqarah = writtenSurahs[1];
    expect(find.text(baqarah.basmala!), findsWidgets);
    for (final v in [...writtenSurahs[0].verses, ...baqarah.verses]) {
      expect(find.text(v), findsOneWidget, reason: v);
    }
  });
}
