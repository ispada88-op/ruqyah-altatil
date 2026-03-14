import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'theme.dart';
import 'nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background audio init wrapped in try-catch so a service failure
  // never blocks the UI or causes ANR on release builds.
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.roqia.altatil.audio',
      androidNotificationChannelName: 'رقية التعطيل لشيخ فهد القرني',
      androidNotificationOngoing: true,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () { if (kDebugMode) debugPrint('⚠️ JustAudioBackground init timed out'); },
    );
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ JustAudioBackground init failed: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'رقية التعطيل لشيخ فهد القرني',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Navigation
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
