import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/pages/home_page.dart';
import 'package:roqia_altatil/pages/written_roqia_page.dart';
import 'package:roqia_altatil/pages/audio_roqia_page.dart';
import 'package:roqia_altatil/pages/dhikr_page.dart';
import 'package:roqia_altatil/pages/feedback_page.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:roqia_altatil/pages/tahseen_page.dart';
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

  static const Set<String> all = {
    home, writtenRoqia, audioRoqia, dhikr, tahseen, generalRuqyah, feedback,
  };

  /// Short / legacy paths → canonical route (e.g. shortcuts shipped as
  /// `ruqyah://audio` before 1.0.5).
  static const Map<String, String> aliases = {
    '': home,
    '/audio': audioRoqia,
    '/written': writtenRoqia,
    '/kursi': writtenRoqia,
    '/ruqyah': generalRuqyah,
  };

  /// Returns the path to redirect to, or null when [path] is already canonical.
  static String? normalize(String path) {
    var p = path.trim();
    if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
    if (all.contains(p)) return p == path ? null : p;
    return aliases[p] ?? home;
  }
}
