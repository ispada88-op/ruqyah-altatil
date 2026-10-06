/// Single source of truth for store IDs, public URLs and contact addresses.
///
/// Update ONLY here when a store listing changes (e.g. the Google Play release
/// goes live) — every screen/service reads from this file.
class AppLinks {
  AppLinks._();

  /// Apple App Store numeric ID (from App Store Connect → App Information).
  static const String appStoreId = '6760603658';

  /// Android application id (Google Play listing, once published).
  static const String androidPackage = 'com.ruqyah.altatil';

  static const String appStoreUrl = 'https://apps.apple.com/app/id$appStoreId';

  /// Landing page with both store buttons — used when sharing the app, so one
  /// link works for iPhone and Android users alike.
  static const String shareUrl = 'https://ispada88-op.github.io/ruqyah-altatil/';

  /// Where the feedback form sends its message.
  static const String feedbackEmail = 'ISPADA88@GMAIL.COM';
}
