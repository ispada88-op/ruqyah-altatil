import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/config/app_identity.dart';

void main() {
  test('app is named الرقية الشاملة; رقية التعطيل is attributed to the Sheikh',
      () {
    expect(AppIdentity.name, 'الرقية الشاملة');
    expect(
        AppIdentity.taTilAttribution, 'رقية التعطيل لفضيلة الشيخ فهد القرني');
  });

  test('store name + subtitle show all three names, each within 30 chars', () {
    expect(AppIdentity.storeName, 'الرقية الشاملة والمصحف الشريف');
    expect(AppIdentity.storeSubtitle, 'رقية التعطيل للشيخ فهد القرني');
    expect(AppIdentity.storeName.length, lessThanOrEqualTo(30));
    expect(AppIdentity.storeSubtitle.length, lessThanOrEqualTo(30));
    expect(AppIdentity.fullName, 'الرقية الشاملة ورقية التعطيل والمصحف الشريف');
    for (final w in ['الرقية الشاملة', 'رقية التعطيل', 'المصحف الشريف']) {
      expect(AppIdentity.fullName, contains(w));
      // الثلاثة ظاهرة في المتجر: الاسم + العنوان الفرعي معاً.
      expect('${AppIdentity.storeName} ${AppIdentity.storeSubtitle}', contains(w));
    }
    // «رقية التعطيل» تظهر في المتجر منسوبةً للشيخ دائماً (لا بلا نسبة).
    expect(AppIdentity.storeSubtitle, contains(AppIdentity.taTil));
    expect(AppIdentity.storeSubtitle, contains('للشيخ فهد القرني'));
  });

  test('sadaqa line is shown and shared with the app link', () {
    expect(AppIdentity.sadaqaLine, contains('صدقةً جارية'));
    expect(File('lib/services/share_service.dart').readAsStringSync(),
        contains('AppIdentity.sadaqaLine'));
    expect(File('lib/pages/home_page.dart').readAsStringSync(),
        contains('AppIdentity.sadaqaLine'));
  });

  test('store-visible names use the new app name', () {
    expect(File('ios/Runner/Info.plist').readAsStringSync(),
        contains('<string>الرقية الشاملة</string>'));
    expect(
        File('android/app/src/main/res/values-ar/strings.xml')
            .readAsStringSync(),
        contains('>الرقية الشاملة<'));
    expect(
        File('android/app/src/main/res/values-ar/strings.xml')
            .readAsStringSync(),
        isNot(contains('رقية التعطيل')));
  });

  test('attribution is shown on first screen, home and the written ruqyah page',
      () {
    for (final f in [
      'lib/pages/onboarding_page.dart',
      'lib/pages/home_page.dart',
      'lib/pages/written_roqia_page.dart',
    ]) {
      expect(File(f).readAsStringSync(), contains('AppIdentity.taTil'),
          reason: f);
    }
  });

  test('searchable: store listing keeps «رقية التعطيل» in name and keywords',
      () {
    final s = File('docs/android/STORE_LISTING.md').readAsStringSync();
    expect(s, contains(AppIdentity.storeName));
    expect(s, contains(AppIdentity.storeSubtitle));
    expect(s, contains('رقيه التعطيل'));
  });
}
