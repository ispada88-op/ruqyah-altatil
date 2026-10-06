import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roqia_altatil/config/app_identity.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/widgets/back_to_home_scope.dart';
import 'package:roqia_altatil/widgets/mini_player.dart';
import 'package:roqia_altatil/widgets/sleep_timer_sheet.dart';
import 'package:roqia_altatil/services/audio_player_service.dart';
import 'package:roqia_altatil/services/whats_new_service.dart';

/// Main shell with bottom navigation bar + persistent mini player.
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    // تنبيه "الجديد في هذا الإصدار" بعد أول إطار (مرة لكل تحديث).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) WhatsNewService.maybeShow(context);
    });
  }

  /// الضغط على تبويب يفتح جذره (فالضغط على التبويب الحالي يعود لقائمته).
  void _onNavItemTapped(int index) => context.go(AppRoutes.tabRoots[index]);

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = AppRoutes.tabOf(path);
    final themeProvider = context.watch<ThemeProvider>();
    // select (لا watch): الـ shell يحتاج حالتين فقط من الصوت؛ watch كان يعيد
    // بناء الـ AppBar وشريط التنقل مع كل تحديث لموضع التشغيل.
    final audioLoaded =
        context.select<AudioPlayerService, bool>((a) => a.isLoaded);
    final hasSleepTimer =
        context.select<AudioPlayerService, bool>((a) => a.hasSleepTimer);
    final isDark = themeProvider.isDarkMode(context);

    // زر الرجوع في أندرويد: خارج الرئيسية يعود إلى الرئيسية بدل إغلاق التطبيق
    // (التنقّل بـ context.go يستبدل المكدّس فلا يبقى شيء ليُفتح للخلف).
    // ومن صفحة فرعية يعود إلى قائمة قسمها (الرقية/الأذكار/المصحف) لا للرئيسية.
    final atHome = path == AppRoutes.home;
    return BackToHomeScope(
      atHome: atHome,
      onBackToHome: () => context.go(AppRoutes.parentOf(path)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppIdentity.name,
            style: AppTextStyles.header(
              color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Sleep timer button (يظهر فقط لما الصوت محمل)
            if (audioLoaded)
              IconButton(
                icon: Icon(
                  hasSleepTimer ? Icons.timer : Icons.timer_outlined,
                  color: hasSleepTimer
                      ? AppColors.accentGold
                      : (isDark ? AppColors.darkTeal : AppColors.primaryTeal),
                ),
                onPressed: () => showSleepTimerSheet(context),
                tooltip: 'مؤقت الإيقاف',
              ),
            // Theme toggle
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
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
                currentIndex: currentIndex,
                onTap: _onNavItemTapped,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'الرئيسية'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.auto_stories_outlined),
                      activeIcon: Icon(Icons.auto_stories),
                      label: 'المصحف'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.healing_outlined),
                      activeIcon: Icon(Icons.healing),
                      label: 'الرقية'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.wb_twilight_outlined),
                      activeIcon: Icon(Icons.wb_twilight),
                      label: 'الأذكار'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.mosque_outlined),
                      activeIcon: Icon(Icons.mosque),
                      label: 'الصلاة'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
