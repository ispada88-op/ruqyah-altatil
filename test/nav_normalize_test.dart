import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/nav.dart';

void main() {
  test('canonical routes pass through untouched', () {
    for (final r in AppRoutes.all) {
      expect(AppRoutes.normalize(r), isNull, reason: r);
    }
  });

  test('app-shortcut / legacy deep links map to real screens', () {
    expect(AppRoutes.normalize('/audio'), AppRoutes.audioRoqia);
    expect(AppRoutes.normalize('/written'), AppRoutes.writtenRoqia);
    expect(AppRoutes.normalize(''), AppRoutes.home);
    expect(AppRoutes.normalize('/dhikr/'), AppRoutes.dhikr);
  });

  test('unknown paths fall back to home instead of an error page', () {
    expect(AppRoutes.normalize('/does-not-exist'), AppRoutes.home);
  });

  test('parameterised routes: valid kept, invalid → their index page', () {
    expect(AppRoutes.normalize('/mushaf/2'), isNull);
    expect(AppRoutes.normalize('/mushaf/114'), isNull);
    expect(AppRoutes.normalize('/mushaf/0'), AppRoutes.mushaf);
    expect(AppRoutes.normalize('/mushaf/115'), AppRoutes.mushaf);
    expect(AppRoutes.normalize('/ruqyah-types/sihr'), isNull);
    expect(AppRoutes.normalize('/ruqyah-types/xyz'), AppRoutes.ruqyahTypes);
    expect(AppRoutes.normalize('/quran'), AppRoutes.mushaf);
    expect(AppRoutes.normalize('/mushaf/page/604'), isNull);
    expect(AppRoutes.normalize('/mushaf/page/0'), AppRoutes.mushaf);
    expect(AppRoutes.normalize('/mushaf/page/605'), AppRoutes.mushaf);
  });

  test('route builders', () {
    expect(AppRoutes.mushafSurah(2), '/mushaf/2');
    expect(AppRoutes.mushafPage(42), '/mushaf/page/42');
    expect(AppRoutes.mushafSurah(2, ayah: 142), '/mushaf/2?ayah=142');
    expect(AppRoutes.mushafSurah(18, resume: true), '/mushaf/18?resume=1');
    expect(AppRoutes.ruqyahType('ayn'), '/ruqyah-types/ayn');
  });
}
