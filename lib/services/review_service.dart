import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_links.dart';
import 'error_reporter.dart';

/// متى نطلب التقييم — دالة صرفة لتُختبر بلا واجهة.
///
/// الفكرة: لا نسأل مستخدماً جديداً. نسأل من صار التطبيق عادةً عنده
/// (أيام فتح متفرقة، لا جلسات متتالية في يوم واحد)، وفي لحظة رضا
/// (إتمام ورد الختمة اليوم) — وبعدها لا نكرّر قبل ٩٠ يوماً.
class ReviewPolicy {
  ReviewPolicy._();

  /// لحظة رضا (ورد اليوم اكتمل): مرور أسبوع على أول فتح وخمسة أيام نشاط.
  static const minAgeDays = 7;
  static const minActiveDays = 5;

  /// بلا لحظة رضا (المستخدم لا يستعمل الختمة): نصبر أكثر.
  static const lateAgeDays = 14;
  static const lateActiveDays = 8;

  static const minDaysBetweenPrompts = 90;

  /// البطاقة الهادئة في الرئيسية: بعد نافذة النظام بقليل، وتختفي نهائياً
  /// بالتقييم أو بعد تأجيلين.
  static const cardMinAgeDays = 10;
  static const cardMinActiveDays = 6;
  static const cardMinDaysBetween = 30;
  static const cardMaxDismissals = 2;

  static bool shouldShowCard({
    required DateTime now,
    required DateTime firstLaunch,
    required int activeDays,
    required bool rated,
    required int dismissals,
    DateTime? lastDismissed,
  }) {
    if (rated || dismissals >= cardMaxDismissals) return false;
    if (lastDismissed != null &&
        now.difference(lastDismissed).inDays < cardMinDaysBetween) {
      return false;
    }
    return now.difference(firstLaunch).inDays >= cardMinAgeDays &&
        activeDays >= cardMinActiveDays;
  }

  /// Apple نفسها تحدّ العرض بثلاث مرات في السنة؛ لا نحاول أكثر.
  static const maxPrompts = 3;

  static bool shouldAsk({
    required DateTime now,
    required DateTime firstLaunch,
    required int activeDays,
    required int promptsShown,
    DateTime? lastPrompt,
    required bool positiveMoment,
  }) {
    if (promptsShown >= maxPrompts) return false;
    if (lastPrompt != null && now.difference(lastPrompt).inDays < minDaysBetweenPrompts) {
      return false;
    }
    final age = now.difference(firstLaunch).inDays;
    if (positiveMoment) return age >= minAgeDays && activeDays >= minActiveDays;
    return age >= lateAgeDays && activeDays >= lateActiveDays;
  }
}

