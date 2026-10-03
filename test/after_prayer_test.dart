import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/after_prayer_data.dart';
import 'package:roqia_altatil/data/general_ruqyah_data.dart';
import 'package:roqia_altatil/data/verified_quran.dart';
import 'package:roqia_altatil/pages/after_prayer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بنية ومحتوى أذكار ما بعد الصلاة. تطابق النص مع «حصن المسلم»:
/// `python3 scripts/gen_after_prayer.py --check` (يعمل في CI).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final items = afterPrayerItems();

  test('12 items in the order of Hisn al-Muslim', () {
    expect([for (final i in items) i.title], [
      'الاستغفار',
      'اللهم أنت السلام',
      'لا مانع لما أعطيت',
      'لا حول ولا قوة إلا بالله',
      'التسبيح',
      'التحميد',
      'التكبير',
      'تمام المئة',
      'آية الكرسي',
      'المعوذات',
      'التهليل عشراً',
      'علماً نافعاً',
    ]);
  });

  test('counts: istighfar ×3, tasbih/tahmid/takbir ×33, tahlil ×10', () {
    int rep(String t) => items.firstWhere((i) => i.title == t).repeat;
    expect(rep('الاستغفار'), 3);
    expect(rep('التسبيح') + rep('التحميد') + rep('التكبير') + 1, 100);
    expect(rep('التهليل عشراً'), 10);
  });

  test('every item has a source and non-empty text', () {
    for (final i in items) {
      expect(i.source, isNotNull, reason: i.title);
      expect(i.blocks.expand((b) => b.lines).every((l) => l.trim().isNotEmpty),
          isTrue,
          reason: i.title);
    }
  });

  test('Quran items come from the verified text, byte for byte', () {
    final kursi = items.firstWhere((i) => i.title == 'آية الكرسي');
    expect(kursi.isQuran, isTrue);
    expect(kursi.blocks.single.lines, verseLines(ayatAlKursi));
    final mu = items.firstWhere((i) => i.title == 'المعوذات');
    expect(mu.isQuran, isTrue);
    expect(mu.blocks.map((b) => b.lines).toList(),
        muawwidhatBlocks.map((b) => b.lines).toList());
  });

  test('no ASCII comma and no leftover count notes in dhikr text', () {
    for (final i in items.where((i) => !i.isQuran)) {
      for (final l in i.blocks.expand((b) => b.lines)) {
        expect(l.contains(','), isFalse, reason: i.title);
        expect(l.contains('(') || l.contains('['), isFalse, reason: i.title);
      }
    }
  });

  testWidgets('page renders the first dhikr and its source', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
          textDirection: TextDirection.rtl, child: AfterPrayerPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('أذكار بعد الصلاة'), findsWidgets);
    expect(find.text('الاستغفار'), findsOneWidget);
  });
}
