import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/pages/home_page.dart';
import 'package:roqia_altatil/pages/written_roqia_page.dart';
import 'package:roqia_altatil/pages/audio_roqia_page.dart';
import 'package:roqia_altatil/pages/dhikr_page.dart';
import 'package:roqia_altatil/pages/feedback_page.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:roqia_altatil/pages/tahseen_page.dart';
import 'package:roqia_altatil/pages/adhkar_page.dart';
import 'package:roqia_altatil/pages/mushaf_pages.dart';
import 'package:roqia_altatil/pages/reminders_page.dart';
import 'package:roqia_altatil/pages/ruqyah_tracker_page.dart';
import 'package:roqia_altatil/pages/ruqyah_types_page.dart';
import 'package:roqia_altatil/widgets/main_shell.dart';

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
            path: AppRoutes.writtenRoqia,
            name: 'written-roqia',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const WrittenRoqiaPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.audioRoqia,
            name: 'audio-roqia',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AudioRoqiaPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.dhikr,
            name: 'dhikr',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DhikrPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.tahseen,
            name: 'tahseen',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TahseenPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.generalRuqyah,
            name: 'general-ruqyah',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const GeneralRuqyahPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.adhkar,
            name: 'adhkar',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AdhkarPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.ruqyahTypes,
            name: 'ruqyah-types',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RuqyahTypesPage(),
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
            path: AppRoutes.mushaf,
            name: 'mushaf',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MushafIndexPage(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
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
              child: const RuqyahTrackerPage(),
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
              child: const FeedbackPage(),
              transitionsBuilder: _fadeSlideTransition,
            ),
          ),
        ],
      ),
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

  static const Set<String> all = {
    home, writtenRoqia, audioRoqia, dhikr, tahseen, generalRuqyah, feedback,
    adhkar, ruqyahTypes, mushaf, tracker, reminders,
  };

  /// أنواع «رقى حسب الحالة» المعروفة للمسار /ruqyah-types/:type.
  static const Set<String> ruqyahTypeIds = {'sihr', 'ayn', 'hamm'};

  static String ruqyahType(String id) => '$ruqyahTypes/$id';

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
    final type = RegExp(r'^/ruqyah-types/([a-z]+)$').firstMatch(p);
    if (type != null) {
      return ruqyahTypeIds.contains(type.group(1)) ? (p == path ? null : p) : ruqyahTypes;
    }
    return aliases[p] ?? home;
  }
}
