import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';
import 'khatma_service.dart';
import 'ruqyah_log_service.dart';

/// بنود برنامج المداومة اليومي (معرّفات ثابتة تُحفظ في الجهاز).
enum ProgramItem {
  morning('morning'),
  ruqyah('ruqyah'),
  wird('wird'),
  evening('evening'),
  sleep('sleep');

  final String id;
  const ProgramItem(this.id);
}

/// اليوم مكتمل حين تُنجز كل البنود (بند الورد يُحتسب تلقائياً إن أتممت ورد الختمة).
bool isProgramDayComplete(Set<ProgramItem> done, {bool wirdFromKhatma = false}) {
  final all = {...done, if (wirdFromKhatma) ProgramItem.wird};
  return ProgramItem.values.every(all.contains);
}

/// قائمة المهام اليومية للمداومة. عند اكتمالها يُسجَّل اليوم في سجل الرقية
/// ([RuqyahLogService]) فيزيد السلسلة نحو هدف ٧/٢١/٤٠ يوماً. لا يُلغى التسجيل
/// تلقائياً إن تراجعت (التسجيل اليدوي في صفحة المتابعة يبقى لك).
class ProgramService extends ChangeNotifier {
  ProgramService._();
  static final ProgramService instance = ProgramService._();

  @visibleForTesting
  ProgramService.test({RuqyahLogService? log, KhatmaService? khatma})
      : _log = log,
        _khatma = khatma;

  static const _key = 'program_done'; // «yyyy-MM-dd:id»
  static const int keepDays = 14;

  RuqyahLogService? _log;
  KhatmaService? _khatma;
  RuqyahLogService get _logSvc => _log ?? RuqyahLogService.instance;
  KhatmaService get _khatmaSvc => _khatma ?? KhatmaService.instance;

  final Set<String> _entries = {};
  Future<void>? _loading;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.get(_key);
      final ids = {for (final i in ProgramItem.values) i.id};
      _entries
        ..clear()
        ..addAll((raw is List ? raw.whereType<String>() : const <String>[])
            .where((e) {
          final parts = e.split(':');
          return parts.length == 2 &&
              RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(parts[0]) &&
              ids.contains(parts[1]);
        }));
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ProgramService.load');
    }
  }

  Set<ProgramItem> doneOn(DateTime day) {
    final k = dayKey(day);
    return {
      for (final i in ProgramItem.values)
        if (_entries.contains('$k:${i.id}')) i,
    };
  }

  bool wirdFromKhatma() => _khatmaSvc.todayDone;

  /// بنود اليوم المنجزة فعلياً (يدوياً أو بورد الختمة).
  Set<ProgramItem> effectiveDone(DateTime day) => {
        ...doneOn(day),
        if (wirdFromKhatma() && dayKey(day) == dayKey(DateTime.now())) ProgramItem.wird,
      };

  bool isComplete(DateTime day) => isProgramDayComplete(effectiveDone(day));

  Future<void> toggle(ProgramItem item, {DateTime? now}) async {
    await ensureLoaded();
    final today = now ?? DateTime.now();
    final e = '${dayKey(today)}:${item.id}';
    if (!_entries.remove(e)) _entries.add(e);
    _prune(today);
    notifyListeners();
    await _save();
    await syncLog(today);
  }

  /// يسجّل اليوم في سجل الرقية إن اكتملت بنوده ولم يكن مسجّلاً.
  Future<void> syncLog([DateTime? now]) async {
    final today = now ?? DateTime.now();
    if (!isComplete(today)) return;
    if (!_logSvc.isLoaded) await _logSvc.load();
    if (!_logSvc.isDone(today)) await _logSvc.toggle(today);
  }

  void _prune(DateTime today) {
    final cutoff = dayKey(DateTime(today.year, today.month, today.day - keepDays));
    _entries.removeWhere((e) => e.substring(0, 10).compareTo(cutoff) < 0);
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_key, _entries.toList()..sort());
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ProgramService.save');
    }
  }
}
