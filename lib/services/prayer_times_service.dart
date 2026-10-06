import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      adhan.CalculationMethod.north_america);

  final String id;
  final String label;
  final adhan.CalculationMethod _method;
  const PrayerMethod(this.id, this.label, this._method);

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
/// تقويم أم القرى). رمضان يُعرف بالتحويل الجدولي — قد يخطئ يوماً عند حدّي الشهر.
PrayerDay computePrayerDay({
  required double lat,
  required double lon,
  required DateTime date,
  required PrayerMethod method,
  required PrayerMadhab madhab,
}) {
  final params = method._method.getParameters();
  params.madhab =
      madhab == PrayerMadhab.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
  if (method == PrayerMethod.ummAlQura && gregorianToHijri(date).isRamadan) {
    params.adjustments.isha = params.adjustments.isha + 30;
  }
  final pt = adhan.PrayerTimes(
    adhan.Coordinates(lat, lon),
    adhan.DateComponents(date.year, date.month, date.day),
    params,
  );
  return PrayerDay(DateTime(date.year, date.month, date.day), {
    PrayerKind.fajr: pt.fajr,
    PrayerKind.sunrise: pt.sunrise,
    PrayerKind.dhuhr: pt.dhuhr,
    PrayerKind.asr: pt.asr,
    PrayerKind.maghrib: pt.maghrib,
    PrayerKind.isha: pt.isha,
  });
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

  double? _lat;
  double? _lon;
  String _label = '';
  PrayerLocationSource? _source;
  PrayerMethod _method = PrayerMethod.ummAlQura;
  bool _methodManual = false;
  PrayerMadhab _madhab = PrayerMadhab.shafi;
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
    await _persist();
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
  }) {
    _lat = lat;
    _lon = lon;
    _label = label;
    _method = method;
    _madhab = madhab;
    _loaded = true;
    _cache.clear();
    notifyListeners();
  }
}
