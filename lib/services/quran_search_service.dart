import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/arabic_search.dart';
import 'error_reporter.dart';

/// فهرس البحث في القرآن — من نص «تنزيل» البسيط المضمَّن حرفياً
/// (`assets/quran/quran-simple-tanzil.txt`، بصمته مثبّتة في الاختبارات).
/// يُبنى مرة واحدة في isolate عند أول بحث.
class QuranSearchService {
  QuranSearchService._();
  static final QuranSearchService instance = QuranSearchService._();

  static const assetPath = 'assets/quran/quran-simple-tanzil.txt';

  Future<List<SearchVerse>>? _index;

  Future<List<SearchVerse>> index() => _index ??= () async {
        try {
          final raw = await rootBundle.loadString(assetPath);
          return await compute(parseTanzilForSearch, raw);
        } catch (e, st) {
          ErrorReporter.report(e, st, context: 'QuranSearch.index');
          _index = null;
          rethrow;
        }
      }();

  Future<SearchResults> search(String query, {int limit = 100}) async =>
      searchVerses(await index(), query, limit: limit);
}
