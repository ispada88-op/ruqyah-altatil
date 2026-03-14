import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/nav.dart';

/// Main shell with bottom navigation bar
class MainShell extends StatefulWidget {
  final Widget child;
  
  const MainShell({
    super.key,
    required this.child,
  });

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
    int newIndex = 0;
    
    if (currentPath == AppRoutes.home) {
      newIndex = 0;
    } else if (currentPath == AppRoutes.audioRoqia) {
      newIndex = 1;
    } else if (currentPath == AppRoutes.writtenRoqia) {
      newIndex = 2;
    } else if (currentPath == AppRoutes.dhikr) {
      newIndex = 3;
    } else if (currentPath == AppRoutes.feedback) {
      newIndex = 4;
    }
    
    if (_currentIndex != newIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateIndex(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'رقية التعطيل — الشيخ فهد القرني',
          style: AppTextStyles.header(
            color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: Container(
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headphones),
              label: 'الرقية الصوتية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'الرقية المكتوبة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_outlined),
              label: 'الأذكار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'اقتراحات',
            ),
          ],
        ),
      ),
    );
  }
}
