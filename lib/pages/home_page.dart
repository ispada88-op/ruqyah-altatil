import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/share_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/widgets/notifications_settings_card.dart';

/// Enhanced home page with professional design.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkPrimary, AppColors.darkSurface]
                : [AppColors.backgroundCreamLight, AppColors.backgroundCream],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Welcome Section
                Container(
                  padding: AppSpacing.paddingXl,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.darkSecondary, AppColors.darkSurface]
                          : [Colors.white, AppColors.backgroundCreamLight],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.darkTeal, AppColors.accentGold]
                                : [AppColors.primaryTeal, AppColors.accentGold],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                                  .withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.spa,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
                        style: AppTextStyles.quran(
                          color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                          fontSize: 24,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'رقية التعطيل والسحر — الشيخ فهد القرني',
                        style: AppTextStyles.body(
                          color: isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'الأقسام الرئيسية',
                  style: AppTextStyles.subheader(
                    color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _FeatureCard(
                  title: 'الرقية الشرعية الصوتية',
                  subtitle: 'استمع إلى الرقية بأصوات مشايخ مختارين',
                  icon: Icons.headphones_rounded,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkTeal, AppColors.primaryTealDark]
                        : [AppColors.primaryTeal, AppColors.primaryTealLight],
                  ),
                  onTap: () {
                    Haptic.light();
                    context.go(AppRoutes.audioRoqia);
                  },
                ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.md),

                _FeatureCard(
                  title: 'الرقية الشرعية المكتوبة',
                  subtitle: 'اقرأ آيات الرقية بخط واضح وجميل',
                  icon: Icons.menu_book_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.accentGold, AppColors.accentGoldLight],
                  ),
                  onTap: () {
                    Haptic.light();
                    context.go(AppRoutes.writtenRoqia);
                  },
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.md),

                _FeatureCard(
                  title: 'الأذكار اليومية',
                  subtitle: 'عداد التسبيح والأدعية المأثورة',
                  icon: Icons.favorite_rounded,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkSecondary, AppColors.darkSurface]
                        : [AppColors.backgroundCreamDark, AppColors.backgroundCream],
                  ),
                  textColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                  onTap: () {
                    Haptic.light();
                    context.go(AppRoutes.dhikr);
                  },
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.md),

                _FeatureCard(
                  title: 'أذكار التحصين',
                  subtitle: 'أذكار مأثورة بمصادرها وأدعية للحفظ بإذن الله',
                  icon: Icons.shield_moon_outlined,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.primaryTealDark, AppColors.darkTeal]
                        : [AppColors.primaryTealLight, AppColors.primaryTeal],
                  ),
                  onTap: () {
                    Haptic.light();
                    context.go(AppRoutes.tahseen);
                  },
                ).animate().fadeIn(delay: 350.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.lg),

                const NotificationsSettingsCard()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.lg),

                _DisclaimerCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.lg),

                _FeatureCard(
                  title: 'شارك التطبيق',
                  subtitle: 'الدال على الخير كفاعله — شاركه مع من تحب',
                  icon: Icons.share_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.accentGold, AppColors.accentGoldLight],
                  ),
                  onTap: () {
                    Haptic.light();
                    ShareService.shareApp();
                  },
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: AppSpacing.xxl),

                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSecondary
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                        size: 20,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
                        style: AppTextStyles.quran(
                          color: isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'الإصدار 1.0.3',
                        style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color? textColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.textColor,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _isPressed ? 0.97 : 1.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: _isPressed ? 8 : 12,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _isPressed = v),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: (widget.textColor ?? Colors.white)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: widget.textColor ?? Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.subheader(
                            color: widget.textColor ?? Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.caption(
                            color: (widget.textColor ?? Colors.white)
                                .withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: (widget.textColor ?? Colors.white)
                        .withValues(alpha: 0.7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// تنبيه: مصدر الرقية + أن التطبيق خيري بلا إعلانات + تنبيه شرعي/طبي.
class _DisclaimerCard extends StatelessWidget {
  final bool isDark;
  const _DisclaimerCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final subColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondary.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.accentGold, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'تنبيه',
                style: AppTextStyles.subheader(color: AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _line(Icons.menu_book_rounded,
              'الرقية الشرعية في هذا التطبيق منقولة عن الشيخ فهد القرني.',
              teal, textColor),
          const SizedBox(height: AppSpacing.sm),
          _line(Icons.volunteer_activism_rounded,
              'تطبيق خيري بالكامل — بدون أي إعلانات، ولا يجمع بياناتك.',
              teal, textColor),
          const SizedBox(height: AppSpacing.sm),
          _line(Icons.healing_rounded,
              'الرقية عبادة وسبب بإذن الله، ولا تُغني عن مراجعة الطبيب عند الحاجة.',
              teal, subColor),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String text, Color iconColor, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption(color: textColor)
                .copyWith(height: 1.6),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }
}
