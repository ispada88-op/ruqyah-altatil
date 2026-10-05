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

  test('bottom tabs: roots, section membership and back targets', () {
    expect(AppRoutes.tabRoots, [
      AppRoutes.home,
      AppRoutes.mushaf,
      AppRoutes.ruqyahHub,
      AppRoutes.adhkarHub,
      AppRoutes.prayerTimes,
    ]);
    // كل جذر يعود لنفسه كتبويب، والصفحات الفرعية تنتمي لقسمها.
    for (var i = 0; i < AppRoutes.tabRoots.length; i++) {
      expect(AppRoutes.tabOf(AppRoutes.tabRoots[i]), i);
    }
    expect(AppRoutes.tabOf(AppRoutes.khatma), 1);
    expect(AppRoutes.tabOf('/mushaf/page/12'), 1);
    expect(AppRoutes.tabOf(AppRoutes.audioRoqia), 2);
    expect(AppRoutes.tabOf(AppRoutes.ruqyahType('sihr')), 2);
    expect(AppRoutes.tabOf(AppRoutes.tahseen), 3);
    expect(AppRoutes.tabOf(AppRoutes.afterPrayer), 3);
    expect(AppRoutes.tabOf(AppRoutes.qibla), 4);
    expect(AppRoutes.tabOf(AppRoutes.feedback), 0);

    // زر الرجوع: الصفحة الفرعية إلى قائمتها، والجذر إلى الرئيسية.
    expect(AppRoutes.parentOf(AppRoutes.audioRoqia), AppRoutes.ruqyahHub);
    expect(AppRoutes.parentOf(AppRoutes.ruqyahType('ayn')), AppRoutes.ruqyahHub);
    expect(AppRoutes.parentOf(AppRoutes.dhikr), AppRoutes.adhkarHub);
    expect(AppRoutes.parentOf(AppRoutes.reminders), AppRoutes.adhkarHub);
    expect(AppRoutes.parentOf(AppRoutes.khatma), AppRoutes.mushaf);
    expect(AppRoutes.parentOf('/mushaf/page/12'), AppRoutes.mushaf);
    expect(AppRoutes.parentOf(AppRoutes.qibla), AppRoutes.prayerTimes);
    expect(AppRoutes.parentOf(AppRoutes.feedback), AppRoutes.home);
    for (final root in AppRoutes.tabRoots) {
      expect(AppRoutes.parentOf(root), AppRoutes.home, reason: root);
    }
  });

  test('no section page falls through to the home tab by mistake', () {
    // صفحة جديدة نُسي إدراجها في tabOf تظهر هنا بدل أن تُظهر «الرئيسية» نشطة.
    const homeTab = {AppRoutes.home, AppRoutes.feedback};
    for (final r in AppRoutes.all.difference(homeTab)) {
      expect(AppRoutes.tabOf(r), isNot(0), reason: r);
    }
  });
}
