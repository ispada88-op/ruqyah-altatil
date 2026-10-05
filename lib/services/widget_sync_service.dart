import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'error_reporter.dart';
import 'khatma_service.dart';
import 'prayer_times_service.dart';

/// نسخة صيغة اللقطة — يقرؤها الودجت (ios/PrayerWidget/WidgetSnapshot.swift).
const int kWidgetSnapshotVersion = 1;

/// الأيام المرسلة: أمس (لحساب «منذ آخر أذان» بعد الفجر) واليوم و٨ أيام قادمة.
/// إن لم يُفتح التطبيق أكثر من ثمانية أيام يطلب الودجت فتحه.
const int kWidgetDaysBefore = 1;
const int kWidgetDaysAhead = 8;

int _epochSeconds(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

/// ورد اليوم للودجت. يستدعي المرسِل [KhatmaService.refresh] قبلها حتى يكون يوم
/// الورد هو اليوم الفعلي.
Map<String, dynamic> wirdPayload(KhatmaService k, DateTime now) => {
      'on': k.active,
      'day': khatmaDayKey(now),
      'page': k.nextPage,
      'start': k.todayStartPage,
      'end': k.todayEndPage,
      'target': k.todayTarget,
      'read': k.todayRead,
      'done': k.todayDoneAt(now),
      'prog': double.parse(k.progress.toStringAsFixed(4)),
      'left': k.daysLeftAfterToday(now).clamp(0, 100000),
      'fin': k.completedCount,
    };

/// لقطة الودجت: أوقات الصلاة لعدة أيام (ثوانٍ منذ 1970) + ورد الختمة.
///
/// ترتيب الأوقات الستة في كل يوم = ترتيب [PrayerKind]: الفجر، الشروق، الظهر،
/// العصر، المغرب، العشاء (يثبّته اختبار — Swift يعتمد عليه). لا إحداثيات هنا
/// أبداً: اسم المدينة فقط، والموقع لا يغادر التطبيق.
Map<String, dynamic> buildWidgetPayload({
  required DateTime now,
  required String city,
  required PrayerDay? Function(DateTime date) dayFor,
  required KhatmaService khatma,
}) {
  final days = <Map<String, dynamic>>[];
  for (var off = -kWidgetDaysBefore; off <= kWidgetDaysAhead; off++) {
    final date = DateTime(now.year, now.month, now.day + off);
    final day = dayFor(date);
    if (day == null) continue;
    days.add({
      'd': khatmaDayKey(date),
      't': [for (final k in PrayerKind.values) _epochSeconds(day[k])],
    });
  }
  return {
    'v': kWidgetSnapshotVersion,
    'gen': _epochSeconds(now),
    'city': city,
    'days': days,
    'wird': wirdPayload(khatma, now),
  };
}

/// يدفع لقطة الودجت إلى iOS (Keychain مشترك) كلما تغيّر الموقع/المواقيت أو
/// الختمة، وعند عودة التطبيق. على غير iOS لا يفعل شيئاً.
class WidgetSyncService {
  WidgetSyncService._()
      : _send = _channelSend,
        _enabled = _onIos,
        _khatma = KhatmaService.instance,
        _debounce = const Duration(seconds: 2);

  static final WidgetSyncService instance = WidgetSyncService._();

  @visibleForTesting
  WidgetSyncService.test({
    required Future<bool> Function(String json) send,
    bool enabled = true,
    KhatmaService? khatma,
    Duration debounce = Duration.zero,
  })  : _send = send,
        _enabled = (() => enabled),
        _khatma = khatma ?? KhatmaService.instance,
        _debounce = debounce;

  static const MethodChannel _channel =
      MethodChannel('com.ruqyah.altatil/widget');

  static Future<bool> _channelSend(String json) async =>
      (await _channel.invokeMethod<bool>('update', json)) ?? false;

  static bool _onIos() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  final Future<bool> Function(String json) _send;
  final bool Function() _enabled;
  final KhatmaService _khatma;
  final Duration _debounce;

  Timer? _timer;
  String? _lastKey;
  bool _attached = false;
  Future<void> _tail = Future<void>.value();

  /// يبدأ الاستماع لتغيّر المواقيت والختمة (مرة واحدة) ويرسل أول لقطة.
  void attach() {
    if (_attached) return;
    _attached = true;
    PrayerTimesService.instance.addListener(_schedule);
    _khatma.addListener(_schedule);
    _schedule();
  }

  /// يوقف الاستماع (للاختبارات).
  @visibleForTesting
  void detach() {
    if (!_attached) return;
    _attached = false;
    PrayerTimesService.instance.removeListener(_schedule);
    _khatma.removeListener(_schedule);
    _timer?.cancel();
  }

  void _schedule() {
    if (!_enabled()) return;
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      // ignore: discarded_futures
      sync();
    });
  }

  /// يرسل اللقطة الآن إن تغيّر شيء عن آخر إرسال ناجح ([force] يتجاوز المقارنة).
  Future<void> sync({DateTime? now, bool force = false}) {
    if (!_enabled()) return Future<void>.value();
    _timer?.cancel();
    final at = now ?? DateTime.now();
    // سلسلة واحدة: لا إرسالان متداخلان فتتكرر المقارنة على حالة قديمة.
    return _tail = _tail.then((_) => _run(at, force));
  }

  Future<void> _run(DateTime now, bool force) async {
    try {
      await _khatma.ensureLoaded();
      _khatma.refresh(now);
      final prayers = PrayerTimesService.instance;
      final payload = buildWidgetPayload(
        now: now,
        city: prayers.label,
        dayFor: prayers.dayFor,
        khatma: _khatma,
      );
      // «gen» يتغيّر كل مرة: لا يدخل في المقارنة.
      final key = jsonEncode(Map<String, dynamic>.of(payload)..remove('gen'));
      if (!force && key == _lastKey) return;
      final ok = await _send(jsonEncode(payload));
      if (ok) _lastKey = key;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'WidgetSyncService.sync');
    }
  }
}
