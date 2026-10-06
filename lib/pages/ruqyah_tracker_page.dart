import 'package:flutter/material.dart';

import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/ruqyah_log_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';

/// متابعة أيام الرقية (طلب مستخدمة): تسجيل القراءة اليومية + السلسلة + الهدف.
class RuqyahTrackerPage extends StatefulWidget {
  const RuqyahTrackerPage({super.key});

  @override
  State<RuqyahTrackerPage> createState() => _RuqyahTrackerPageState();
}

class _RuqyahTrackerPageState extends State<RuqyahTrackerPage> {
  final _log = RuqyahLogService.instance;

  @override
  void initState() {
    super.initState();
    _log.addListener(_onChange);
    if (!_log.isLoaded) _log.load();
  }

  @override
  void dispose() {
    _log.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final sub =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final doneToday = _log.isDone(today);
    final streak = _log.streak(today);
    final total = _log.days.length;
    final goal = _log.goal;
    final progress = (streak / goal).clamp(0.0, 1.0);

    final recent = _log.days.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Text('متابعة أيام الرقية',
              textAlign: TextAlign.center,
              style: AppTextStyles.header(color: teal)),
          Text('سجّل قراءتك كل يوم وتابع استمرارك — البيانات على جهازك فقط',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: sub)),
          const SizedBox(height: AppSpacing.lg),

          // زر تسجيل اليوم
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: doneToday
                    ? (isDark ? const Color(0xFF66BB6A) : AppColors.success)
                    : teal,
                foregroundColor: isDark ? const Color(0xFF0B1F1F) : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
              onPressed: () {
                doneToday ? Haptic.select() : Haptic.medium();
                _log.toggle(today);
              },
              icon: Icon(
                  doneToday ? Icons.check_circle : Icons.menu_book_outlined,
                  size: 28),
              label: Text(
                doneToday ? 'تم تسجيل قراءة اليوم ✓' : 'قرأت الرقية اليوم',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (doneToday)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('اضغط مرة أخرى لإلغاء التسجيل',
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.caption(color: sub).copyWith(fontSize: 11)),
            ),
          const SizedBox(height: AppSpacing.lg),

          // الإحصاءات
          Row(
            children: [
              _Stat(
                  label: 'أيام متتالية', value: arDigits(streak), color: teal),
              const SizedBox(width: AppSpacing.sm),
              _Stat(label: 'مجموع الأيام', value: arDigits(total), color: teal),
              const SizedBox(width: AppSpacing.sm),
              _Stat(label: 'الهدف', value: daysLabel(goal), color: teal),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: teal.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(teal),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            streak >= goal
                ? 'أتممت ${daysLabel(goal)} متتالية — تقبّل الله منك 🌿'
                : 'بقي ${daysLabel(goal - streak)} لإتمام ${daysLabel(goal)} متتالية',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: textColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final g in RuqyahLogService.goals)
                ChoiceChip(
                  label: Text(daysLabel(g)),
                  selected: goal == g,
                  onSelected: (_) {
                    Haptic.select();
                    _log.setGoal(g);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // آخر ٢٨ يوماً
          Text('آخر ٤ أسابيع',
              style: AppTextStyles.subheader(color: textColor)),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var i = 27; i >= 0; i--)
                _DayCell(
                  day: DateTime(today.year, today.month, today.day - i),
                  done: _log
                      .isDone(DateTime(today.year, today.month, today.day - i)),
                  isToday: i == 0,
                  color: teal,
                  onTap: (d) {
                    Haptic.select();
                    _log.toggle(d);
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('اضغط أي يوم لتسجيله أو إلغائه إن نسيت.',
              style: AppTextStyles.caption(color: sub).copyWith(fontSize: 11)),
          const SizedBox(height: AppSpacing.lg),

          if (recent.isNotEmpty) ...[
            Text('سجل القراءة',
                style: AppTextStyles.subheader(color: textColor)),
            const SizedBox(height: AppSpacing.sm),
            for (final key in recent.take(14))
              ListTile(
                dense: true,
                leading:
                    Icon(Icons.check_circle,
                    color: isDark ? const Color(0xFF66BB6A) : AppColors.success),
                title: Text(formatDateAr(DateTime.parse(key))),
              ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption().copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.done,
    required this.isToday,
    required this.color,
    required this.onTap,
  });

  final DateTime day;
  final bool done;
  final bool isToday;
  final Color color;
  final void Function(DateTime) onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: formatDateAr(day),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(day),
        child: Container(
          decoration: BoxDecoration(
            color: done ? color : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppColors.accentGold, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            arDigits(day.day),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: done ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
