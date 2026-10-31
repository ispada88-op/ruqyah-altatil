import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';

const int kMushafPages = 604;

/// «yyyy-MM-dd» لتاريخ محلي.
String khatmaDayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// عدد الأيام التقويمية بين [a] و[b] (لا تتأثر بتغيير التوقيت الصيفي).
int calendarDaysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;

/// صفحات ورد اليوم: المتبقي مقسوماً على الأيام المتبقية (مقرَّب لأعلى)،
/// فالتأخّر يوزَّع على ما بقي من أيام الختمة بدل أن يضيع.
int khatmaDailyTarget({required int nextPage, required int daysLeft}) {
  final remaining = (kMushafPages - nextPage + 1).clamp(0, kMushafPages);
  if (remaining == 0) return 0;
  final d = daysLeft < 1 ? 1 : daysLeft;
  return (remaining + d - 1) ~/ d;
}

/// وتيرة الخطة: صفحات اليوم لو سارت الخطة بلا تأخّر (من الصفحة [fromPage]
/// على [days] يوماً). تُستعمل سقفاً للورد بعد انتهاء المدة، وللتمديد.
int khatmaPace({required int days, int fromPage = 1}) {
  final remaining = (kMushafPages - fromPage + 1).clamp(1, kMushafPages);
  final d = days < 1 ? 1 : days;
  return (remaining + d - 1) ~/ d;
}

/// مدة بقاء الصفحة ظاهرة قبل أن تُحتسب مقروءة في الختمة.
const Duration kKhatmaDwell = Duration(seconds: 10);

/// يحتسب الصفحة مقروءة بعد بقائها ظاهرة [dwell]؛ التقليب السريع بين الصفحات
/// لا يحتسب شيئاً. [show] يُستدعى عند ظهور صفحة، و[pause] عند خروج التطبيق
/// للخلفية (حتى لا تُحتسب صفحة تُركت مفتوحة والشاشة مقفلة).
class PageDwellTimer {
  PageDwellTimer(this.onRead, {this.dwell = kKhatmaDwell});

  final void Function(int page) onRead;
  final Duration dwell;
  Timer? _timer;

