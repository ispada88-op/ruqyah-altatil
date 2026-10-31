/// تحويل ميلادي → هجري بالخوارزمية الجدولية (Kuwaiti algorithm).
///
/// تقريبي: قد يختلف يوماً واحداً عن تقويم أم القرى الرسمي أو رؤية الهلال.
/// لذلك لا يُعرض التاريخ الهجري للمستخدم في التطبيق. أما معرفة «هل نحن في
/// رمضان» (زيادة ٣٠ دقيقة على العشاء في طريقة أم القرى) فتعتمد [isRamadanUmmAlQura]
/// وجدول أم القرى المضمَّن، وتعود إلى هذا التحويل خارج نطاق الجدول فقط.
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

// ═══ رمضان بتقويم أم القرى (جدول مضمَّن، بلا اتصال) ═══
//
// بداية رمضان لكل عام هجري ١٤٤٠..١٥٠٠ بأيام منذ ١٩٧٠-٠١-٠١ (UTC)، وطوله:
// '1' = ٣٠ يوماً، '0' = ٢٩. مولَّد من بيانات تقويم أم القرى في مكتبة hijridate 2.3.0
// (مرجع: umalqura.org.sa) — ويثبّته اختبار على حدود رمضان ١٤٤٦–١٤٤٩.
const List<int> _ramadanStartEpochDay = [
  18022, 18376, 18730, 19084, 19439, 19793, 20148, 20502, 20857, 21211, //
  21565, 21919, 22274, 22628, 22983, 23337, 23691, 24045, 24399, 24754,
  25109, 25463, 25817, 26172, 26526, 26880, 27235, 27589, 27944, 28298,
  28652, 29007, 29361, 29715, 30070, 30425, 30779, 31133, 31487, 31841,
  32196, 32551, 32905, 33260, 33614, 33968, 34322, 34676, 35031, 35386,
  35740, 36094, 36448, 36802, 37157, 37511, 37866, 38220, 38575, 38929,
  39283,
];
const String _ramadanIs30 =
    '0111010100010101111001100001011001001111001000110011110101000';

/// نطاق الجدول: ١ محرم ١٤٤٠ (٢٠١٨-٠٩-١١) → آخر ذي الحجة ١٥٠٠ (٢٠٧٧-١١-١٦).
const int _tableFirstDay = 17785;
const int _tableLastDay = 39401;

/// هل [date] (بالتاريخ المحلي، دون الوقت) في رمضان وفق تقويم أم القرى؟
bool isRamadanUmmAlQura(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day)
          .millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  if (day < _tableFirstDay || day > _tableLastDay) {
    return gregorianToHijri(date).isRamadan; // خارج الجدول: التقريب الجدولي
  }
  for (var i = 0; i < _ramadanStartEpochDay.length; i++) {
    final start = _ramadanStartEpochDay[i];
    final len = _ramadanIs30[i] == '1' ? 30 : 29;
    if (day >= start && day < start + len) return true;
  }
  return false;
}
