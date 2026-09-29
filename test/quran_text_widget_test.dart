import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/quran_text.dart';

void main() {
  testWidgets('QuranText never becomes bold, even with the system «Bold text» setting',
      (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(boldText: true),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          QuranText('س', key: const Key('q'), style: AppTextStyles.mushaf()),
          const Text('س', key: Key('plain')),
        ]),
      ),
    ));
    FontWeight? weightOf(Key k) => tester
        .widget<RichText>(find.descendant(of: find.byKey(k), matching: find.byType(RichText)))
        .text
        .style
        ?.fontWeight;
    expect(weightOf(const Key('q')), isNot(FontWeight.bold));
    expect(weightOf(const Key('plain')), FontWeight.bold,
        reason: 'sanity: ordinary Text does pick up the bold setting');
  });

  test('mushaf style uses the KFGQPC family and no explicit weight', () {
    final s = AppTextStyles.mushaf();
    expect(s.fontFamily, kQuranFontFamily);
    expect(s.fontWeight, isNull);
  });
}
