/// تحويل ميلادي → هجري بالخوارزمية الجدولية (Kuwaiti algorithm).
///
/// تقريبي: قد يختلف يوماً واحداً عن تقويم أم القرى الرسمي أو رؤية الهلال.
/// لذلك لا يُعرض التاريخ الهجري للمستخدم في التطبيق؛ يُستعمل داخلياً فقط
/// لمعرفة هل نحن في رمضان (زيادة ٣٠ دقيقة على العشاء في طريقة أم القرى).
class HijriDate {
  final int year;
  final int month; // 1..12 (9 = رمضان)
  final int day;
  const HijriDate(this.year, this.month, this.day);

  bool get isRamadan => month == 9;

  @override
  String toString() => '$year-$month-$day';
}

/// يشبه القسمة الصحيحة في C (يقتطع نحو الصفر) — الخوارزمية مكتوبة عليها.
int _div(int a, int b) => a ~/ b;

HijriDate gregorianToHijri(DateTime date) {
  final y = date.year, m = date.month, d = date.day;
  final t = _div(m - 14, 12);
  final jd = _div(1461 * (y + 4800 + t), 4) +
      _div(367 * (m - 2 - 12 * t), 12) -
      _div(3 * _div(y + 4900 + t, 100), 4) +
      d -
      32075;
  var l = jd - 1948440 + 10632;
  final n = _div(l - 1, 10631);
  l = l - 10631 * n + 354;
  final j = _div(10985 - l, 5316) * _div(50 * l, 17719) +
      _div(l, 5670) * _div(43 * l, 15238);
  l = l -
      _div(30 - j, 15) * _div(17719 * j, 50) -
      _div(j, 16) * _div(15238 * j, 43) +
      29;
  final month = _div(24 * l, 709);
  final day = l - _div(709 * month, 24);
  final year = 30 * n + j - 30;
  return HijriDate(year, month, day);
}
