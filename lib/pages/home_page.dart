import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roqia_altatil/data/quran_quotes.dart';
import 'package:roqia_altatil/data/verified_quran.dart' show basmalaUthmani;
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/mushaf_page_reader.dart' show kLastPageKey;
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/share_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/config/app_identity.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/menu_group.dart';
import 'package:roqia_altatil/widgets/quran_text.dart';
import 'package:roqia_altatil/widgets/today_strip.dart';

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
                const SizedBox(height: AppSpacing.md),

                // ١) المصحف وحده أولاً.
                const _MushafHero()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSpacing.md),

                const TodayStrip()
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.lg),

                // نسبة رقية التعطيل (مطلوبة بخط عريض واضح)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                      QuranText(
                        basmalaUthmani,
                        style: AppTextStyles.mushaf(
                          color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // نسبة رقية التعطيل للشيخ — بخط عريض واضح.
                      Text(
                        AppIdentity.taTil,
                        style: AppTextStyles.header(
                          color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        AppIdentity.taTilOwner,
                        style: AppTextStyles.subheader(
                          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: AppSpacing.xl),

                // ٢) الأقسام: كل قسم قائمة قائمة بذاتها (المصحف في البطاقة أعلاه).
                const MenuGroup(
                  title: 'الأقسام',
                  rows: [
                    MenuRow(
                      title: 'الرقية',
                      subtitle: 'رقية التعطيل • الرقية المستقلة • رقى حسب الحالة',
                      icon: Icons.healing_outlined,
                      route: AppRoutes.ruqyahHub,
                    ),
                    MenuRow(
                      title: 'الأذكار',
                      subtitle: 'حصن المسلم • التحصين • التسبيح • التذكيرات',
                      icon: Icons.wb_twilight_outlined,
                      route: AppRoutes.adhkarHub,
                    ),
                    MenuRow(
                      title: 'الصلاة',
                      subtitle: 'المواقيت • القبلة • أذكار بعد الصلاة',
                      icon: Icons.mosque_outlined,
                      route: AppRoutes.prayerTimes,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.lg),

                const _SadaqaCard()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: AppSpacing.lg),

                _DisclaimerCard(isDark: isDark)
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),

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
                        Icons.info_outlined,
                        color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                        size: 20,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        kHomeFooterAyah.text,
                        style: AppTextStyles.quran(
                          color: isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _VersionAndLicenses(
                        color: isDark
                            ? AppColors.textOnDarkSecondary
                            : AppColors.textTertiary,
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

/// المصحف: بطاقة كبيرة وحدها أعلى الرئيسية، مع «تابع القراءة» إن وُجدت صفحة محفوظة.
class _MushafHero extends StatefulWidget {
  const _MushafHero();

  @override
  State<_MushafHero> createState() => _MushafHeroState();
}

class _MushafHeroState extends State<_MushafHero> {
  int? _lastPage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final p = prefs.getInt(kLastPageKey);
      if (mounted && p != null && p >= 1 && p <= 604) setState(() => _lastPage = p);
    } catch (_) {/* اختياري */}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.xl);
    // الظل خارج Material: Ink يقصّ ظلّه على مستطيل فيظهر خلف الزوايا المستديرة.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [AppColors.primaryTealDark, AppColors.darkSecondary]
                  : [AppColors.primaryTealDark, AppColors.primaryTeal],
            ),
            borderRadius: radius,
            border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              Haptic.light();
              context.go(AppRoutes.mushaf);
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(AppRadius.md + 6),
                        ),
                        child: const Icon(Icons.auto_stories_outlined,
                            size: 30, color: AppColors.accentGoldLight),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المصحف الشريف',
                              style: AppTextStyles.header(color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'مصحف المدينة النبوية — ٦٠٤ صفحات',
                              style: AppTextStyles.caption(
                                  color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: AppColors.textPrimary,
                            minimumSize: const Size.fromHeight(46),
                          ),
                          onPressed: () {
                            Haptic.light();
                            context.go(_lastPage == null
                                ? AppRoutes.mushaf
                                : AppRoutes.mushafPage(_lastPage!));
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _lastPage == null
                                  ? 'ابدأ القراءة'
                                  : 'تابع من صفحة ${arDigits(_lastPage!)}',
                              maxLines: 1,
                              style: AppTextStyles.button(color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                      ),
                      if (_lastPage != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                            minimumSize: const Size(0, 46),
                          ),
                          onPressed: () {
                            Haptic.light();
                            context.go(AppRoutes.mushaf);
                          },
                          child: Text('الفهرس',
                              style: AppTextStyles.button(color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // ما يخصّ المصحف: الختمة والعلامات والبحث.
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final (icon, label, route) in [
                        (Icons.flag_outlined, 'الختمة', AppRoutes.khatma),
                        (Icons.bookmarks_outlined, 'العلامات', AppRoutes.bookmarks),
                        (Icons.manage_search_outlined, 'البحث', AppRoutes.quranSearch),
                      ])
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            Haptic.light();
                            context.go(route);
                          },
                          icon: Icon(icon, size: 20),
                          label: Text(label,
                              style: AppTextStyles.button(color: Colors.white)),
                        ),
                    ],
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

/// «شارك التطبيق صدقة جارية»: عبارة الصدقة الجارية + زرّا المشاركة والاقتراحات.
class _SadaqaCard extends StatelessWidget {
  const _SadaqaCard();

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: c.isDark
            ? AppColors.darkSecondary.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.volunteer_activism_outlined, color: c.gold, size: 26),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppIdentity.sadaqaLine,
                  style: AppTextStyles.subheader(color: c.ink)
                      .copyWith(fontWeight: FontWeight.w700, height: 1.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('الدال على الخير كفاعله',
              style: AppTextStyles.caption(color: c.sub)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                style: c.filled,
                onPressed: () {
                  Haptic.light();
                  ShareService.shareApp(context);
                },
                icon: const Icon(Icons.share_outlined, size: 20),
                label: const Text('شارك التطبيق'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: c.teal),
                onPressed: () {
                  Haptic.light();
                  context.go(AppRoutes.feedback);
                },
                icon: const Icon(Icons.feedback_outlined, size: 20),
                label: const Text('اقتراحات'),
              ),
            ],
          ),
        ],
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
              Icon(Icons.info_outlined, color: AppColors.accentGold, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'تنبيه',
                style: AppTextStyles.subheader(color: AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _line(Icons.menu_book_outlined,
              'رقية التعطيل في هذا التطبيق هي رقية الشيخ فهد القرني.',
              teal, textColor),
          const SizedBox(height: AppSpacing.sm),
          _line(Icons.volunteer_activism_outlined,
              'تطبيق خيري بالكامل — بدون أي إعلانات، ولا يجمع بياناتك.',
              teal, textColor),
          const SizedBox(height: AppSpacing.sm),
          _line(Icons.healing_outlined,
              'الرقية سبب للشفاء بإذن الله، ولا تُغني عن مراجعة الطبيب عند الحاجة.',
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

/// «الإصدار X» من الحزمة نفسها (لا رقم مكتوب يدوياً) + صفحة التراخيص، ومنها
/// رخصة خط مجمع الملك فهد التي تشترط أن تُرفق مع الخط.
class _VersionAndLicenses extends StatefulWidget {
  final Color color;
  const _VersionAndLicenses({required this.color});

  @override
  State<_VersionAndLicenses> createState() => _VersionAndLicensesState();
}

class _VersionAndLicensesState extends State<_VersionAndLicenses> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = info.version);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'HomePage.version');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_version != null)
          Text('الإصدار $_version', style: AppTextStyles.caption(color: widget.color)),
        TextButton(
          onPressed: () => showLicensePage(
            context: context,
            applicationName: AppIdentity.name,
            applicationVersion: _version,
            applicationLegalese: AppIdentity.taTilAttribution,
          ),
          child: Text('التراخيص والمصادر',
              style: AppTextStyles.caption(color: widget.color)),
        ),
      ],
    );
  }
}
