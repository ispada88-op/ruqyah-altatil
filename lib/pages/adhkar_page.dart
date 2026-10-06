import 'package:flutter/material.dart';

import 'package:roqia_altatil/data/adhkar_data.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/theme.dart';

/// أذكار الصباح والمساء (طلب مستخدم) — من «حصن المسلم» بعدّاد لكل ذكر.
class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key, this.initial});

  final AdhkarTime? initial;

  /// الافتراضي حسب الوقت: قبل العصر تقريباً (٣م) صباح، وبعده مساء.
  static AdhkarTime defaultFor(DateTime now) =>
      now.hour >= 4 && now.hour < 15 ? AdhkarTime.morning : AdhkarTime.evening;

  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  late AdhkarTime _time =
      widget.initial ?? AdhkarPage.defaultFor(DateTime.now());

  @override
  void didUpdateWidget(AdhkarPage old) {
    super.didUpdateWidget(old);
    // ضغط إشعار الصباح/المساء والصفحة مفتوحة: انتقل للوقت المطلوب.
    final next = widget.initial;
    if (next != null && next != old.initial) _time = next;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final morning = _time == AdhkarTime.morning;

    return GeneralRuqyahPage(
      // مفتاح لكل وقت: يعيد تعيين العدّادات عند التبديل.
      key: ValueKey(_time),
      items: adhkarItems(_time),
      title: morning ? 'أذكار الصباح' : 'أذكار المساء',
      subtitle: morning
          ? 'وقتها من طلوع الفجر إلى ارتفاع الشمس وما بعده من الضحى'
          : 'وقتها من العصر إلى الليل',
      emblem: 'أذكار',
      headerExtra: SegmentedButton<AdhkarTime>(
        segments: const [
          ButtonSegment(
            value: AdhkarTime.morning,
            icon: Icon(Icons.wb_sunny_outlined),
            label: Text('الصباح'),
          ),
          ButtonSegment(
            value: AdhkarTime.evening,
            icon: Icon(Icons.nights_stay_outlined),
            label: Text('المساء'),
          ),
        ],
        selected: {_time},
        onSelectionChanged: (s) {
          Haptic.select();
          setState(() => _time = s.first);
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor:
              isDark ? AppColors.darkTeal : AppColors.primaryTeal,
          selectedForegroundColor: Colors.white,
        ),
      ),
      footer: 'المصدر: حصن المسلم — سعيد بن علي بن وهف القحطاني',
    );
  }
}
