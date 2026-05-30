import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

/// خدمة طلب تقييم التطبيق بطريقة لطيفة.
///
/// السلوك:
/// - تتزايد جلسات الفتح كل مرة `markSessionStart()`
/// - بعد الجلسة الـ 10، تطلب تقييم مرة واحدة
/// - بعد الجلسة الـ 30، تطلب مرة ثانية لو ما قيّم
/// - تحفظ "تم الطلب" حتى لا يكرر الإزعاج
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const _kSessionCountKey = 'review_session_count';
  static const _kAskedAtKey = 'review_asked_at';
  static const _kThresholds = [10, 30];

  final InAppReview _inAppReview = InAppReview.instance;

  /// تستدعى من `main()` بعد التهيئة.
  Future<void> markSessionStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_kSessionCountKey) ?? 0) + 1;
      await prefs.setInt(_kSessionCountKey, count);

      final askedAt = prefs.getInt(_kAskedAtKey) ?? 0;
      // إذا وصلنا threshold ولم نطلب من قبل في هذا الـ threshold
      for (final t in _kThresholds) {
        if (count == t && askedAt < t) {
          await Future.delayed(const Duration(seconds: 5)); // wait for app to settle
          await _maybeRequest();
          await prefs.setInt(_kAskedAtKey, t);
          break;
        }
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ReviewService.markSessionStart');
    }
  }

  Future<void> _maybeRequest() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'requestReview');
    }
  }

  /// طلب يدوي (من زر "قيّم التطبيق" في الإعدادات).
  Future<void> openStoreListing() async {
    try {
      // تأكد من id قبل النشر — يطلب package id من Play Console
      await _inAppReview.openStoreListing(
        appStoreId: '6738451632', // Apple Store id (مثال - بدّله بالحقيقي)
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'openStoreListing');
    }
  }
}
