import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/onboarding_page.dart';

final AudioPlayer appAudioPlayer = AudioPlayer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🔥 main() started');

  runApp(const RuqyahApp());
  debugPrint('🚀 runApp() called');
}

class RuqyahApp extends StatefulWidget {
  const RuqyahApp({super.key});

  @override
  State<RuqyahApp> createState() => _RuqyahAppState();
}

class _RuqyahAppState extends State<RuqyahApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
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
      setState(() {
        _showOnboarding = !onboardingComplete;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking onboarding: $e');
      setState(() {
        _showOnboarding = false;
        _isLoading = false;
      });
    }
  }

  void _completeOnboarding() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _themeProvider,
      child: MaterialApp.router(
        title: 'رقية التعطيل',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeProvider.themeMode,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          if (_isLoading) {
            return _buildSplashScreen();
          }
          if (_showOnboarding) {
            return OnboardingPage(onComplete: _completeOnboarding);
          }
          return child ?? const SizedBox.shrink();
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
              child: const Icon(
                Icons.spa,
                size: 50,
                color: Colors.white,
              ),
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
