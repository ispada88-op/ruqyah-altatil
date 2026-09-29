import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/data/general_ruqyah_data.dart';
import 'package:roqia_altatil/data/hisn_almuslim_dhikr.dart';
import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';

void main() {
  test('surah names: hamzat al-qat\' / al-wasl as in the Mushaf headers', () {
    String name(int n) => kSurahs[n - 1].name;
    expect(name(14), 'إبراهيم');
    expect(name(76), 'الإنسان');
    expect(name(82), 'الانفطار');
    expect(name(84), 'الانشقاق');
    for (var i = 0; i < kSurahs.length; i++) {
      expect(kSurahs[i].number, i + 1);
    }
  });

  test('ayat count labels are grammatical Arabic', () {
    expect(ayatLabel(1), 'آية واحدة');
    expect(ayatLabel(2), 'آيتان');
    expect(ayatLabel(7), '٧ آيات');
    expect(ayatLabel(10), '١٠ آيات');
    expect(ayatLabel(11), '١١ آية');
    expect(ayatLabel(103), '١٠٣ آيات');
    expect(ayatLabel(286), '٢٨٦ آية');
  });

  test('copied Quran text carries the surah name / location', () {
    final fatiha = generalRuqyahItems.first;
    expect(fatiha.plainText.startsWith('سورة الفاتحة'), isTrue);
    final taha = generalRuqyahItems.firstWhere((i) => i.title == 'آيات من سورة طه');
    expect(taha.plainText.startsWith('آيات من سورة طه — طه (١٠٥-١٠٧)'), isTrue);
  });

  test('only real ayat are labelled «آية», each with its reference', () {
    final ayat = hisnAlmuslimDhikr.where((d) => d.category == 'ayah');
    expect(ayat, isNotEmpty);
    for (final d in ayat) {
      expect(RegExp(r'^آية — .+ [٠-٩]+$').hasMatch(d.title), isTrue,
          reason: d.title);
    }
    expect(
      hisnAlmuslimDhikr.any((d) =>
          d.category == 'ayah' && d.body.contains('مُحَمَّدٌ رَسُولُ')),
      isFalse,
      reason: 'the shahada is two half-verses, not one ayah',
    );
  });
}
