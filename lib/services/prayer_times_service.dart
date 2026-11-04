import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart' as adhan;
// تقريب تقويم أم القرى يحتاج الأوقات الخام قبل تقريب المكتبة لأقرب دقيقة.
// ignore: implementation_imports
import 'package:adhan/src/internal/shadow_length.dart';
// ignore: implementation_imports
import 'package:adhan/src/internal/solar_time.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/prayer_cities.dart';
import '../data/saudi_places.dart';
import '../utils/hijri.dart';
import 'error_reporter.dart';

/// أوقات اليوم: الفجر، الشروق (ليس صلاة)، الظهر، العصر، المغرب، العشاء.
enum PrayerKind {
  fajr('الفجر'),
  sunrise('الشروق'),
  dhuhr('الظهر'),
  asr('العصر'),
  maghrib('المغرب'),
  isha('العشاء');

  final String label;
  const PrayerKind(this.label);

  /// الشروق وقت لا صلاة.
  bool get isPrayer => this != PrayerKind.sunrise;
}

/// جاكيم (ماليزيا): فجر ١٨° وعشاء ١٨° — من بيانات e-solat الرسمية. الفروق الصحيحة
/// (احتياط الدقائق) استُخرجت من الجدول الرسمي لا من مصدر ثانوي.
adhan.CalculationParameters _jakimParams() =>
    adhan.CalculationParameters(fajrAngle: 18, ishaAngle: 18)
      ..methodAdjustments = adhan.PrayerAdjustments(
          fajr: 2, sunrise: -1, dhuhr: 3, asr: 2, maghrib: 1, isha: 1);

/// وزارة الأوقاف الأردنية: فجر ١٨° وعشاء ١٨°، والشروق والمغرب بفارق ٥ دقائق احتياطاً.
adhan.CalculationParameters _jordanParams() =>
    adhan.CalculationParameters(fajrAngle: 18, ishaAngle: 18)
      ..methodAdjustments = adhan.PrayerAdjustments(
          fajr: 0, sunrise: -6, dhuhr: 0, asr: 1, maghrib: 7, isha: 0);

/// وزارة الشؤون الدينية الإندونيسية (Kemenag): فجر ٢٠° وعشاء ١٨° مع احتياط ~٢ دقيقة.
adhan.CalculationParameters _kemenagParams() =>
    adhan.CalculationParameters(fajrAngle: 20, ishaAngle: 18)
      ..methodAdjustments = adhan.PrayerAdjustments(
          fajr: 3, sunrise: -3, dhuhr: 4, asr: 3, maghrib: 3, isha: 2);

/// طرق حساب المواقيت. المعرّف [id] هو ما يُحفظ في الجهاز — لا يتغير أبداً.
enum PrayerMethod {
  ummAlQura('umm_al_qura', 'أم القرى (السعودية)',
      adhan.CalculationMethod.umm_al_qura),
  muslimWorldLeague('muslim_world_league', 'رابطة العالم الإسلامي',
      adhan.CalculationMethod.muslim_world_league),
  egyptian('egyptian', 'الهيئة المصرية العامة للمساحة',
      adhan.CalculationMethod.egyptian),
  karachi('karachi', 'جامعة العلوم الإسلامية — كراتشي',
      adhan.CalculationMethod.karachi),
  dubai('dubai', 'الإمارات', adhan.CalculationMethod.dubai),
  qatar('qatar', 'قطر', adhan.CalculationMethod.qatar),
  kuwait('kuwait', 'الكويت', adhan.CalculationMethod.kuwait),
  singapore('singapore', 'سنغافورة وجنوب شرق آسيا',
      adhan.CalculationMethod.singapore),
  turkey('turkey', 'تركيا', adhan.CalculationMethod.turkey),
  northAmerica('north_america', 'أمريكا الشمالية (ISNA)',
      adhan.CalculationMethod.north_america),
  // طرق الجهات الرسمية التي حُقّقت من جداولها المنشورة (انظر test/prayer_times_test.dart).
  jakim('jakim', 'ماليزيا (جاكيم)', adhan.CalculationMethod.other, _jakimParams),
  jordan('jordan', 'الأردن (وزارة الأوقاف)', adhan.CalculationMethod.other,
      _jordanParams),
  kemenag('kemenag', 'إندونيسيا (وزارة الشؤون الدينية)',
      adhan.CalculationMethod.other, _kemenagParams);