  void show(int page) {
    _timer?.cancel();
    _timer = Timer(dwell, () {
      _timer = null;
      onRead(page);
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => pause();
}

/// ختمة القرآن بخطة يومية: تتقدّم تلقائياً بقراءة الصفحات بالتسلسل في المصحف.
class KhatmaService extends ChangeNotifier {
  KhatmaService._();
  static final KhatmaService instance = KhatmaService._();

  @visibleForTesting
  KhatmaService.test();

  static const durations = [7, 14, 30, 60, 90, 180];

  bool _active = false;
  DateTime _start = DateTime.now();
  int _days = 30;
  int _next = 1; // أول صفحة لم تُقرأ بعد
  int _startPage = 1; // الصفحة التي بدأت منها الخطة
  int _pace = 0; // وتيرة الخطة عند بدئها (٠ = قديمة: تُشتقّ من المدة)
  String _dayKey = '';
  int _dayStart = 1;
  int _dayTarget = 0;
  int _completed = 0;

  /// يوم أُتمّت فيه الختمة كلها (تبقى «ورد اليوم مكتمل» صحيحة بعد إيقافها).
  String _finishedDay = '';
  Future<void>? _loading;

  bool get active => _active;
  int get days => _days;
  int get nextPage => _next.clamp(1, kMushafPages);
  int get completedCount => _completed;
  int get startPage => _startPage;

  /// صفحات اليوم لو سارت الخطة بلا تأخّر. تُثبَّت عند بدء الخطة ولا يغيّرها
  /// التمديد، فلا يظهر عرض التمديد من جديد بعد قبوله.
  int get planPace =>
      _pace > 0 ? _pace : khatmaPace(days: _days, fromPage: _startPage);
  DateTime get startDate => _start;

  /// يُستدعى مرة حين يكتمل ورد اليوم (يُربط بطلب التقييم من main.dart).
  VoidCallback? onTodayCompleted;

  /// تُستدعى حين تبدأ ختمة أو تتوقف (يُربط بإعادة جدولة تذكير الورد من main.dart).
  VoidCallback? onPlanChanged;

  /// أول صفحة وآخر صفحة في ورد اليوم.
  int get todayStartPage => _dayStart;
  int get todayEndPage =>
      (_dayStart + _dayTarget - 1).clamp(_dayStart, kMushafPages);
  int get todayTarget => _dayTarget;

  /// صفحات اليوم المقروءة (0..الهدف).
  int get todayRead => (_next - _dayStart).clamp(0, _dayTarget);
  bool get todayDone =>
      (_finishedDay.isNotEmpty && _finishedDay == _dayKey) ||
      (_active && _dayTarget > 0 && _next > todayEndPage);

  /// مكتمل «اليوم الفعلي» [now]: لا يعتدّ بورد يوم سابق لم يُجدَّد بعد
  /// (التطبيق مفتوح عبر منتصف الليل) — دالة نقية بلا إشعار مستمعين.
  bool todayDoneAt(DateTime now) => khatmaDayKey(now) == _dayKey && todayDone;

  double get progress => ((_next - 1) / kMushafPages).clamp(0.0, 1.0);
  int get pagesLeft => (kMushafPages - _next + 1).clamp(0, kMushafPages);

  /// الأيام المتبقية بعد اليوم (قد تكون سالبة إن تأخّرت عن المدة).
  int daysLeftAfterToday(DateTime now) =>
      _days - calendarDaysBetween(_start, now) - 1;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      int i(String k, int def, int lo, int hi) {
        final v = p.get(k);
        return v is int && v >= lo && v <= hi ? v : def;
      }

      _active = p.get('khatma_active') == true;
      final s = p.get('khatma_start');
      _start = (s is String ? DateTime.tryParse(s) : null) ?? DateTime.now();
      _days = i('khatma_days', 30, 1, 3650);
      _next = i('khatma_next', 1, 1, kMushafPages + 1);
      _startPage = i('khatma_start_page', 1, 1, kMushafPages);
      _pace = i('khatma_pace', 0, 0, kMushafPages);
      final dk = p.get('khatma_day_key');
      _dayKey = dk is String ? dk : '';
      _dayStart = i('khatma_day_start', 1, 1, kMushafPages);
      _dayTarget = i('khatma_day_target', 0, 0, kMushafPages);
      _completed = i('khatma_completed', 0, 0, 10000);
      final fd = p.get('khatma_finished_day');
      _finishedDay = fd is String ? fd : '';
      _rollover(DateTime.now());
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'KhatmaService.load');
    }
  }

  /// يبدأ يوماً جديداً: يثبّت صفحة بداية اليوم وهدفه.
  void _rollover(DateTime now) {
    if (!_active) return;
    final key = khatmaDayKey(now);
    if (key == _dayKey) return;
    final daysLeft = _days - calendarDaysBetween(_start, now);
    _dayKey = key;
    _dayStart = _next.clamp(1, kMushafPages);
    _dayTarget = _targetFor(_next, daysLeft);
    _save();
  }

  /// ورد اليوم من الصفحة [fromPage] وقد بقي [daysLeft] يوماً (مع اليوم).
  /// بعد انتهاء المدة لا يصير الورد كل المتبقي في يوم واحد، بل لا يتجاوز
  /// وتيرة الخطة الأصلية.
  int _targetFor(int fromPage, int daysLeft) {
    if (daysLeft >= 1) {
      return khatmaDailyTarget(nextPage: fromPage, daysLeft: daysLeft);
    }
    final remaining = (kMushafPages - fromPage + 1).clamp(0, kMushafPages);
    final pace = planPace;
    return remaining < pace ? remaining : pace;
  }

  /// هل تأخّرت عن الخطة تأخّراً يستحق عرض التمديد؟ (انتهت المدة وبقي أكثر من
  /// يوم، أو صار ورد اليوم أكثر من ١٫٥ ضعف الوتيرة الأصلية.)
  bool isBehind(DateTime now) {
    if (!_active || _dayTarget == 0) return false;
    if (daysLeftAfterToday(now) < 0) return pagesLeft > planPace;
    return _dayTarget * 2 > planPace * 3;
  }

