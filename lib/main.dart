import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roqia_altatil/services/audio_player_service.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/services/review_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/onboarding_page.dart';

Future<void> main() async {
  await ErrorReporter.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Background audio - لازم يكون قبل أي AudioPlayer
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.ruqyah.altatil.audio',
        androidNotificationChannelName: 'تشغيل الرقية',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'JustAudioBackground.init');
    }

    // Audio session config
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'AudioSession init');
    }

    // Theme provider — pre-loaded
    final themeProvider = ThemeProvider();
    await themeProvider.load();

    // Notification service — initialized but not enabled (user opts in)
    await NotificationService.instance.initialize();

    // Audio player service
    await AudioPlayerService.instance.initialize();

    // Track session for review prompt (best-effort, fire-and-forget)
    // ignore: discarded_futures
    ReviewService.instance.markSessionStart();

    runApp(RuqyahApp(themeProvider: themeProvider));
  });
}

class RuqyahApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  const RuqyahApp({super.key, required this.themeProvider});

  @override
  State<RuqyahApp> createState() => _RuqyahAppState();
}

class _RuqyahAppState extends State<RuqyahApp> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      if (!mounted) return;
      setState(() {
        _showOnboarding = !onboardingComplete;
        _isLoading = false;
      });
    } catch (e, st) {
      ErrorReporter.report(e, st, context: '_checkOnboarding');
      if (mounted) {
        setState(() {
          _showOnboarding = false;
          _isLoading = false;
        });
      }
    }
  }

  void _completeOnboarding() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider.value(value: AudioPlayerService.instance),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: 'رقية التعطيل',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: theme.themeMode,
            routerConfig: AppRouter.router,
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            builder: (context, child) {
              if (_isLoading) return _buildSplashScreen();
              if (_showOnboarding) {
                return ErrorBoundary(
                  child: OnboardingPage(onComplete: _completeOnboarding),
                );
              }
              return ErrorBoundary(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'رقية التعطيل',
              style: AppTextStyles.header(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'جاري التحميل...',
              style: AppTextStyles.caption(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
