// التاريخ الهجري المعروض (أم القرى) وتنسيق أوقات الصلاة بأرقام لاتينية.
import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/utils/hijri.dart';

void main() {
  test('Umm al-Qura dates match the official calendar', () {
    String h(DateTime d) => hijriUmmAlQura(d).toString();
    // ummulqura.org.sa: السبت ٣١ أكتوبر ٢٠٢٦ = ٢٠ جمادى الأولى ١٤٤٨.
    expect(h(DateTime(2026, 10, 31)), '1448-5-20');
    // رمضان ١٤٤٨ يبدأ ٨ فبراير ٢٠٢٧، والعيد ٩ مارس ٢٠٢٧.
    expect(h(DateTime(2027, 2, 8)), '1448-9-1');
    expect(h(DateTime(2027, 3, 8)), '1448-9-29');
    expect(h(DateTime(2027, 3, 9)), '1448-10-1');
    // أول الجدول.
    expect(h(DateTime(2018, 9, 11)), '1440-1-1');
  });

  test('display table agrees with the Ramadan table', () {
    for (var d = DateTime(2025, 1, 1);
        d.isBefore(DateTime(2030, 1, 1));
        d = DateTime(d.year, d.month, d.day + 1)) {
      expect(hijriUmmAlQura(d).isRamadan, isRamadanUmmAlQura(d),
          reason: d.toIso8601String());
    }
  });

  test('prayer times and dates use Latin digits', () {
    expect(formatTimeLatin(4, 51), '4:51 ص');
    expect(formatTimeLatin(17, 39), '5:39 م');
    expect(formatTimeLatin(0, 5), '12:05 ص');
    expect(formatDateLatin(DateTime(2026, 10, 31)), 'السبت 31 أكتوبر 2026');
    expect(kHijriMonths[4], 'جمادى الأولى');
    expect(shortLeftLatin(const Duration(minutes: 282)), '4 س 42 د');
    expect(shortLeftLatin(const Duration(minutes: 12)), '12 د');
  });
}