/// خدمة طلب تقييم التطبيق بلطف.
///
/// - `markSessionStart()` عند الإقلاع: تسجّل أول فتح وأيام النشاط، وقد تسأل
///   (مسار «الصبر الأطول») إن لم تحدث لحظة رضا.
/// - `onPositiveMoment()` عند اكتمال ورد الختمة: تسأل إن حان الوقت.
/// - الطلب نفسه نافذة Apple/Google الرسمية (لا نافذة مخصّصة، فهي ممنوعة في App Store).
/// - `openWriteReview()` للزر اليدوي في الصفحة الرئيسية.
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const _kFirstMs = 'review_first_ms';
  static const _kActiveDays = 'review_active_days';
  static const _kLastActiveDay = 'review_last_active_day';
  static const _kPrompts = 'review_prompts';
  static const _kLastPromptMs = 'review_last_prompt_ms';
  // قديم: عدّاد جلسات + «سُئل عند العتبة n». يُرحَّل مرة واحدة.
  static const _kLegacyAsked = 'review_asked_at';
  static const _kRated = 'review_rated';
  static const _kCardDismissals = 'review_card_dismissals';
  static const _kCardLastMs = 'review_card_last_ms';

  /// تظهر بطاقة «قيّم التطبيق» في الرئيسية حين يكون ذلك مناسباً.
  final ValueNotifier<bool> cardVisible = ValueNotifier<bool>(false);

  final InAppReview _inAppReview = InAppReview.instance;
  bool _askedThisSession = false;

  /// للاختبار: يستبدل النافذة الحقيقية. يعيد true إن طُلبت فعلاً.
  @visibleForTesting
  Future<bool> Function()? requester;

  /// مهلة استقرار الواجهة قبل الطلب (صفر في الاختبار).
  @visibleForTesting
  Duration settle = const Duration(seconds: 6);

  @visibleForTesting
  void resetForTest() {
    _askedThisSession = false;
    requester = null;
    settle = const Duration(seconds: 6);
    cardVisible.value = false;
  }

  Future<void> refreshCard({DateTime? now}) async {
    try {
      _refreshCardFrom(await SharedPreferences.getInstance(), now ?? DateTime.now());
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ReviewService.refreshCard');
    }
  }

  void _refreshCardFrom(SharedPreferences prefs, DateTime now) {
    final firstMs = prefs.getInt(_kFirstMs);
    final lastMs = prefs.getInt(_kCardLastMs);
    cardVisible.value = firstMs != null &&
        ReviewPolicy.shouldShowCard(
          now: now,
          firstLaunch: DateTime.fromMillisecondsSinceEpoch(firstMs),
          activeDays: prefs.getInt(_kActiveDays) ?? 0,
          rated: prefs.getBool(_kRated) ?? false,
          dismissals: prefs.getInt(_kCardDismissals) ?? 0,
          lastDismissed:
              lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs),
        );
  }

  /// «لاحقاً»: تختفي البطاقة ٣٠ يوماً، وبعد تأجيلين لا تعود.
  Future<void> dismissCard({DateTime? now}) async {
    cardVisible.value = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kCardDismissals, (prefs.getInt(_kCardDismissals) ?? 0) + 1);
      await prefs.setInt(
          _kCardLastMs, (now ?? DateTime.now()).millisecondsSinceEpoch);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ReviewService.dismissCard');
    }
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// تُستدعى من `main()` بعد التهيئة.
  Future<void> markSessionStart({DateTime? now}) async {
    try {
      final t = now ?? DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await _migrateLegacy(prefs, t);

      if (prefs.getInt(_kFirstMs) == null) {
        await prefs.setInt(_kFirstMs, t.millisecondsSinceEpoch);
      }
      final today = _dayKey(t);
      if (prefs.getString(_kLastActiveDay) != today) {
        await prefs.setString(_kLastActiveDay, today);
        await prefs.setInt(_kActiveDays, (prefs.getInt(_kActiveDays) ?? 0) + 1);
      }
      _refreshCardFrom(prefs, t);
      await _maybeAsk(prefs, t, positiveMoment: false);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ReviewService.markSessionStart');
    }
  }

  /// لحظة رضا: اكتمل ورد الختمة اليوم.
  Future<void> onPositiveMoment({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _maybeAsk(prefs, now ?? DateTime.now(), positiveMoment: true);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ReviewService.onPositiveMoment');
    }
  }

  Future<void> _migrateLegacy(SharedPreferences prefs, DateTime now) async {
    if (prefs.containsKey(_kPrompts)) return;
    final legacy = prefs.getInt(_kLegacyAsked) ?? 0;
    if (legacy > 0) {
      // سُئل بالنظام القديم: عُدّ مرة، وابدأ مهلة الـ٩٠ يوماً من الآن.
      await prefs.setInt(_kPrompts, 1);
      await prefs.setInt(_kLastPromptMs, now.millisecondsSinceEpoch);
    }
  }

  Future<void> _maybeAsk(SharedPreferences prefs, DateTime now, {required bool positiveMoment}) async {
    if (_askedThisSession) return;
    final firstMs = prefs.getInt(_kFirstMs);
    if (firstMs == null) return;
    final lastMs = prefs.getInt(_kLastPromptMs);
    final ok = ReviewPolicy.shouldAsk(
      now: now,
      firstLaunch: DateTime.fromMillisecondsSinceEpoch(firstMs),
      activeDays: prefs.getInt(_kActiveDays) ?? 0,
      promptsShown: prefs.getInt(_kPrompts) ?? 0,
      lastPrompt: lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs),
      positiveMoment: positiveMoment,
    );
    if (!ok) return;

    _askedThisSession = true; // لا نكرّر في الجلسة نفسها حتى لو فشل الطلب
    if (settle > Duration.zero) await Future<void>.delayed(settle);
    final shown = await (requester ?? _systemRequest)();
    if (!shown) return;
    await prefs.setInt(_kPrompts, (prefs.getInt(_kPrompts) ?? 0) + 1);
    await prefs.setInt(_kLastPromptMs, now.millisecondsSinceEpoch);
  }

  Future<bool> _systemRequest() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        return true;
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'requestReview');
    }
    return false;
  }

  /// الزر اليدوي «قيّم التطبيق»: على iOS يفتح صفحة كتابة المراجعة مباشرة.
  Future<void> openWriteReview() async {
    cardVisible.value = false;
    try {
      // نعدّ من فتح صفحة التقييم «قيّم»: لا نلحّ عليه بعدها.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRated, true);
    } catch (_) {/* best-effort */}
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await launchUrl(
          Uri.parse('${AppLinks.appStoreUrl}?action=write-review'),
          mode: LaunchMode.externalApplication,
        );
      } else {
        await _inAppReview.openStoreListing(appStoreId: AppLinks.appStoreId);
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'openWriteReview');
    }
  }
}
