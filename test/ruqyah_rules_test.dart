import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/ruqyah_rules_data.dart';
import 'package:roqia_altatil/pages/ruqyah_rules_page.dart';

void main() {
  test('every quoted hadith carries its source; no empty text', () {
    expect(kRuqyahRules.length, greaterThanOrEqualTo(5));
    for (final s in kRuqyahRules) {
      expect(s.points, isNotEmpty, reason: s.title);
      for (final p in s.points) {
        expect(p.text.trim(), isNotEmpty);
        if (p.hadith != null) {
          expect(p.source, isNotNull, reason: p.hadith);
        }
      }
    }
  });

  test('sources are attribution only (no grading words invented)', () {
    const banned = ['صحيح', 'حسن', 'ضعيف', 'موضوع'];
    for (final s in kRuqyahRules) {
      for (final p in s.points) {
        for (final w in banned) {
          expect((p.source ?? '').contains(w), isFalse, reason: p.source);
        }
      }
    }
  });

  testWidgets('page shows the three conditions section and the disclaimer',
      (tester) async {
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
          textDirection: TextDirection.rtl, child: RuqyahRulesPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('الشروط الثلاثة للرقية الشرعية'), findsOneWidget);
    expect(find.textContaining('ليست فتوى'), findsOneWidget);
  });
}
