import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/pages/home_page.dart';
import 'package:roqia_altatil/pages/written_roqia_page.dart';
import 'package:roqia_altatil/pages/audio_roqia_page.dart';
import 'package:roqia_altatil/pages/dhikr_page.dart';
import 'package:roqia_altatil/pages/feedback_page.dart';
import 'package:roqia_altatil/widgets/main_shell.dart';

/// GoRouter configuration with bottom navigation shell
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
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
  static const String feedback = '/feedback';
}