  final String id;
  final String label;
  final adhan.CalculationMethod _method;
  final adhan.CalculationParameters Function()? _custom;
  const PrayerMethod(this.id, this.label, this._method, [this._custom]);

  adhan.CalculationParameters _buildParams() =>
      _custom != null ? _custom() : _method.getParameters();

  static PrayerMethod? byId(String? id) {
    for (final m in values) {
      if (m.id == id) return m;
    }
    return null;
  }
}

/// المذهب في وقت العصر: الجمهور (ظل الشيء مثله) أو الحنفية (مثليه).
enum PrayerMadhab {
  shafi('shafi', 'الجمهور — العصر حين يصير ظل الشيء مثله (سوى ظل الزوال)'),
  hanafi('hanafi', 'الحنفية — العصر حين يصير ظل الشيء مثليه (سوى ظل الزوال)');

  final String id;
  final String label;
  const PrayerMadhab(this.id, this.label);

  static PrayerMadhab byId(String? id) =>
      id == 'hanafi' ? PrayerMadhab.hanafi : PrayerMadhab.shafi;
}

/// قاعدة تحديد الفجر والعشاء في العروض العالية، حيث قد لا يغيب الشفق أو يقصر الليل.
/// «تلقائي»: سُبع الليل فوق خط عرض ٤٨°، ونصف الليل دونه (توصية مكتبة Adhan).
enum PrayerHighLat {
  auto('auto', 'تلقائي (موصى به)'),
  seventh('seventh', 'سُبع الليل'),
  middle('middle', 'منتصف الليل'),
  angle('angle', 'زاوية الشفق');

  final String id;
  final String label;
  const PrayerHighLat(this.id, this.label);

  static PrayerHighLat byId(String? id) {
    for (final v in values) {
      if (v.id == id) return v;
    }
    return PrayerHighLat.auto;
  }
}

/// ما فوق هذا العرض يظهر أثر القاعدة في الصيف/الشتاء؛ ويُعرض خيارها في الإعدادات.
const double kHighLatitudeDeg = 48;

/// عرض «أقرب البلاد» للمناطق القطبية حيث لا تغيب الشمس أو لا تطلع.
const double kPolarFallbackLat = 48.5;

/// الجمهور على العصر بظل المثل، والحنفية بالمثلين: الافتراضي حسب طريقة المنطقة
/// (طريقة كراتشي تُستعمل مع الحنفي في جنوب آسيا). لا يُطبَّق إلا إن لم يختر المستخدم.
PrayerMadhab defaultMadhabFor(PrayerMethod m) =>
    m == PrayerMethod.karachi ? PrayerMadhab.hanafi : PrayerMadhab.shafi;

/// هل [a] تبعد عن [b] أكثر من [km] كيلومتر؟
bool isFarFrom(double aLat, double aLon, double bLat, double bLon, double km) =>
    _distanceKm(aLat, aLon, bLat, bLon) >= km;

enum PrayerLocationSource { gps, city }

/// جدول يوم واحد بتوقيت جهاز المستخدم.
class PrayerDay {
  final DateTime date; // منتصف ليل ذلك اليوم محلياً
  final Map<PrayerKind, DateTime> times;
  const PrayerDay(this.date, this.times);

  DateTime operator [](PrayerKind k) => times[k]!;
}

