import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// تصحيح الانحراف المغناطيسي لبوصلة القبلة.
///
/// القبلة تُحسب من «الشمال الحقيقي»، بينما بوصلة أندرويد
/// (TYPE_ROTATION_VECTOR) تقرأ «الشمال المغناطيسي». الفرق بينهما هو الانحراف
/// المغناطيسي (شرقاً موجب). على iOS تعطي الحزمة الاتجاه الحقيقي أصلاً
/// (CLHeading.trueHeading) فلا تصحيح هناك.
///
/// الانحراف يُحسب على الجهاز من نموذج المجال المغناطيسي المدمج في أندرويد
/// (android.hardware.GeomagneticField) — بلا إنترنت، ولا يغادر الموقع الجهاز.
class MagneticDeclination {
  MagneticDeclination._();

  @visibleForTesting
  static const channel = MethodChannel('com.ruqyah.altatil/declination');

  /// الانحراف بالدرجات (شرقاً موجب) عند الإحداثيات، أو ٠ إن تعذّر.
  static Future<double> forLocation(double lat, double lon) async {
    if (kIsWeb || !Platform.isAndroid) return 0;
    try {
      final d = await channel.invokeMethod<double>('get', {
        'lat': lat,
        'lon': lon,
      });
      if (d == null || d.isNaN || d.abs() > 90) return 0;
      return d;
    } on MissingPluginException {
      return 0;
    } on PlatformException {
      return 0;
    }
  }
}

/// الاتجاه الحقيقي من قراءة البوصلة [heading] والانحراف [declination]،
/// داخل ٠..٣٦٠. القراءة السالبة (iOS: «تعذّر تحديد الاتجاه الحقيقي») = لا قراءة.
double? trueHeadingFrom(double? heading, double declination) {
  if (heading == null || heading.isNaN || heading < 0) return null;
  final t = (heading + declination) % 360;
  return t < 0 ? t + 360 : t;
}
