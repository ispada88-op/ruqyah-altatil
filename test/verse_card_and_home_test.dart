import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/verse_card_page.dart';
import 'package:roqia_altatil/widgets/today_strip.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('shortLeftAr', () {
    expect(shortLeftAr(const Duration(seconds: 20)), 'أقل من دقيقة');
    expect(shortLeftAr(const Duration(minutes: 12)), '١٢ د');
    expect(shortLeftAr(const Duration(minutes: 60)), '١ س');
    expect(shortLeftAr(const Duration(minutes: 80)), '١ س ٢٠ د');
    expect(shortLeftAr(const Duration(minutes: -5)), 'أقل من دقيقة');
  });

  test('verse card route builder and canonical path', () {
    expect(AppRoutes.verseCardFor(2, 255), '/verse-card?s=2&a=255');
    expect(AppRoutes.normalize('/verse-card'), isNull);
  });

  testWidgets('VerseCard renders every theme at large text without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final t in kVerseCardThemes) {
      await tester.pumpWidget(const SizedBox()); // شجرة جديدة لكل لون
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(t.label),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: VerseCard(
                  verse: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ' * 12,
                  surah: 2,
                  ayah: 282,
                  theme: t,
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: t.label);
      expect(find.textContaining('سورة البقرة'), findsOneWidget);
    }
  });

  testWidgets('a card can be captured as a PNG', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: key,
          child: VerseCard(
              verse: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
              surah: 112,
              ayah: 1,
              theme: kVerseCardThemes.first),
        ),
      ),
    ));
    await tester.pump();
    final bytes = await tester.runAsync(() async {
      final box = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await box.toImage(pixelRatio: 2);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]); // PNG
    expect(bytes.length, greaterThan(500));
  });

  testWidgets('invalid surah/ayah shows a message instead of crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
          textDirection: TextDirection.rtl,
          child: VerseCardPage(surah: 999, ayah: 1)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('تعذّر تحميل الآية'), findsOneWidget);
  });
}
