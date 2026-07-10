import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/general_ruqyah_data.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('General ruqyah data integrity', () {
    test('has exactly 7 items in the prescribed order', () {
      final items = generalRuqyahItems;
      expect(items.length, 7);
      expect(items.map((i) => i.title).toList(), [
        'سورة الفاتحة',
        'المعوذات',
        'آيات من سورة طه',
        'آية من سورة هود',
        'بسم الله',
        'التعوّذ بعزة الله',
        'سؤال الله الشفاء',
      ]);
    });

    test('repeat counts match the ruqyah prescription', () {
      expect(generalRuqyahItems.map((i) => i.repeat).toList(),
          [7, 7, 7, 7, 3, 7, 7]);
    });

    test('Quran items are flagged, adhkar items carry a source', () {
      final items = generalRuqyahItems;
      for (final i in items.take(4)) {
        expect(i.isQuran, isTrue, reason: '${i.title} must be Quran-flagged');
      }
      for (final i in items.skip(4)) {
        expect(i.isQuran, isFalse);
        expect(i.source, isNotNull,
            reason: '${i.title} must carry hadith attribution');
      }
    });

    test('muawwidhat item contains the three surahs with basmala', () {
      final m = generalRuqyahItems[1];
      expect(m.blocks.length, 3);
      expect(m.blocks.map((b) => b.heading).toList(),
          ['سورة الإخلاص', 'سورة الفلق', 'سورة الناس']);
      for (final b in m.blocks) {
        expect(b.lines.first, contains('بِسْمِ'));
        expect(b.lines.length, greaterThan(1));
      }
    });

    test('no empty lines and plainText includes repeat label', () {
      for (final i in generalRuqyahItems) {
        for (final b in i.blocks) {
          for (final l in b.lines) {
            expect(l.trim(), isNotEmpty);
          }
        }
        expect(i.plainText, contains('مرات'));
      }
    });
  });

  group('GeneralRuqyahPage widget', () {
    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: GeneralRuqyahPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders header and first items', (tester) async {
      await pumpPage(tester);
      expect(find.text('الرقية المستقلة'), findsOneWidget);
      expect(find.text('سورة الفاتحة'), findsOneWidget);
      // «المعوذات» تحت حد النافذة في ListView كسول — نمرّر إليها
      await tester.scrollUntilVisible(
        find.text('المعوذات'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('المعوذات'), findsOneWidget);
    });

    testWidgets('counter increments on tap and completes at target',
        (tester) async {
      await pumpPage(tester);
      // عدّاد الفاتحة يبدأ 0 / 7
      expect(find.text('0 / 7'), findsWidgets);
      await tester.ensureVisible(find.text('0 / 7').first);
      await tester.pump();
      await tester.tap(find.text('0 / 7').first);
      await tester.pump();
      expect(find.text('1 / 7'), findsOneWidget);
      // ست ضغطات إضافية → اكتمال
      for (var i = 0; i < 6; i++) {
        await tester.ensureVisible(find.text('${i + 1} / 7').first);
        await tester.pump();
        await tester.tap(find.text('${i + 1} / 7').first);
        await tester.pump();
      }
      expect(find.text('اكتمل ✓'), findsOneWidget);
    });
  });
}