/// الحساب نفسه كدالة نقية (بلا تخزين ولا واجهة) — قابلة للاختبار.
///
/// طريقة أم القرى: العشاء بعد المغرب بـ٩٠ دقيقة، وفي رمضان بـ١٢٠ (كما في
/// تقويم أم القرى). رمضان يُعرف من جدول أم القرى المضمَّن (انظر [isRamadanUmmAlQura]).
PrayerDay computePrayerDay({
  required double lat,
  required double lon,
  required DateTime date,
  required PrayerMethod method,
  required PrayerMadhab madhab,
  PrayerHighLat highLat = PrayerHighLat.auto,
  tz.Location? zone,
}) {
  adhan.PrayerTimes calc(double useLat, DateTime d) {
    final params = method._buildParams();
    params.madhab =
        madhab == PrayerMadhab.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    // «زاوية الشفق» تحتاج زاوية للعشاء؛ طرق الفاصل الزمني (أم القرى، قطر) تعود لسُبع الليل.
    final rule = switch (highLat) {
      PrayerHighLat.middle => adhan.HighLatitudeRule.middle_of_the_night,
      PrayerHighLat.seventh => adhan.HighLatitudeRule.seventh_of_the_night,
      PrayerHighLat.angle => params.ishaAngle == null
          ? adhan.HighLatitudeRule.seventh_of_the_night
          : adhan.HighLatitudeRule.twilight_angle,
      PrayerHighLat.auto => useLat.abs() > kHighLatitudeDeg
          ? adhan.HighLatitudeRule.seventh_of_the_night
          : adhan.HighLatitudeRule.middle_of_the_night,
    };
    params.highLatitudeRule = rule;
    if (method == PrayerMethod.ummAlQura && isRamadanUmmAlQura(date)) {
      params.adjustments.isha = params.adjustments.isha + 30;
    }
    return adhan.PrayerTimes(
      adhan.Coordinates(useLat, lon),
      adhan.DateComponents(d.year, d.month, d.day),
      params,
    );
  }

  adhan.PrayerTimes forDate(DateTime d) {
    try {
      return calc(lat, d);
    } on ArgumentError {
      // نهار أو ليل قطبي (الشمس لا تغيب/لا تطلع): تُحسب المواقيت بخط عرض «أقرب
      // البلاد» ٤٨٫٥° على الطول نفسه، وهو ما تفتي به المجامع الفقهية لهذه المناطق.
      return calc(lat < 0 ? -kPolarFallbackLat : kPolarFallbackLat, d);
    }
  }

  // [date] هو يوم الموقع المحلي. المكتبة تحسب على يوم UTC، وقرب خط التاريخ
  // (تونغا، ساموا، كيريباتي: توقيت +١٣/+١٤ على طول غربي) يقع ظهر اليوم المحلي
  // في يوم UTC السابق، فتخرج مواقيت الغد. نختار اليوم الذي يقع ظهره محلياً في
  // التاريخ المطلوب ([zone] = منطقة الموقع، وnull = منطقة الجهاز).
  bool onDate(DateTime t) {
    final w = zone == null ? t.toLocal() : tz.TZDateTime.from(t, zone);
    return w.year == date.year && w.month == date.month && w.day == date.day;
  }

  var pt = forDate(date);
  var utcDay = date;
  if (!onDate(pt.dhuhr)) {
    for (final shift in const [-1, 1]) {
      final d = DateTime(date.year, date.month, date.day + shift);
      final alt = forDate(d);
      if (onDate(alt.dhuhr)) {
        pt = alt;
        utcDay = d;
        break;
      }
    }
  }
  if (method == PrayerMethod.ummAlQura && lat.abs() <= kHighLatitudeDeg) {
    final official = ummAlQuraDisplayTimes(lat, lon, utcDay, madhab,
        ramadan: isRamadanUmmAlQura(date));
    if (official != null) {
      return PrayerDay(DateTime(date.year, date.month, date.day), official);
    }
  }
  return PrayerDay(DateTime(date.year, date.month, date.day), {
    PrayerKind.fajr: pt.fajr,
    PrayerKind.sunrise: pt.sunrise,
    PrayerKind.dhuhr: pt.dhuhr,
    PrayerKind.asr: pt.asr,
    PrayerKind.maghrib: pt.maghrib,
    PrayerKind.isha: pt.isha,
  });
}

