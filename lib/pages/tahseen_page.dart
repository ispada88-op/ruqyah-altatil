import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:roqia_altatil/data/hisn_almuslim_dhikr.dart';
import 'package:roqia_altatil/theme.dart';

/// صفحة أذكار التحصين: تعرض الأذكار المسندة بمصادرها + الأدعية العامة.
class TahseenPage extends StatelessWidget {
  const TahseenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sourced = hisnAlmuslimDhikr
        .where((d) => d.category == 'tahseen')
        .toList(growable: false);
    final duas = hisnAlmuslimDhikr
        .where((d) => d.category == 'dua_tahseen')
        .toList(growable: false);

    return Container(
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
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Icon(
                Icons.shield_moon_outlined,
                size: 48,
                color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'أذكار التحصين',
                style: AppTextStyles.header(
                  color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'أذكار مأثورة بمصادرها الصحيحة، وأدعية جامعة للحفظ بإذن الله',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(
                  color: isDark
                      ? AppColors.textOnDarkSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(title: 'أذكار مأثورة بمصادرها', isDark: isDark),
            ...sourced.map((d) => _TahseenCard(entry: d, isDark: isDark)),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(title: 'أدعية تحصين عامة', isDark: isDark),
            ...duas.map((d) => _TahseenCard(entry: d, isDark: isDark)),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.star_purple500_outlined,
              size: 18, color: AppColors.accentGold),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.subheader(
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TahseenCard extends StatelessWidget {
  final DhikrEntry entry;
  final bool isDark;
  const _TahseenCard({required this.entry, required this.isDark});

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(
        ClipboardData(text: '${entry.body}\n\n— ${entry.title}'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم النسخ ✅'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    // ignore: deprecated_member_use
    await Share.share(
        '${entry.body}\n\n— ${entry.title}\n\nمن تطبيق رقية التعطيل');
  }

  @override
  Widget build(BuildContext context) {
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: teal.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 16, color: AppColors.accentGold),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  entry.title,
                  style: AppTextStyles.caption(color: AppColors.accentGold)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.body,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.quran(
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              fontSize: 19,
            ).copyWith(height: 1.9),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _copy(context),
                icon: Icon(Icons.copy_rounded, size: 20, color: teal),
                tooltip: 'نسخ',
              ),
              IconButton(
                onPressed: _share,
                icon: Icon(Icons.share_rounded, size: 20, color: teal),
                tooltip: 'مشاركة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
