import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// PROFESSIONAL COLOR PALETTE
// =============================================================================

class AppColors {
  // Primary: Deep Teal
  static const Color primaryTeal = Color(0xFF006B6B);
  static const Color primaryTealLight = Color(0xFF008B8B);
  static const Color primaryTealDark = Color(0xFF004B4B);
  
  // Accent: Gold
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFE5C158);
  static const Color accentGoldDark = Color(0xFFB8941F);
  
  // Background: Soft Cream
  static const Color backgroundCream = Color(0xFFF5F5DC);
  static const Color backgroundCreamLight = Color(0xFFFFFEF0);
  static const Color backgroundCreamDark = Color(0xFFE8E8D0);
  
  // Dark Mode
  static const Color darkPrimary = Color(0xFF1A1A2E);
  static const Color darkSecondary = Color(0xFF16213E);
  static const Color darkSurface = Color(0xFF0F0F1E);
  static const Color darkTeal = Color(0xFF4DA6A6);
  
  // Semantic Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);
  
  // Neutral Colors (WCAG AAA compliant)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFAFAFA);
  static const Color textOnDarkSecondary = Color(0xFFE0E0E0);
}

// =============================================================================
// SPACING & SIZING
// =============================================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;
}

// =============================================================================
// TYPOGRAPHY (Amiri for Arabic, Inter for English)
// =============================================================================

class AppTextStyles {
  // Header styles (24sp)
  static TextStyle header({Color? color}) => GoogleFonts.amiri(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.6,
    color: color ?? AppColors.textPrimary,
  );
  
  // Subheader styles (18sp)
  static TextStyle subheader({Color? color}) => GoogleFonts.amiri(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.6,
    color: color ?? AppColors.textPrimary,
  );
  
  // Body styles (16sp)
  static TextStyle body({Color? color}) => GoogleFonts.amiri(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: color ?? AppColors.textPrimary,
  );
  
  // Caption styles (14sp)
  static TextStyle caption({Color? color}) => GoogleFonts.amiri(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: color ?? AppColors.textSecondary,
  );
  
  // Quran text (larger, elegant)
  static TextStyle quran({Color? color, double? fontSize}) => GoogleFonts.amiri(
    fontSize: fontSize ?? 20,
    fontWeight: FontWeight.w500,
    height: 1.8,
    color: color ?? AppColors.textPrimary,
  );
}

// =============================================================================
// LIGHT THEME
// =============================================================================

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  
  // Color Scheme
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryTeal,
    primaryContainer: AppColors.primaryTealLight,
    secondary: AppColors.accentGold,
    secondaryContainer: AppColors.accentGoldLight,
    surface: Colors.white,
    surfaceContainerHighest: AppColors.backgroundCream,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
    outline: AppColors.textTertiary,
  ),
  
  scaffoldBackgroundColor: AppColors.backgroundCream,
  
  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primaryTeal,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.header(color: AppColors.primaryTeal),
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    elevation: AppElevation.md,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    color: Colors.white,
    shadowColor: Colors.black.withValues(alpha: 0.1),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: Colors.white,
      elevation: AppElevation.md,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      minimumSize: const Size(48, 48),
      textStyle: AppTextStyles.body(color: Colors.white).copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  
  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.primaryTeal,
    size: 24,
  ),
  
  // Floating Action Button Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentGold,
    foregroundColor: Colors.white,
    elevation: AppElevation.lg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primaryTeal,
    unselectedItemColor: AppColors.textTertiary,
    selectedLabelStyle: AppTextStyles.caption(color: AppColors.primaryTeal),
    unselectedLabelStyle: AppTextStyles.caption(color: AppColors.textTertiary),
    type: BottomNavigationBarType.fixed,
    elevation: AppElevation.lg,
  ),
  
  // Text Theme
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.header(),
    headlineMedium: AppTextStyles.subheader(),
    bodyLarge: AppTextStyles.body(),
    bodyMedium: AppTextStyles.body(),
    bodySmall: AppTextStyles.caption(),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.textTertiary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.textTertiary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  
  // Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.textTertiary.withValues(alpha: 0.2),
    thickness: 1,
    space: 1,
  ),
  
  // Progress Indicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primaryTeal,
  ),
);

// =============================================================================
// DARK THEME
// =============================================================================

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  // Color Scheme
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkTeal,
    primaryContainer: AppColors.primaryTealDark,
    secondary: AppColors.accentGold,
    secondaryContainer: AppColors.accentGoldDark,
    surface: AppColors.darkSecondary,
    surfaceContainerHighest: AppColors.darkSurface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: AppColors.textOnDark,
    onSurface: AppColors.textOnDark,
    onError: Colors.white,
    outline: AppColors.textOnDarkSecondary,
  ),
  
  scaffoldBackgroundColor: AppColors.darkPrimary,
  
  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.darkTeal,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.header(color: AppColors.darkTeal),
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    elevation: AppElevation.md,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    color: AppColors.darkSecondary,
    shadowColor: Colors.black.withValues(alpha: 0.5),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkTeal,
      foregroundColor: Colors.white,
      elevation: AppElevation.md,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      minimumSize: const Size(48, 48),
      textStyle: AppTextStyles.body(color: Colors.white).copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  
  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.darkTeal,
    size: 24,
  ),
  
  // Floating Action Button Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentGold,
    foregroundColor: Colors.white,
    elevation: AppElevation.lg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSecondary,
    selectedItemColor: AppColors.darkTeal,
    unselectedItemColor: AppColors.textTertiary,
    selectedLabelStyle: AppTextStyles.caption(color: AppColors.darkTeal),
    unselectedLabelStyle: AppTextStyles.caption(color: AppColors.textTertiary),
    type: BottomNavigationBarType.fixed,
    elevation: AppElevation.lg,
  ),
  
  // Text Theme
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.header(color: AppColors.textOnDark),
    headlineMedium: AppTextStyles.subheader(color: AppColors.textOnDark),
    bodyLarge: AppTextStyles.body(color: AppColors.textOnDark),
    bodyMedium: AppTextStyles.body(color: AppColors.textOnDark),
    bodySmall: AppTextStyles.caption(color: AppColors.textOnDarkSecondary),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.textOnDarkSecondary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.textOnDarkSecondary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.darkTeal, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  
  // Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.textOnDarkSecondary.withValues(alpha: 0.2),
    thickness: 1,
    space: 1,
  ),
  
  // Progress Indicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.darkTeal,
  ),
);

// =============================================================================
// THEME PROVIDER
// =============================================================================

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
