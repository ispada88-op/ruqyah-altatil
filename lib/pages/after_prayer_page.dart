import 'package:flutter/material.dart';

import 'package:roqia_altatil/data/after_prayer_data.dart';
import 'package:roqia_altatil/pages/general_ruqyah_page.dart';

/// أذكار ما بعد السلام من الصلاة المفروضة — من «حصن المسلم» بعدّاد لكل ذكر.
class AfterPrayerPage extends StatelessWidget {
  const AfterPrayerPage({super.key});

  @override
  Widget build(BuildContext context) => GeneralRuqyahPage(
        items: afterPrayerItems(),
        title: 'أذكار بعد الصلاة',
        subtitle:
            'أذكار تُقال بعد السلام من الصلاة المفروضة، بعدد التكرار المبيَّن لكل ذكر',
        emblem: 'أذكار',
        footer: 'المصدر: حصن المسلم — سعيد بن علي بن وهف القحطاني',
      );
}
