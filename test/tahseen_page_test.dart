import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/hisn_almuslim_dhikr.dart';
import 'package:roqia_altatil/pages/tahseen_page.dart';

void main() {
  group('Tahseen data integrity', () {
    test('has exactly 10 sourced tahseen adhkar', () {
      final sourced =
          hisnAlmuslimDhikr.where((d) => d.category == 'tahseen').toList();
      expect(sourced.length, 10);
      // every sourced entry must carry an attribution in its title
      for (final d in sourced) {
        expect(
          d.title.contains('—'),
          isTrue,
          reason: 'sourced tahseen "${d.title}" must include its source',
        );
      }
    });

    test('has exactly 4 general tahseen duas without hadith attribution', () {
      final duas =
          hisnAlmuslimDhikr.where((d) => d.category == 'dua_tahseen').toList();
      expect(duas.length, 4);
      for (final d in duas) {
        expect(d.title.contains('رواه'), isFalse,
            reason: 'general duas must not claim a narration source');
        expect(d.title.contains('متفق'), isFalse);
      }
    });

    test('no empty or duplicate bodies across tahseen entries', () {
      final all = hisnAlmuslimDhikr
          .where((d) => d.category == 'tahseen' || d.category == 'dua_tahseen')
          .map((d) => d.body)
          .toList();
      expect(all.any((b) => b.trim().isEmpty), isFalse);
      expect(all.toSet().length, all.length, reason: 'duplicate dhikr body');
    });
  });

  group('TahseenPage widget', () {
    testWidgets('renders header, both sections and all 14 cards',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: TahseenPage()),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('أذكار التحصين'), findsOneWidget);
      expect(find.text('أذكار مأثورة بمصادرها'), findsOneWidget);

      // scroll through the list and count unique tahseen cards by their copy buttons
      final copyButtons = find.byIcon(Icons.copy_rounded);
      // at least the first cards are built lazily; scroll to bottom to build all
      final listFinder = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('أدعية تحصين عامة'),
        400,
        scrollable: listFinder,
      );
      expect(find.text('أدعية تحصين عامة'), findsOneWidget);
      expect(copyButtons, findsWidgets);
    });

    testWidgets('renders in dark theme without exceptions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: TahseenPage()),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('أذكار التحصين'), findsOneWidget);
    });
  });
}
