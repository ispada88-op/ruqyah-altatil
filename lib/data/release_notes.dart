import 'package:flutter/material.dart';

import 'package:roqia_altatil/nav.dart';

/// ملاحظات الإصدارات التي تظهر في نافذة «الجديد في هذا الإصدار».
///
/// عند كل تحديث: أضف مدخلاً جديداً بمفتاح = `version` في pubspec.yaml
/// (بدون رقم البناء). اختبار `release_notes_test.dart` يفشل إن نسيت —
/// فلا يرى المستخدمون ملاحظات إصدار قديم على أنها «جديد».
class ReleaseEntry {
  final List<(IconData, String)> highlights;

  /// زر اختياري يأخذ المستخدم للميزة الجديدة.
  final String? ctaLabel;
  final String? ctaRoute;
  final IconData ctaIcon;

  const ReleaseEntry({
    required this.highlights,
    this.ctaLabel,
    this.ctaRoute,
    this.ctaIcon = Icons.auto_stories_outlined,
  });
}

const Map<String, ReleaseEntry> kReleaseNotes = {
  '1.1.0': ReleaseEntry(
    highlights: [
      (
        Icons.mosque_outlined,
        'مواقيت الصلاة واتجاه القبلة بحساب داخل جهازك بلا إنترنت، مع تنبيه اختياري عند دخول كل وقت'
      ),
      (
        Icons.menu_book_outlined,
        'أذكار بعد الصلاة من حصن المسلم، وتذكير بها بعد كل فريضة، وتذكير سورة الكهف يوم الجمعة'
      ),
      (
        Icons.flag_outlined,
        'ختمة القرآن بورد يومي يتقدّم بقراءتك، وعلامات مرجعية في المصحف'
      ),
      (
        Icons.manage_search_outlined,
        'البحث في آيات القرآن، وبطاقة آية تشاركها كصورة'
      ),
      (
        Icons.checklist_outlined,
        'برنامج المداومة: مهام يومية قصيرة نحو ٧ أو ٢١ أو ٤٠ يوماً متتالية'
      ),
      (
        Icons.rule_outlined,
        'صفحة «ضوابط الرقية الشرعية»: الشروط والأدلة وما يُحذَّر منه'
      ),
    ],
    ctaLabel: 'افتح مواقيت الصلاة',
    ctaRoute: AppRoutes.prayerTimes,
    ctaIcon: Icons.mosque_outlined,
  ),
  '1.0.6': ReleaseEntry(
    highlights: [
      (
        Icons.wb_twilight_outlined,
        'أذكار الصباح والمساء كاملة من حصن المسلم، بعدّاد لكل ذكر'
      ),
      (
        Icons.auto_stories_outlined,
        'المصحف الشريف كاملاً كما في مصحف المدينة: ٦٠٤ صفحات بخط ورسم مجمع الملك فهد نفسه، مع فهرس السور والأجزاء ومتابعة آخر قراءة'
      ),
      (
        Icons.alarm_add_outlined,
        'تذكير أذكار الصباح والمساء بوقتك المحلي (يفتح الأذكار بالضغط عليه)، وتذكيراتك الخاصة'
      ),
      (
        Icons.calendar_month_outlined,
        'متابعة أيام الرقية: سجّل قراءتك اليومية وتابع استمرارك'
      ),
      (
        Icons.healing_outlined,
        'رقى حسب الحالة: السحر، العين والحسد، الهم والحزن'
      ),
      (
        Icons.label_outlined,
        'اسم التطبيق صار «الرقية الشاملة» بأيقونة جديدة وقائمة أبسط تبدأ بالمصحف. ورقية التعطيل فيه للشيخ فهد القرني'
      ),
    ],
    ctaLabel: 'افتح أذكار الصباح والمساء',
    ctaRoute: AppRoutes.adhkar,
    ctaIcon: Icons.wb_twilight_outlined,
  ),
  '1.0.5': ReleaseEntry(highlights: [
    (
      Icons.schedule_outlined,
      'التذكيرات الآن بتوقيت بلدك أينما كنت، وتذكير الرقية اليومي لا ينقطع حتى لو لم تفتح التطبيق'
    ),
    (
      Icons.mail_outlined,
      'صفحة الاقتراحات: إن لم يوجد تطبيق بريد نحفظ رسالتك وننسخها بدل أن تضيع'
    ),
    (
      Icons.text_fields_outlined,
      'خطوط المصحف والتطبيق مضمّنة — تظهر بشكلها الصحيح حتى بدون إنترنت'
    ),
    (Icons.battery_charging_full_outlined, 'تشغيل صوتي أخف على البطارية'),
  ]),
  '1.0.4': ReleaseEntry(
    highlights: [
      (
        Icons.auto_stories_outlined,
        'قسم جديد: الرقية المستقلة — الفاتحة والمعوذات وآيات وأدعية الشفاء، بعدّاد تكرار لكل فقرة'
      ),
      (
        Icons.share_outlined,
        'إصلاح المشاركة — تعمل الآن بثبات على كل الأجهزة بما فيها iPad'
      ),
      (
        Icons.notifications_active_outlined,
        'إصلاح مفتاح التنبيهات، مع زر «فتح الإعدادات» عند رفض الإذن'
      ),
      (Icons.spellcheck, 'تدقيق النصوص وتحسينات عامة'),
    ],
    ctaLabel: 'استكشف الرقية المستقلة',
    ctaRoute: AppRoutes.generalRuqyah,
  ),
};

/// مقارنة أرقام إصدارات بصيغة x.y.z (يتجاهل رقم البناء بعد +).
int compareVersions(String a, String b) {
  List<int> parse(String v) => v
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p.trim()) ?? 0)
      .toList();
  final pa = parse(a), pb = parse(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

/// الملاحظات التي لم يرها المستخدم: كل إصدار أحدث من [lastSeen] حتى [current]
/// (الأحدث أولاً). المستخدم الذي قفز من 1.0.3 إلى 1.0.5 يرى الاثنين.
List<MapEntry<String, ReleaseEntry>> unseenReleaseNotes({
  required String? lastSeen,
  required String current,
}) {
  final out = kReleaseNotes.entries.where((e) {
    if (compareVersions(e.key, current) > 0) return false;
    if (lastSeen == null) return compareVersions(e.key, current) == 0;
    return compareVersions(e.key, lastSeen) > 0;
  }).toList()
    ..sort((a, b) => compareVersions(b.key, a.key));
  return out;
}
