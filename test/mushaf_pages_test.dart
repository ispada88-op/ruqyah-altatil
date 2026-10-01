import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/services/mushaf_pages_repository.dart';
import 'package:roqia_altatil/widgets/mushaf_page_view.dart';

/// صفحات مصحف المدينة (٦٠٤) وخطوطها من «Mushaf Publisher» التابع لمجمع الملك فهد.
/// أي تغيير في الملف أو الخطوط (تحويل/تقليص/تعديل ممنوع) يجب أن يفشل هنا.
const _layoutSha = '6a3b3faf04fbe24a8840c65d579944da877540cd881a18bd95f5fa42759b0746';
const _fontsManifestSha = 'f860431adc69117b59a014199b8fdb05dabe3b02b7d6bcb6416ebb5d7c17d69f';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final file = File(MushafPagesRepository.assetPath);
  final layout = parseMushafPages(file.readAsStringSync());

  test('layout asset is the pinned one (SHA-256)', () {
    expect(sha256.convert(file.readAsBytesSync()).toString(), _layoutSha,
        reason: 'regenerate only with scripts/gen_mushaf_pages.py from the official DB');
  });

  test('47 page fonts + sura-name font are byte-identical to the official ones', () {
    final files = Directory(MushafPagesRepository.fontsDir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ttf'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    expect(files.length, 48);
    final manifest = StringBuffer();
    for (final f in files) {
      manifest.write('${f.uri.pathSegments.last}:${sha256.convert(f.readAsBytesSync())}\n');
    }
    expect(sha256.convert(manifest.toString().codeUnits).toString(), _fontsManifestSha,
        reason: 'KFGQPC licence forbids modifying/converting the fonts');
    expect(File('${MushafPagesRepository.fontsDir}/NOTICE.txt').existsSync(), isTrue);
  });

  test('604 pages; 15 lines each except pages 1–2 (8 lines)', () {
    expect(layout.pages.length, 604);
    for (final p in layout.pages) {
      expect(p.lines.length, p.number <= 2 ? 8 : 15, reason: 'page ${p.number}');
    }
  });

  test('every page font exists as a file', () {
    final used = {for (final p in layout.pages) ...p.fonts};
    for (final f in used) {
      expect(File('${MushafPagesRepository.fontsDir}/$f.ttf').existsSync(), isTrue, reason: f);
    }
  });

  test('all 6236 verse ends appear once, in order, matching kSurahs ayah counts', () {
    final seq = [for (final p in layout.pages) ...p.verseEnds];
    expect(seq.length, 6236);
    var i = 0;
    for (final s in kSurahs) {
      for (var a = 1; a <= s.ayahCount; a++) {
        expect(seq[i], (s.number, a), reason: 'index $i');
        i++;
      }
    }
  });

  test('surah / juz start pages are the Madinah Mushaf ones', () {
    expect(layout.pageOfSurah(1), 1);
    expect(layout.pageOfSurah(2), 2);
    expect(layout.pageOfSurah(9), 187);
    expect(layout.pageOfSurah(18), 293);
    expect(layout.pageOfSurah(36), 440);
    expect(layout.pageOfSurah(67), 562);
    expect(layout.pageOfSurah(114), 604);
    var prev = 0;
    for (var s = 1; s <= 114; s++) {
      final p = layout.pageOfSurah(s);
      expect(p, greaterThanOrEqualTo(prev), reason: 'surah $s');
      prev = p;
    }
    expect(layout.pageOfJuz(1), 1);
    expect(layout.pageOfJuz(2), 22);
    for (var j = 2; j <= 30; j++) {
      expect(layout.pageOfJuz(j), 2 + 20 * (j - 1), reason: 'juz $j');
    }
    expect(layout.pageOfAyah(2, 255), 42); // آية الكرسي
  });

  test('page numbers in routes', () {
    // ignore: avoid_dynamic_calls
    expect(layout.page(0).number, 1);
    expect(layout.page(999).number, 604);
  });

  testWidgets('a page renders one text widget per glyph, without overflow', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final page = layout.page(3);
    final glyphs = page.lines.fold<int>(0, (a, l) => a + l.length);
    await tester.runAsync(() => MushafPagesRepository.instance.ensureFonts(page.fonts));
    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: MushafPageView(page: page, color: Colors.black, accent: Colors.amber),
        ),
      ),
    ));
    // the font futures complete in the real zone: give the event loop a turn
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(Text), findsNWidgets(glyphs));
  });
}
