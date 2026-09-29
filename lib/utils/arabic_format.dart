/// تنسيق الأرقام والتواريخ والأوقات بالعربية (بدون حزمة intl).
library;

const _digits = '٠١٢٣٤٥٦٧٨٩';

/// 128 → «١٢٨».
String arDigits(Object n) => n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : _digits[d];
    }).join();

const List<String> kArabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// DateTime.weekday: 1 = الإثنين … 7 = الأحد.
const List<String> kArabicWeekdays = [
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

/// «الأحد ٢٨ سبتمبر ٢٠٢٦».
String formatDateAr(DateTime d) =>
    '${kArabicWeekdays[d.weekday - 1]} ${arDigits(d.day)} '
    '${kArabicMonths[d.month - 1]} ${arDigits(d.year)}';

/// «٩:٠٥ ص» / «٨:٣٠ م» (نظام ١٢ ساعة).
String formatTimeAr(int hour, int minute) {
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  final suffix = hour < 12 ? 'ص' : 'م';
  return '${arDigits(h12)}:${arDigits(minute.toString().padLeft(2, '0'))} $suffix';
}

/// عدد الأيام بصيغته العربية الصحيحة: «يوم واحد» «يومان» «٧ أيام» «٢١ يوماً».
String daysLabel(int n) {
  if (n == 1) return 'يوم واحد';
  if (n == 2) return 'يومان';
  if (n >= 3 && n <= 10) return '${arDigits(n)} أيام';
  return '${arDigits(n)} يوماً';
}

/// عدد الآيات بصيغته العربية الصحيحة: «آية واحدة» «آيتان» «٧ آيات» «١١٠ آيات» «٢٨٦ آية».
String ayatLabel(int n) {
  if (n == 1) return 'آية واحدة';
  if (n == 2) return 'آيتان';
  final m = n % 100;
  if (m >= 3 && m <= 10) return '${arDigits(n)} آيات';
  return '${arDigits(n)} آية';
}