/// أوقات أم القرى كما يعرضها تقويم أم القرى الرسمي (ummulqura.org.sa).
///
/// الحساب نفسه (فجر ١٨٫٥°، عشاء بعد المغرب بـ٩٠ دقيقة و١٢٠ في رمضان)، لكن
/// التقويم الرسمي لا يقرّب لأقرب دقيقة كما تفعل مكتبة adhan. القاعدة مستخرجة
/// بمطابقة جداوله المنشورة (١٦ موقعاً بإحداثياته الرسمية في يومين: ٩٤ من ٩٦ وقتاً
/// مطابقة تماماً والباقي دقيقة واحدة — انظر test/prayer_official_timetables_test):
/// الشروق للأسفل، والظهر والمغرب والعشاء للأعلى، والفجر والعصر بعد نصف دقيقة للأعلى.
/// null إن تعذّر الحساب (لا شروق/غروب)، فيعود المستدعي لحساب المكتبة.
Map<PrayerKind, DateTime>? ummAlQuraDisplayTimes(
  double lat,
  double lon,
  DateTime utcDay,
  PrayerMadhab madhab, {
  required bool ramadan,
}) {
  final base = DateTime.utc(utcDay.year, utcDay.month, utcDay.day);
  final st = SolarTime(base, adhan.Coordinates(lat, lon));
  final fajr = st.hourAngle(-18.5, false);
  final asr = st.afternoon(madhab == PrayerMadhab.hanafi
      ? ShadowLength.double
      : ShadowLength.single);
  final isha = st.sunset + (ramadan ? 2.0 : 1.5);
  if (![fajr, st.sunrise, st.transit, asr, st.sunset].every((h) => h.isFinite)) {
    return null;
  }
  DateTime at(int minute) => base.add(Duration(minutes: minute)).toLocal();
  int up(double h) => (h * 60).ceil();
  int upHalf(double h) => (h * 60 + 0.5).ceil();
  int down(double h) => (h * 60).floor();
  return {
    PrayerKind.fajr: at(upHalf(fajr)),
    PrayerKind.sunrise: at(down(st.sunrise)),
    PrayerKind.dhuhr: at(up(st.transit)),
    PrayerKind.asr: at(upHalf(asr)),
    PrayerKind.maghrib: at(up(st.sunset)),
    PrayerKind.isha: at(up(isha)),
  };
}

/// اتجاه القبلة بالدرجات من الشمال الحقيقي مع عقارب الساعة.
double qiblaBearing(double lat, double lon) =>
    adhan.Qibla(adhan.Coordinates(lat, lon)).direction;

/// المسافة التقريبية بالكيلومتر بين نقطتين (haversine).
double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.min(1.0, math.sqrt(a)));
}

/// الطريقة الافتراضية لموقع GPS: طريقة أقرب مدينة جاهزة في نطاق ٣٠٠ كم (الكويت،
/// قطر، الإمارات، مصر، تركيا…)، وإلا أم القرى داخل السعودية، وإلا رابطة العالم
/// الإسلامي. المستخدم يغيّرها من الإعدادات.
PrayerMethod defaultMethodFor(double lat, double lon) {
  PrayerCity? nearest;
  var best = 300.0;
  for (final c in kPrayerCities) {
    final d = _distanceKm(lat, lon, c.lat, c.lon);
    if (d <= best) {
      best = d;
      nearest = c;
    }
  }
  final byCity = nearest == null ? null : PrayerMethod.byId(nearest.method);
  if (byCity != null) return byCity;
  final inSaudi = lat >= 16 && lat <= 32.2 && lon >= 34.5 && lon <= 50.8;
  return inSaudi ? PrayerMethod.ummAlQura : PrayerMethod.muslimWorldLeague;
}

/// نص الموقع حين لا تُعرف مدينة قريبة.
const String kUnknownPlaceLabel = 'موقعك الحالي';

/// أقرب مدينة تُعدّ «مدينتك» (كم)، وبعدها حتى [_kNearKm] يُكتب «قرب …».
/// طرق تحققنا من مطابقتها لجدول الجهة الرسمية المنشور (±١ دقيقة؛ انظر
/// test/prayer_official_timetables_test.dart) → البلد الذي تحقّقت فيه. خارج هذا
/// البلد تبقى الطريقة «حساباً عاماً» حتى يُتحقق من جدول رسمي.
const Map<PrayerMethod, String> kVerifiedMethodCountry = {
  PrayerMethod.ummAlQura: 'السعودية',
  PrayerMethod.jakim: 'ماليزيا',
  PrayerMethod.jordan: 'الأردن',
  PrayerMethod.kemenag: 'إندونيسيا',
  PrayerMethod.turkey: 'تركيا',
  PrayerMethod.singapore: 'سنغافورة',
  PrayerMethod.egyptian: 'مصر',
};

