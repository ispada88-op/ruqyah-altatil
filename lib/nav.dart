import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/data/adhkar_data.dart';
import 'package:roqia_altatil/pages/home_page.dart';
import 'package:roqia_altatil/pages/written_roqia_page.dart';
import 'package:roqia_altatil/pages/audio_roqia_page.dart';
import 'package:roqia_altatil/pages/dhikr_page.dart';
import 'package:roqia_altatil/pages/feedback_page.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:roqia_altatil/pages/tahseen_page.dart';
import 'package:roqia_altatil/pages/adhkar_page.dart';
import 'package:roqia_altatil/pages/after_prayer_page.dart';
import 'package:roqia_altatil/pages/bookmarks_page.dart';
import 'package:roqia_altatil/pages/khatma_page.dart';
import 'package:roqia_altatil/pages/quran_search_page.dart';
import 'package:roqia_altatil/pages/mushaf_page_reader.dart';
import 'package:roqia_altatil/pages/mushaf_pages.dart';
import 'package:roqia_altatil/pages/prayer_times_page.dart';
import 'package:roqia_altatil/pages/program_page.dart';
import 'package:roqia_altatil/pages/qibla_page.dart';
import 'package:roqia_altatil/pages/reminders_page.dart';
import 'package:roqia_altatil/pages/ruqyah_rules_page.dart';
import 'package:roqia_altatil/pages/ruqyah_tracker_page.dart';
import 'package:roqia_altatil/pages/ruqyah_types_page.dart';
import 'package:roqia_altatil/pages/section_hubs.dart';
import 'package:roqia_altatil/pages/verse_card_page.dart';
import 'package:roqia_altatil/widgets/main_shell.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// GoRouter configuration with bottom navigation shell
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    // Deep links (Android app shortcuts, ruqyah://open/<route>) and any old or
    // short path are normalised here; unknown paths fall back to home instead
    // of GoRouter's red "page not found" screen.
    redirect: (context, state) => AppRoutes.normalize(state.uri.path),
    onException: (context, state, router) => router.go(AppRoutes.home),
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.ruqyahHub,
            name: 'ruqyah-hub',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RuqyahHubPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.adhkarHub,
            name: 'adhkar-hub',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AdhkarHubPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.writtenRoqia,
            name: 'written-roqia',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('رقية التعطيل — مكتوبة', AppRoutes.ruqyahHub, const WrittenRoqiaPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.audioRoqia,
            name: 'audio-roqia',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('رقية التعطيل — صوتية', AppRoutes.ruqyahHub, const AudioRoqiaPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.dhikr,
            name: 'dhikr',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('عدّاد التسبيح', AppRoutes.adhkarHub, const DhikrPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.tahseen,
            name: 'tahseen',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('أذكار التحصين', AppRoutes.adhkarHub, const TahseenPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.generalRuqyah,
            name: 'general-ruqyah',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('الرقية المستقلة', AppRoutes.ruqyahHub, const GeneralRuqyahPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.adhkar,
            name: 'adhkar',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub(
                'أذكار الصباح والمساء',
                AppRoutes.adhkarHub,
                AdhkarPage(
                  initial: switch (state.uri.queryParameters['time']) {
                    'morning' => AdhkarTime.morning,
                    'evening' => AdhkarTime.evening,
                    _ => null,
                  },
                ),
              ),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.ruqyahTypes,
            name: 'ruqyah-types',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('رقى حسب الحالة', AppRoutes.ruqyahHub, const RuqyahTypesPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
            routes: [
              GoRoute(
                path: ':type',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: RuqyahTypePage(typeId: state.pathParameters['type'] ?? ''),
                  transitionsBuilder: _fadeSlideTransition,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.prayerTimes,
            name: 'prayer-times',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PrayerTimesPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.afterPrayer,
            name: 'after-prayer',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('أذكار بعد الصلاة', AppRoutes.adhkarHub, const AfterPrayerPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.khatma,
            name: 'khatma',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const KhatmaPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.bookmarks,
            name: 'bookmarks',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BookmarksPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.quranSearch,
            name: 'quran-search',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const QuranSearchPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.ruqyahRules,
            name: 'ruqyah-rules',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RuqyahRulesPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.program,
            name: 'program',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProgramPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.verseCard,
            name: 'verse-card',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: VerseCardPage(
                surah: int.tryParse(state.uri.queryParameters['s'] ?? '') ?? 0,
                ayah: int.tryParse(state.uri.queryParameters['a'] ?? '') ?? 0,
              ),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.qibla,
            name: 'qibla',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const QiblaPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.mushaf,
            name: 'mushaf',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MushafIndexPage(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'page/:n',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: MushafPageReaderPage(
                    page: int.tryParse(state.pathParameters['n'] ?? '') ?? 1,
                  ),
                  transitionsBuilder: _fadeSlideTransition,
                ),
              ),
              GoRoute(
                path: ':surah',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: MushafReaderPage(
                    surah: int.tryParse(state.pathParameters['surah'] ?? '') ?? 1,
                    ayah: int.tryParse(state.uri.queryParameters['ayah'] ?? ''),
                    resume: state.uri.queryParameters['resume'] == '1',
                  ),
                  transitionsBuilder: _fadeSlideTransition,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.tracker,
            name: 'ruqyah-tracker',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('متابعة أيام الرقية', AppRoutes.ruqyahHub, const RuqyahTrackerPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.reminders,
            name: 'reminders',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RemindersPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.feedback,
            name: 'feedback',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: _sub('اقتراحات', AppRoutes.home, const FeedbackPage()),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
        ],
      ),
    ],
  );
  
  /// صفحة فرعية بشريط رجوع إلى قائمتها (الصفحات التي بلا شريط خاص بها).
  static Widget _sub(String title, String fallbackRoute, Widget page) => Column(
        children: [
          SectionBackBar(title: title, fallbackRoute: fallbackRoute),
          Expanded(child: page),
        ],
      );

  // Fade transition
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  // Fade + Slide transition
  static Widget _fadeSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.05, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    
    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Route path constants
class AppRoutes {
  static const String home = '/';
  static const String writtenRoqia = '/written-roqia';
  static const String audioRoqia = '/audio-roqia';
  static const String dhikr = '/dhikr';
  static const String tahseen = '/tahseen';
  static const String generalRuqyah = '/general-ruqyah';
  static const String feedback = '/feedback';
  static const String adhkar = '/adhkar';
  static const String ruqyahTypes = '/ruqyah-types';
  static const String mushaf = '/mushaf';
  static const String tracker = '/ruqyah-tracker';
  static const String reminders = '/reminders';
  static const String prayerTimes = '/prayer-times';
  static const String qibla = '/qibla';
  static const String afterPrayer = '/after-prayer';
  static const String khatma = '/khatma';
  static const String bookmarks = '/bookmarks';
  static const String quranSearch = '/quran-search';
  static const String ruqyahRules = '/ruqyah-rules';
  static const String program = '/program';
  static const String verseCard = '/verse-card';

  /// قائمتا القسمين الجديدتان (الرقية، الأذكار) — تبويبان في الشريط السفلي.
  static const String ruqyahHub = '/hub/ruqyah';
  static const String adhkarHub = '/hub/adhkar';

  /// بطاقة الآية ([surah]:[ayah]) للمشاركة كصورة.
  static String verseCardFor(int surah, int ayah) => '$verseCard?s=$surah&a=$ayah';

  /// صفحة بداية سورة الكهف في مصحف المدينة (يثبّتها اختبار mushaf_pages_test).
  static const int kKahfPage = 293;

  static const Set<String> all = {
    home, writtenRoqia, audioRoqia, dhikr, tahseen, generalRuqyah, feedback,
    adhkar, ruqyahTypes, mushaf, tracker, reminders, prayerTimes, qibla, afterPrayer,
    khatma, bookmarks, quranSearch, ruqyahRules, program, verseCard,
    ruqyahHub, adhkarHub,
  };

  /// جذور تبويبات الشريط السفلي بالترتيب: الرئيسية، المصحف، الرقية، الأذكار،
  /// الصلاة (المواقيت وفيها القبلة وأذكار بعد الصلاة).
  static const List<String> tabRoots = [
    home,
    mushaf,
    ruqyahHub,
    adhkarHub,
    prayerTimes,
  ];

  /// رقم التبويب الذي تنتمي إليه [path] (٠ = الرئيسية وما لا قسم له).
  static int tabOf(String path) {
    if (path == mushaf || path.startsWith('$mushaf/')) return 1;
    if (path.startsWith('$ruqyahTypes/')) return 2;
    return switch (path) {
      khatma || bookmarks || quranSearch || verseCard => 1,
      ruqyahHub ||
      writtenRoqia ||
      audioRoqia ||
      generalRuqyah ||
      ruqyahTypes ||
      ruqyahRules ||
      program ||
      tracker =>
        2,
      adhkarHub || adhkar || afterPrayer || dhikr || tahseen || reminders => 3,
      prayerTimes || qibla => 4,
      _ => 0,
    };
  }

  /// أين يعود زر الرجوع (أندرويد) من [path]: قائمة القسم للصفحات الفرعية،
  /// والرئيسية لجذور التبويبات.
  static String parentOf(String path) {
    if (tabRoots.contains(path)) return home;
    final tab = tabOf(path);
    return tab == 0 ? home : tabRoots[tab];
  }

  /// أنواع «رقى حسب الحالة» المعروفة للمسار /ruqyah-types/:type.
  static const Set<String> ruqyahTypeIds = {'sihr', 'ayn', 'hamm'};

  static String ruqyahType(String id) => '$ruqyahTypes/$id';

  /// مسار أذكار الصباح أو المساء مباشرة (يُستعمل عند الضغط على الإشعار).
  static String adhkarAt(AdhkarTime t) => '$adhkar?time=${t.name}';

  /// المسار الذي يُفتح عند الضغط على إشعار بحمولة [payload]، أو null إن لم
  /// تكن حمولة معروفة (إشعارات الأذكار الدورية بلا حمولة فتفتح الرئيسية).
  static String? fromNotificationPayload(String? payload) => switch (payload) {
        'adhkar:morning' => adhkarAt(AdhkarTime.morning),
        'adhkar:evening' => adhkarAt(AdhkarTime.evening),
        'prayer' => prayerTimes,
        'afterprayer' => afterPrayer,
        'kahf' => mushafPage(kKahfPage),
        'sleep' => tahseen,
        _ => null,
      };

  /// قارئ المصحف بالصفحات (١..٦٠٤).
  static String mushafPage(int page) => '$mushaf/page/$page';

  static String mushafSurah(int surah, {int? ayah, bool resume = false}) {
    final q = <String>[
      if (ayah != null) 'ayah=$ayah',
      if (resume) 'resume=1',
    ];
    return '$mushaf/$surah${q.isEmpty ? '' : '?${q.join('&')}'}';
  }

  /// Short / legacy paths → canonical route (e.g. shortcuts shipped as
  /// `ruqyah://audio` before 1.0.5).
  static const Map<String, String> aliases = {
    '': home,
    '/audio': audioRoqia,
    '/written': writtenRoqia,
    '/kursi': writtenRoqia,
    '/ruqyah': generalRuqyah,
    '/quran': mushaf,
    '/azkar': adhkar,
  };

  /// Returns the path to redirect to, or null when [path] is already canonical.
  static String? normalize(String path) {
    var p = path.trim();
    if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
    if (all.contains(p)) return p == path ? null : p;
    final surah = RegExp(r'^/mushaf/(\d{1,3})$').firstMatch(p);
    if (surah != null) {
      final n = int.parse(surah.group(1)!);
      return n >= 1 && n <= 114 ? (p == path ? null : p) : mushaf;
    }
    final pg = RegExp(r'^/mushaf/page/(\d{1,3})$').firstMatch(p);
    if (pg != null) {
      final n = int.parse(pg.group(1)!);
      return n >= 1 && n <= 604 ? (p == path ? null : p) : mushaf;
    }
    final type = RegExp(r'^/ruqyah-types/([a-z]+)$').firstMatch(p);
    if (type != null) {
      return ruqyahTypeIds.contains(type.group(1)) ? (p == path ? null : p) : ruqyahTypes;
    }
    return aliases[p] ?? home;
  }
}
