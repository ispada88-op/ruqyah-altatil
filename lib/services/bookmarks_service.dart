import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error_reporter.dart';
import 'mushaf_pages_repository.dart';

/// علامة مرجعية على صفحة من المصحف.
class Bookmark {
  final int page; // 1..604
  final DateTime added;
  const Bookmark(this.page, this.added);
}

/// العلامات المرجعية (صفحات المصحف) — تُحفظ في الجهاز فقط.
class BookmarksService extends ChangeNotifier {
  BookmarksService._();
  static final BookmarksService instance = BookmarksService._();

  /// للاختبارات: نسخة معزولة.
  @visibleForTesting
  BookmarksService.test();

  static const _key = 'mushaf_bookmarks'; // قائمة «صفحة:ميلي_ثانية»
  static const int maxBookmarks = 300;

  final List<Bookmark> _items = [];
  Future<void>? _loading;

  /// الأحدث أولاً.
  List<Bookmark> get items => List.unmodifiable(_items);

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.get(_key);
      final list = raw is List ? raw.whereType<String>() : const <String>[];
      final seen = <int>{};
      final parsed = <Bookmark>[];
      for (final s in list) {
        final parts = s.split(':');
        if (parts.length != 2) continue;
        final page = int.tryParse(parts[0]);
        final ms = int.tryParse(parts[1]);
        if (page == null || ms == null) continue;
        if (page < 1 || page > MushafLayout.pageCount || !seen.add(page)) {
          continue;
        }
        parsed.add(Bookmark(page, DateTime.fromMillisecondsSinceEpoch(ms)));
      }
      parsed.sort((a, b) => b.added.compareTo(a.added));
      _items
        ..clear()
        ..addAll(parsed);
      notifyListeners();
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'BookmarksService.load');
    }
  }

  bool contains(int page) => _items.any((b) => b.page == page);

  /// يضيف العلامة إن لم تكن موجودة وإلا يزيلها. يعيد true إن صارت موجودة.
  Future<bool> toggle(int page, {DateTime? now}) async {
    await ensureLoaded();
    if (page < 1 || page > MushafLayout.pageCount) return contains(page);
    final existing = _items.indexWhere((b) => b.page == page);
    if (existing >= 0) {
      _items.removeAt(existing);
    } else {
      _items.insert(0, Bookmark(page, now ?? DateTime.now()));
      if (_items.length > maxBookmarks) _items.removeLast();
    }
    notifyListeners();
    await _save();
    return existing < 0;
  }

  Future<void> remove(int page) async {
    await ensureLoaded();
    _items.removeWhere((b) => b.page == page);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_key, [
        for (final b in _items) '${b.page}:${b.added.millisecondsSinceEpoch}'
      ]);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'BookmarksService.save');
    }
  }
}