const double _kInCityKm = 40;
const double _kNearKm = 90;

final List<PrayerCity> _kAllPlaces = [...kPrayerCities, ...kSaudiPlaces];

/// اسم المدينة لإحداثيات GPS: أقرب مدينة معروفة ضمن ٤٠ كم، وإلا «قرب X» ضمن
/// ٩٠ كم، وإلا «موقعك الحالي». المطابقة محلية على الجهاز (لا خدمة ترجمة عناوين
/// خارجية) حتى لا يغادر الموقع الجهاز أبداً، كما في سياسة الخصوصية.
String placeLabelFor(double lat, double lon) {
  PrayerCity? best;
  var bestKm = double.infinity;
  for (final c in _kAllPlaces) {
    final d = _distanceKm(lat, lon, c.lat, c.lon);
    if (d < bestKm) {
      bestKm = d;
      best = c;
    }
  }
  if (best == null || bestKm > _kNearKm) return kUnknownPlaceLabel;
  final name =
      best.country == 'السعودية' ? best.name : '${best.name}، ${best.country}';
  return bestKm <= _kInCityKm ? name : 'قرب $name';
}

/// أقرب مكان معروف ضمن ٩٠ كم (محلياً، بلا خدمة خارجية)، وإلا null.
PrayerCity? nearestPlace(double lat, double lon) {
  PrayerCity? best;
  var bestKm = _kNearKm;
  for (final c in _kAllPlaces) {
    final d = _distanceKm(lat, lon, c.lat, c.lon);
    if (d <= bestKm) {
      bestKm = d;
      best = c;
    }
  }
  return best;
}

enum GpsOutcome { ok, serviceOff, denied, deniedForever, failed }

/// إعدادات المواقيت المحفوظة على الجهاز فقط — لا شيء يُرسل لأي خادم.
class PrayerTimesService extends ChangeNotifier {
  PrayerTimesService._();
  static final PrayerTimesService instance = PrayerTimesService._();

  static const _kLat = 'prayer_lat';
  static const _kLon = 'prayer_lon';
  static const _kLabel = 'prayer_label';
  static const _kSource = 'prayer_source';
  static const _kMethod = 'prayer_method';
  static const _kMethodManual = 'prayer_method_manual';
  static const _kMadhab = 'prayer_madhab';
  static const _kMadhabManual = 'prayer_madhab_manual';
  static const _kHighLat = 'prayer_high_lat';

  double? _lat;
  double? _lon;
  String _label = '';
  PrayerLocationSource? _source;
  PrayerMethod _method = PrayerMethod.ummAlQura;
  bool _methodManual = false;
  PrayerMadhab _madhab = PrayerMadhab.shafi;
  bool _madhabManual = false;
  PrayerHighLat _highLat = PrayerHighLat.auto;
  bool _loaded = false;
  final Map<String, PrayerDay> _cache = {};

  bool get isLoaded => _loaded;
  bool get hasLocation => _lat != null && _lon != null;
  double? get lat => _lat;
  double? get lon => _lon;
  String get label => _label;
  PrayerLocationSource? get source => _source;
  PrayerMethod get method => _method;
  PrayerMadhab get madhab => _madhab;
  PrayerHighLat get highLat => _highLat;

  /// بلد الموقع (أقرب مكان معروف ضمن ٩٠ كم)، وإلا null.
  String? get country =>
      hasLocation ? nearestPlace(_lat!, _lon!)?.country : null;

  /// الطريقة الحالية مطابقة لجدول الجهة الرسمية في بلد الموقع.
  bool get methodVerifiedHere {
    final c = country;
    return c != null && kVerifiedMethodCountry[_method] == c;
  }

