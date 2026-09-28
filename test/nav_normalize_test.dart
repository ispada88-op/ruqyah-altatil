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
}
