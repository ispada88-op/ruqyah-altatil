import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/config/app_identity.dart';

void main() {
  test('app is named الرقية الشاملة; رقية التعطيل is attributed to the Sheikh', () {
    expect(AppIdentity.name, 'الرقية الشاملة');
    expect(AppIdentity.taTilAttribution,
        'رقية التعطيل لفضيلة الشيخ فهد القرني');
  });

  test('store-visible names use the new app name', () {
    expect(File('ios/Runner/Info.plist').readAsStringSync(),
        contains('<string>الرقية الشاملة</string>'));
    expect(File('android/app/src/main/res/values-ar/strings.xml').readAsStringSync(),
        contains('>الرقية الشاملة<'));
    expect(File('android/app/src/main/res/values-ar/strings.xml').readAsStringSync(),
        isNot(contains('رقية التعطيل')));
  });

  test('attribution is shown on first screen, home and the written ruqyah page', () {
    for (final f in [
      'lib/pages/onboarding_page.dart',
      'lib/pages/home_page.dart',
      'lib/pages/written_roqia_page.dart',
    ]) {
      expect(File(f).readAsStringSync(), contains('AppIdentity.taTil'), reason: f);
    }
  });

  test('searchable: store listing keeps «رقية التعطيل» in subtitle/keywords', () {
    final s = File('docs/android/STORE_LISTING.md').readAsStringSync();
    expect(s, contains('رقية التعطيل والأذكار والسحر'));
    expect(s, contains('رقيه التعطيل'));
  });
}
