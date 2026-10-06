import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/adhkar_data.dart';
import 'package:roqia_altatil/data/general_ruqyah_data.dart';
import 'package:roqia_altatil/data/ruqyah_types_data.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/adhkar_page.dart';
import 'package:roqia_altatil/pages/ruqyah_types_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Content guards. Letter-by-letter text checks against Hisn al-Muslim:
/// scripts/verify_adhkar.py. These tests pin structure and counts.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('أذكار الصباح والمساء', () {
    final morning = adhkarItems(AdhkarTime.morning);
    final evening = adhkarItems(AdhkarTime.evening);

    test('starts with Ayat al-Kursi then the Mu\'awwidhat ×3', () {
      for (final list in [morning, evening]) {
        expect(list[0].title, 'آية الكرسي');
        expect(list[0].isQuran, isTrue);
        expect(list[1].title, 'المعوذات');
        expect(list[1].repeat, 3);
      }
    });

    test('item counts', () {
      expect(morning.length, 22);
      expect(evening.length, 20);
    });

    test('counts follow the book', () {
      int rep(List<GeneralRuqyahItem> l, String t) =>
          l.firstWhere((i) => i.title == t).repeat;
      expect(rep(morning, 'الإشهاد'), 4);
      expect(rep(morning, 'حسبي الله'), 7);
      expect(rep(morning, 'التسبيح'), 100);
      expect(rep(morning, 'التهليل'), 100);
      expect(rep(evening, 'التهليل'), 10);
      expect(rep(evening, 'كلمات الله التامات'), 3);
      expect(rep(morning, 'الصلاة على النبي ﷺ'), 10);
    });

    test('evening wording never says «أصبح…» where the book says «أمسى…»', () {
      final eveningTexts = adhkarTexts(AdhkarTime.evening).join('\n');
      expect(eveningTexts.contains('أَصْبَحْنَا وَأَصْبَحَ'), isFalse);
      expect(eveningTexts.contains('إِنِّي أَصْبَحْتُ'), isFalse);
      expect(eveningTexts.contains('هَذَا الْيَوْمِ'), isFalse);
      expect(eveningTexts.contains('إِلَيْكَ الْمَصِيرُ'), isTrue);
      final morningTexts = adhkarTexts(AdhkarTime.morning).join('\n');
      expect(morningTexts.contains('أَمْسَيْنَا وَأَمْسَى'), isFalse);
      expect(morningTexts.contains('إِلَيْكَ النُّشُورُ'), isTrue);
    });

    test('every non-Quran dhikr has a source and one non-empty line', () {
      for (final i in [...morning, ...evening]) {
        expect(i.source, isNotNull, reason: i.title);
        for (final b in i.blocks) {
          for (final l in b.lines) {
            expect(l.trim(), isNotEmpty, reason: i.title);
          }
        }
      }
    });

    test('default tab follows the clock', () {
      expect(
          AdhkarPage.defaultFor(DateTime(2026, 1, 1, 6)), AdhkarTime.morning);
      expect(
          AdhkarPage.defaultFor(DateTime(2026, 1, 1, 17)), AdhkarTime.evening);
      expect(
          AdhkarPage.defaultFor(DateTime(2026, 1, 1, 1)), AdhkarTime.evening);
    });
  });

  group('رقى حسب الحالة', () {
    test('three types, ids match the router whitelist', () {
      expect(kRuqyahTypes.map((t) => t.id).toSet(), AppRoutes.ruqyahTypeIds);
    });

    test('sihr type carries the three verse ranges (Ibn Baz)', () {
      final titles =
          ruqyahTypeById('sihr')!.items().map((i) => i.title).toList();
      expect(
          titles,
          containsAll([
            'آيات من سورة الأعراف',
            'آيات من سورة يونس',
            'آيات من سورة طه'
          ]));
    });

    test('every dua is attributed; every item has text', () {
      for (final t in kRuqyahTypes) {
        for (final i in t.items()) {
          if (!i.isQuran) {
            expect(i.source, isNotNull, reason: '${t.id}: ${i.title}');
          }
          expect(i.blocks.expand((b) => b.lines).isNotEmpty, isTrue);
        }
      }
    });

    test('repeat labels read correctly in Arabic', () {
      expect(repeatLabelFor(1), 'مرة واحدة');
      expect(repeatLabelFor(2), 'مرتان');
      expect(repeatLabelFor(3), '٣ مرات');
      expect(repeatLabelFor(10), '١٠ مرات');
      expect(repeatLabelFor(100), '١٠٠ مرة');
    });
  });

  group('widgets', () {
    Widget host(Widget child) => MaterialApp(
          home: Directionality(textDirection: TextDirection.rtl, child: child),
        );

    testWidgets('AdhkarPage switches between morning and evening',
        (tester) async {
      await tester
          .pumpWidget(host(const AdhkarPage(initial: AdhkarTime.morning)));
      await tester.pumpAndSettle();
      expect(find.text('أذكار الصباح'), findsOneWidget);
      await tester.tap(find.text('المساء'));
      await tester.pumpAndSettle();
      expect(find.text('أذكار المساء'), findsOneWidget);
    });

    testWidgets('RuqyahTypesPage lists the three types', (tester) async {
      await tester.pumpWidget(host(const RuqyahTypesPage()));
      await tester.pumpAndSettle();
      for (final t in kRuqyahTypes) {
        expect(find.text(t.title), findsOneWidget);
      }
    });
  });
}
