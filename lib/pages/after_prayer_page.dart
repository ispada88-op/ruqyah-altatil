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
        subtitle: 'تُقرأ بعد السلام من كل صلاة مفروضة بالترتيب وبعدد التكرار المبيَّن',
        emblem: 'أذكار',
        footer: 'المصدر: حصن المسلم — سعيد بن علي بن وهف القحطاني',
      );
}