  /// خط عرض مرتفع: الفجر والعشاء قد يُقدَّران صيفاً بقاعدة العروض العالية.
  bool get isHighLatitude => hasLocation && _lat!.abs() > kHighLatitudeDeg;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final lat = p.getDouble(_kLat), lon = p.getDouble(_kLon);
      if (lat != null && lon != null && lat.abs() <= 90 && lon.abs() <= 180) {
        _lat = lat;
        _lon = lon;
      }
      _label = p.getString(_kLabel) ?? '';
      _source = switch (p.getString(_kSource)) {
        'gps' => PrayerLocationSource.gps,
        'city' => PrayerLocationSource.city,
        _ => null,
      };
      // من حُفظ موقعه قبل ظهور اسم المدينة ما زال عنده «موقعك الحالي»: نحسبه
      // من الإحداثيات المحفوظة (محلياً) دون طلب GPS جديد.
      if (_source == PrayerLocationSource.gps && hasLocation) {
        _label = placeLabelFor(_lat!, _lon!);
      }
      _method =
          PrayerMethod.byId(p.getString(_kMethod)) ?? PrayerMethod.ummAlQura;
      _methodManual = p.getBool(_kMethodManual) ?? false;
      _madhab = PrayerMadhab.byId(p.getString(_kMadhab));
      _madhabManual = p.getBool(_kMadhabManual) ?? false;
      _highLat = PrayerHighLat.byId(p.getString(_kHighLat));
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerTimesService.load');
    }
    _loaded = true;
    _cache.clear();
    notifyListeners();
  }

  PrayerDay? dayFor(DateTime date) {
    if (!hasLocation) return null;
    final key = '${date.year}-${date.month}-${date.day}';
    final hit = _cache[key];
    if (hit != null) return hit;
    try {
      return _cache[key] = computePrayerDay(
        lat: _lat!,
        lon: _lon!,
        date: date,
        method: _method,
        madhab: _madhab,
        highLat: _highLat,
      );
    } catch (e, st) {
      // مكتبة الحساب قد ترفض إحداثيات متطرفة؛ الواجهة تتعامل مع null.
      ErrorReporter.report(e, st, context: 'PrayerTimesService.dayFor');
      return null;
    }
  }

  PrayerDay? get today => dayFor(DateTime.now());

  /// أقرب صلاة بعد [now] (اليوم أو غداً). الشروق لا يُحسب.
  ({PrayerKind kind, DateTime time})? nextPrayer(DateTime now) {
    if (!hasLocation) return null;
    for (var offset = 0; offset <= 1; offset++) {
      final day = dayFor(DateTime(now.year, now.month, now.day + offset));
      if (day == null) continue;
      for (final k in PrayerKind.values) {
        if (!k.isPrayer) continue;
        if (day[k].isAfter(now)) return (kind: k, time: day[k]);
      }
    }
    return null;
  }

  /// آخر صلاة (أذان) حلّ وقتها حتى [now]: اليوم أو أمس. الشروق لا يُحسب.
  ({PrayerKind kind, DateTime time})? previousPrayer(DateTime now) {
    if (!hasLocation) return null;
    for (var offset = 0; offset >= -1; offset--) {
      final day = dayFor(DateTime(now.year, now.month, now.day + offset));
      if (day == null) continue;
      for (final k in PrayerKind.values.reversed) {
        if (!k.isPrayer) continue;
        if (!day[k].isAfter(now)) return (kind: k, time: day[k]);
      }
    }
    return null;
  }

  /// اتجاه القبلة من الموقع المحفوظ، أو null بلا موقع.
  double? get qibla => hasLocation ? qiblaBearing(_lat!, _lon!) : null;

  Future<void> setCity(PrayerCity c) async {
    _lat = c.lat;
    _lon = c.lon;
    _label = c.name;
    _source = PrayerLocationSource.city;
    if (!_methodManual) _method = PrayerMethod.byId(c.method) ?? _method;
    if (!_madhabManual) _madhab = defaultMadhabFor(_method);
    await _persist();
  }

  /// الموقع من الجهاز بدقة منخفضة (يكفي للمواقيت)، ويُقرَّب إلى منزلتين عشريتين
  /// (~١ كم) قبل الحفظ. لا يغادر الجهاز.
  Future<GpsOutcome> useGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return GpsOutcome.serviceOff;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        return GpsOutcome.deniedForever;
      }
      if (perm == LocationPermission.denied) return GpsOutcome.denied;
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 20),
          ),
        );
      } on TimeoutException {
        // GPS بطيء (داخل مبنى مثلاً): آخر موقع معروف يكفي لحساب المواقيت.
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) return GpsOutcome.failed;
      _lat = (pos.latitude * 100).round() / 100;
      _lon = (pos.longitude * 100).round() / 100;
      _label = placeLabelFor(_lat!, _lon!);
      _source = PrayerLocationSource.gps;
      if (!_methodManual) _method = defaultMethodFor(_lat!, _lon!);
      if (!_madhabManual) _madhab = defaultMadhabFor(_method);
      await _persist();
      return GpsOutcome.ok;
    } on TimeoutException {
      return GpsOutcome.failed;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerTimesService.useGps');
      return GpsOutcome.failed;
    }
  }

  Future<void> setMethod(PrayerMethod m) async {
    _method = m;
    _methodManual = true;
    await _persist();
  }

  Future<void> setMadhab(PrayerMadhab m) async {
    _madhab = m;
    _madhabManual = true;
    await _persist();
  }

  Future<void> setHighLat(PrayerHighLat v) async {
    _highLat = v;
    await _persist();
  }

  /// للمسافر: إن كان الموقع من الجهاز والإذن ممنوحاً من قبل (دون طلب إذن جديد)
  /// نحدّث المواقيت إن ابتعد الجهاز أكثر من [thresholdKm]. المعالجة على الجهاز فقط.
  /// - [fresh] false (الإقلاع): آخر موقع معروف فقط، سريع ولا يوقف التشغيل.
  /// - [fresh] true (العودة للتطبيق): قراءة جديدة منخفضة الدقة بمهلة ٨ ثوانٍ، وعند
  ///   فشلها آخر موقع معروف (قد يكون قديماً على iOS فلا نكتفي به عند العودة).
  /// يعيد true إن تغيّر الموقع.
  Future<bool> refreshGpsIfMoved(
      {double thresholdKm = 10, bool fresh = false}) async {
    try {
      if (_source != PrayerLocationSource.gps || !hasLocation) return false;
      final perm = await Geolocator.checkPermission();
      if (perm != LocationPermission.whileInUse &&
          perm != LocationPermission.always) {
        return false;
      }
      Position? pos;
      if (fresh) {
        try {
          pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 8),
            ),
          );
        } on TimeoutException {
          pos = null;
        }
      }
      pos ??= await Geolocator.getLastKnownPosition();
      if (pos == null) return false;
      final lat = (pos.latitude * 100).round() / 100;
      final lon = (pos.longitude * 100).round() / 100;
      if (!isFarFrom(_lat!, _lon!, lat, lon, thresholdKm)) return false;
      _lat = lat;
      _lon = lon;
      _label = placeLabelFor(lat, lon);
      if (!_methodManual) _method = defaultMethodFor(lat, lon);
      if (!_madhabManual) _madhab = defaultMadhabFor(_method);
      await _persist();
      return true;
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerTimesService.refreshGpsIfMoved');
      return false;
    }
  }

  Future<void> _persist() async {
    _cache.clear();
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      if (hasLocation) {
        await p.setDouble(_kLat, _lat!);
        await p.setDouble(_kLon, _lon!);
      }
      await p.setString(_kLabel, _label);
      if (_source != null) await p.setString(_kSource, _source!.name);
      await p.setString(_kMethod, _method.id);
      await p.setBool(_kMethodManual, _methodManual);
      await p.setString(_kMadhab, _madhab.id);
      await p.setBool(_kMadhabManual, _madhabManual);
      await p.setString(_kHighLat, _highLat.id);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'PrayerTimesService.persist');
    }
  }

  /// للاختبارات فقط.
  @visibleForTesting
  void debugSet({
    double? lat,
    double? lon,
    String label = '',
    PrayerMethod method = PrayerMethod.ummAlQura,
    PrayerMadhab madhab = PrayerMadhab.shafi,
    PrayerHighLat highLat = PrayerHighLat.auto,
    bool madhabManual = false,
  }) {
    _lat = lat;
    _lon = lon;
    _label = label;
    _method = method;
    _madhab = madhab;
    _highLat = highLat;
    _madhabManual = madhabManual;
    _loaded = true;
    _cache.clear();
    notifyListeners();
  }
}
