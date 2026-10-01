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

  const ReleaseEntry({required this.highlights, this.ctaLabel, this.ctaRoute});
}

const Map<String, ReleaseEntry> kReleaseNotes = {
  '1.0.6': ReleaseEntry(
    highlights: [
      (
        Icons.wb_twilight_rounded,
        'أذكار الصباح والمساء كاملة من حصن المسلم، بعدّاد لكل ذكر'
      ),
      (
        Icons.auto_stories_rounded,
        'المصحف الشريف كاملاً كما في مصحف المدينة: ٦٠٤ صفحة بخط ورسم مجمع الملك فهد نفسه، مع فهرس السور والأجزاء ومتابعة آخر قراءة'
      ),
      (
        Icons.alarm_add_outlined,
        'تذكير أذكار الصباح والمساء بوقتك المحلي (يفتح الأذكار بالضغط عليه)، وتذكيراتك الخاصة'
      ),
      (
        Icons.event_available_rounded,
        'متابعة أيام الرقية: سجّل قراءتك اليومية وتابع استمرارك'
      ),
      (
        Icons.healing_rounded,
        'رقى حسب الحالة: السحر، العين والحسد، الهم والحزن'
      ),
      (
        Icons.label_outline_rounded,
        'اسم التطبيق صار «الرقية الشاملة». ورقية التعطيل فيه للشيخ فهد القرني'
      ),
    ],
    ctaLabel: 'افتح أذكار الصباح والمساء',
    ctaRoute: AppRoutes.adhkar,
  ),
  '1.0.5': ReleaseEntry(highlights: [
    (
      Icons.schedule_rounded,
      'التذكيرات الآن بتوقيت بلدك أينما كنت، وتذكير الرقية اليومي لا ينقطع حتى لو لم تفتح التطبيق'
    ),
    (
      Icons.mail_outline_rounded,
      'صفحة الاقتراحات: إن لم يوجد تطبيق بريد نحفظ رسالتك وننسخها بدل أن تضيع'
    ),
    (
      Icons.text_fields_rounded,
      'خطوط المصحف والتطبيق مضمّنة — تظهر بشكلها الصحيح حتى بدون إنترنت'
    ),
    (Icons.battery_charging_full_rounded, 'تشغيل صوتي أخف على البطارية'),
  ]),
  '1.0.4': ReleaseEntry(
    highlights: [
      (
        Icons.auto_stories_outlined,
        'قسم جديد: الرقية المستقلة — الفاتحة والمعوذات وآيات وأدعية الشفاء، بعدّاد تكرار لكل فقرة'
      ),
      (
        Icons.share_rounded,
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
