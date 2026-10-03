import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:roqia_altatil/widgets/adhkar_reminders_card.dart';
import 'package:roqia_altatil/widgets/notifications_settings_card.dart';
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

                // ٢) ثم الباقي في مجموعات قصيرة وواضحة.
                _MenuGroup(
                  title: 'الرقية',
                  rows: [
                    _MenuRow(
                      title: 'رقية التعطيل — صوتية',
                      subtitle: '${AppIdentity.taTilOwner} • بأصوات مشايخ مختارين',
                      icon: Icons.headphones_rounded,
                      route: AppRoutes.audioRoqia,
                    ),
                    _MenuRow(
                      title: 'رقية التعطيل — مكتوبة',
                      subtitle: '${AppIdentity.taTilOwner} • اقرأها بخط واضح',
                      icon: Icons.text_snippet_outlined,
                      route: AppRoutes.writtenRoqia,
                    ),
                    _MenuRow(
                      title: 'الرقية المستقلة',
                      subtitle: 'الفاتحة والمعوذات وآيات وأدعية بعدد التكرار',
                      iconWidget: _RuqyahBadge(),
                      route: AppRoutes.generalRuqyah,
                    ),
                    _MenuRow(
                      title: 'رقى حسب الحالة',
                      subtitle: 'السحر • العين والحسد • الهم والحزن',
                      icon: Icons.healing_rounded,
                      route: AppRoutes.ruqyahTypes,
                    ),
                    _MenuRow(
                      title: 'ضوابط الرقية الشرعية',
                      subtitle: 'الشروط والأدلة وما يُحذَّر منه',
                      icon: Icons.rule_rounded,
                      route: AppRoutes.ruqyahRules,
                    ),
                  ],
                ).animate().fadeIn(delay: 180.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.md),

                _MenuGroup(
                  title: 'الصلاة والقرآن',
                  rows: [
                    _MenuRow(
                      title: 'مواقيت الصلاة',
                      subtitle: 'بدون إنترنت • تنبيهات اختيارية',
                      icon: Icons.access_time_rounded,
                      route: AppRoutes.prayerTimes,
                    ),
                    _MenuRow(
                      title: 'اتجاه القبلة',
                      subtitle: 'بوصلة تدلّك على الكعبة',
                      icon: Icons.explore_outlined,
                      route: AppRoutes.qibla,
                    ),
                    _MenuRow(
                      title: 'ختمة القرآن',
                      subtitle: 'ورد يومي بمدة تختارها',
                      icon: Icons.flag_outlined,
                      route: AppRoutes.khatma,
                    ),
                    _MenuRow(
                      title: 'البحث في القرآن',
                      subtitle: 'ابحث بكلمة من الآية',
                      icon: Icons.manage_search_rounded,
                      route: AppRoutes.quranSearch,
                    ),
                    _MenuRow(
                      title: 'العلامات المرجعية',
                      subtitle: 'صفحات حفظتها في المصحف',
                      icon: Icons.bookmarks_outlined,
                      route: AppRoutes.bookmarks,
                    ),
                  ],
                ).animate().fadeIn(delay: 210.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.md),

                _MenuGroup(
                  title: 'الأذكار',
                  rows: [
                    _MenuRow(
                      title: 'أذكار الصباح والمساء',
                      subtitle: 'كاملة من حصن المسلم بعدّاد لكل ذكر',
                      icon: Icons.wb_twilight_rounded,
                      route: AppRoutes.adhkar,
                    ),
                    _MenuRow(
                      title: 'أذكار بعد الصلاة',
                      subtitle: 'بعد السلام من كل فريضة من حصن المسلم',
                      icon: Icons.menu_book_outlined,
                      route: AppRoutes.afterPrayer,
                    ),
                    _MenuRow(
                      title: 'الأذكار اليومية',
                      subtitle: 'عداد التسبيح والأدعية المأثورة',
                      icon: Icons.favorite_rounded,
                      route: AppRoutes.dhikr,
                    ),
                    _MenuRow(
                      title: 'أذكار التحصين',
                      subtitle: 'أذكار مأثورة بمصادرها للحفظ بإذن الله',
                      icon: Icons.shield_moon_outlined,
                      route: AppRoutes.tahseen,
                    ),
                  ],
                ).animate().fadeIn(delay: 240.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.md),

                _MenuGroup(
                  title: 'المزيد',
                  rows: [
                    _MenuRow(
                      title: 'برنامج المداومة',
                      subtitle: 'مهام يومية نحو ٧ أو ٢١ أو ٤٠ يوماً',
                      icon: Icons.checklist_rounded,
                      route: AppRoutes.program,
                    ),
                    _MenuRow(
                      title: 'متابعة أيام الرقية',
                      subtitle: 'سجّل قراءتك اليومية وتابع استمرارك',
                      icon: Icons.event_available_rounded,
                      route: AppRoutes.tracker,
                    ),
                    _MenuRow(
                      title: 'اقتراحات',
                      subtitle: 'اكتب لنا رأيك أو ملاحظتك',
                      icon: Icons.chat_bubble_outline_rounded,
                      route: AppRoutes.feedback,
                    ),
                    const _MenuRow(
                      title: 'شارك التطبيق',
                      subtitle: 'الدال على الخير كفاعله',
                      icon: Icons.share_rounded,
                      shareApp: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: AppSpacing.lg),

                const AdhkarRemindersCard()
                    .animate()
                    .fadeIn(delay: 390.ms, duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),

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
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [AppColors.primaryTealDark, AppColors.darkSecondary]
                : [AppColors.primaryTealDark, AppColors.primaryTeal],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
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
                      child: const Icon(Icons.auto_stories_rounded,
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
                            'مصحف المدينة النبوية — ٦٠٤ صفحة',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// مجموعة صفوف بعنوان صغير: حاوية واحدة بخلفية موحّدة وفواصل رفيعة.
class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuRow> rows;
  const _MenuGroup({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
          child: Text(
            title,
            style: AppTextStyles.subheader(color: teal)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSecondary : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.08),
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// صف واحد: أيقونة، عنوان، سطر وصف، سهم. يفتح [route] أو يشارك التطبيق.
class _MenuRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final String? route;
  final bool shareApp;

  const _MenuRow({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    this.route,
    this.shareApp = false,
  }) : assert(icon != null || iconWidget != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return InkWell(
      onTap: () {
        Haptic.light();
        if (shareApp) {
          ShareService.shareApp(context);
        } else if (route != null) {
          context.go(route!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
              ),
              child: iconWidget != null
                  ? Center(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: teal),
                        child: iconWidget!,
                      ),
                    )
                  : Icon(icon, size: 24, color: teal),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_new,
                size: 16, color: teal.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

/// شارة قسم «الرقية المستقلة»: أيقونة مكتوب فيها «رقية» بخط أميري.
class _RuqyahBadge extends StatelessWidget {
  const _RuqyahBadge();

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    return Center(
      child: Text(
        'رقية',
        style: GoogleFonts.amiri(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.1,
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
              'رقية التعطيل في هذا التطبيق هي رقية الشيخ فهد القرني.',
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