  /// يمدّ الخطة إلى وتيرتها الأصلية: يُعاد حساب المدة من الصفحات المتبقية، ويبقى
  /// تقدّم اليوم كما هو.
  Future<void> extendToPace({DateTime? now}) async {
    await ensureLoaded();
    if (!_active) return;
    final n = now ?? DateTime.now();
    _rollover(n);
    final elapsed = calendarDaysBetween(_start, n).clamp(0, 3650);
    final remaining = (kMushafPages - _dayStart + 1).clamp(1, kMushafPages);
    final pace = planPace;
    final newLeft = (remaining + pace - 1) ~/ pace;
    _days = (elapsed + newLeft).clamp(1, 3650);
    _dayTarget = _targetFor(_dayStart, _days - elapsed);
    notifyListeners();
    await _save();
  }

  /// للواجهة: يتأكد من يوم اليوم (إن بقي التطبيق مفتوحاً بعد منتصف الليل).
  void refresh([DateTime? now]) {
    final before = _dayKey;
    _rollover(now ?? DateTime.now());
    if (before != _dayKey) notifyListeners();
  }

  /// يبدأ ختمة جديدة بمدة [days] من الصفحة [fromPage].
  Future<void> start(int days, {int fromPage = 1, DateTime? now}) async {
    await ensureLoaded();
    final n = now ?? DateTime.now();
    _active = true;
    _days = days.clamp(1, 3650);
    _start = DateTime(n.year, n.month, n.day);
    _startPage = fromPage.clamp(1, kMushafPages);
    _next = _startPage;
    _pace = khatmaPace(days: _days, fromPage: _startPage);
    _finishedDay = '';
    _dayKey = '';
    _rollover(n);
    notifyListeners();
    await _save();
    onPlanChanged?.call();
  }

  Future<void> stop() async {
    await ensureLoaded();
    _active = false;
    notifyListeners();
    await _save();
    onPlanChanged?.call();
  }

  /// قُرئت صفحة [p] (بقيت ظاهرة في القارئ [kKhatmaDwell]): إن كانت هي المتوقعة
  /// تقدّمت الختمة. (التخطّي بالسحب أو القفز لا يُحتسب قراءةً.)
  Future<void> onPageViewed(int p, {DateTime? now}) async {
    await ensureLoaded();
    if (!_active) return;
    // القارئ قد يبقى مفتوحاً عبر منتصف الليل: ثبّت يوم اليوم قبل أن نتقدّم،
    // وإلا حُسبت صفحات اليوم الجديد على بداية الأمس.
    _rollover(now ?? DateTime.now());
    if (p != _next) return;
    final wasDone = todayDone;
    _next = p + 1;
    if (_next > kMushafPages) _finish();
    notifyListeners();
    await _save();
    if (!wasDone && todayDone) onTodayCompleted?.call();
  }

  void _finish() {
    _completed++;
    _active = false;
    _finishedDay = _dayKey;
  }

  /// يعلّم ورد اليوم مكتملاً (قرأته في مصحف ورقي مثلاً).
  Future<void> completeToday({DateTime? now}) async {
    await ensureLoaded();
    if (!_active) return;
    refresh(now);
    final wasDone = todayDone;
    final end = todayEndPage;
    if (_next <= end) _next = end + 1;
    if (_next > kMushafPages) _finish();
    notifyListeners();
    await _save();
    if (!wasDone && todayDone) onTodayCompleted?.call();
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('khatma_active', _active);
      await p.setString('khatma_start', khatmaDayKey(_start));
      await p.setInt('khatma_days', _days);
      await p.setInt('khatma_next', _next);
      await p.setInt('khatma_start_page', _startPage);
      await p.setInt('khatma_pace', _pace);
      await p.setString('khatma_day_key', _dayKey);
      await p.setInt('khatma_day_start', _dayStart);
      await p.setInt('khatma_day_target', _dayTarget);
      await p.setInt('khatma_completed', _completed);
      await p.setString('khatma_finished_day', _finishedDay);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'KhatmaService.save');
    }
  }
}
