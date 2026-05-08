import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/widgets/mini_player.dart';
import 'package:roqia_altatil/widgets/sleep_timer_sheet.dart';
import 'package:roqia_altatil/services/audio_player_service.dart';

/// Main shell with bottom navigation bar + persistent mini player.
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.audioRoqia);
        break;
      case 2:
        context.go(AppRoutes.writtenRoqia);
        break;
      case 3:
        context.go(AppRoutes.dhikr);
        break;
      case 4:
        context.go(AppRoutes.feedback);
        break;
    }
  }

  void _updateIndex(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final newIndex = switch (currentPath) {
      AppRoutes.home => 0,
      AppRoutes.audioRoqia => 1,
      AppRoutes.writtenRoqia => 2,
      AppRoutes.dhikr => 3,
      AppRoutes.feedback => 4,
      _ => 0,
    };
    if (_currentIndex != newIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = newIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateIndex(context);
    final themeProvider = context.watch<ThemeProvider>();
    final audio = context.watch<AudioPlayerService>();
    final isDark = themeProvider.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'رقية التعطيل — الشيخ فهد القرني',
          style: AppTextStyles.header(
            color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Sleep timer button (يظهر فقط لما الصوت محمل)
          if (audio.isLoaded)
            IconButton(
              icon: Icon(
                audio.hasSleepTimer ? Icons.bedtime : Icons.bedtime_outlined,
                color: audio.hasSleepTimer
                    ? AppColors.accentGold
                    : (isDark ? AppColors.darkTeal : AppColors.primaryTeal),
              ),
              onPressed: () => showSleepTimerSheet(context),
              tooltip: 'مؤقت الإيقاف',
            ),
          // Theme toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
            ),
            onPressed: () => themeProvider.toggleTheme(context),
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player يظهر تلقائياً عندما الصوت محمل
          const MiniPlayer(),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavItemTapped,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.headphones), label: 'الرقية الصوتية'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book), label: 'الرقية المكتوبة'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.circle_outlined), label: 'الأذكار'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline), label: 'اقتراحات'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
