/// مدن جاهزة للمواقيت بدون إذن الموقع. الإحداثيات تقريبية (مركز المدينة) وتكفي
/// للمواقيت. [method] هو معرّف طريقة الحساب الافتراضية للمنطقة (انظر
/// `PrayerMethod.id` في `prayer_times_service.dart`).
class PrayerCity {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final String method;
  const PrayerCity(this.name, this.country, this.lat, this.lon, this.method);

  String get id => '$country|$name';
}

const List<PrayerCity> kPrayerCities = [
  // السعودية — أم القرى
  PrayerCity('مكة المكرمة', 'السعودية', 21.4225, 39.8262, 'umm_al_qura'),
  PrayerCity('المدينة المنورة', 'السعودية', 24.4672, 39.6111, 'umm_al_qura'),
  PrayerCity('الرياض', 'السعودية', 24.7136, 46.6753, 'umm_al_qura'),
  PrayerCity('جدة', 'السعودية', 21.4858, 39.1925, 'umm_al_qura'),
  PrayerCity('الدمام', 'السعودية', 26.4207, 50.0888, 'umm_al_qura'),
  PrayerCity('الخبر', 'السعودية', 26.2172, 50.1971, 'umm_al_qura'),
  PrayerCity('الأحساء', 'السعودية', 25.3648, 49.5873, 'umm_al_qura'),
  PrayerCity('الطائف', 'السعودية', 21.2703, 40.4158, 'umm_al_qura'),
  PrayerCity('أبها', 'السعودية', 18.2164, 42.5053, 'umm_al_qura'),
  PrayerCity('خميس مشيط', 'السعودية', 18.3093, 42.7293, 'umm_al_qura'),
  PrayerCity('جازان', 'السعودية', 16.8892, 42.5511, 'umm_al_qura'),
  PrayerCity('نجران', 'السعودية', 17.4917, 44.1322, 'umm_al_qura'),
  PrayerCity('الباحة', 'السعودية', 20.0129, 41.4677, 'umm_al_qura'),
  PrayerCity('تبوك', 'السعودية', 28.3998, 36.5715, 'umm_al_qura'),
  PrayerCity('حائل', 'السعودية', 27.5114, 41.7208, 'umm_al_qura'),
  PrayerCity('بريدة', 'السعودية', 26.3260, 43.9750, 'umm_al_qura'),
  PrayerCity('عرعر', 'السعودية', 30.9753, 41.0381, 'umm_al_qura'),
  PrayerCity('سكاكا', 'السعودية', 29.9697, 40.2064, 'umm_al_qura'),
  PrayerCity('ينبع', 'السعودية', 24.0895, 38.0618, 'umm_al_qura'),
  PrayerCity('الجبيل', 'السعودية', 27.0046, 49.6460, 'umm_al_qura'),
  // الخليج
  PrayerCity('المنامة', 'البحرين', 26.2285, 50.5860, 'umm_al_qura'),
  PrayerCity('مدينة الكويت', 'الكويت', 29.3759, 47.9774, 'kuwait'),
  PrayerCity('الدوحة', 'قطر', 25.2854, 51.5310, 'qatar'),
  PrayerCity('أبوظبي', 'الإمارات', 24.4539, 54.3773, 'dubai'),
  PrayerCity('دبي', 'الإمارات', 25.2048, 55.2708, 'dubai'),
  PrayerCity('مسقط', 'عُمان', 23.5880, 58.3829, 'umm_al_qura'),
  PrayerCity('صنعاء', 'اليمن', 15.3694, 44.1910, 'umm_al_qura'),
  PrayerCity('عدن', 'اليمن', 12.7855, 45.0187, 'umm_al_qura'),
  // الشام والعراق
  PrayerCity('عمّان', 'الأردن', 31.9454, 35.9284, 'egyptian'),
  PrayerCity('القدس', 'فلسطين', 31.7683, 35.2137, 'egyptian'),
  PrayerCity('دمشق', 'سوريا', 33.5138, 36.2765, 'egyptian'),
  PrayerCity('بيروت', 'لبنان', 33.8938, 35.5018, 'egyptian'),
  PrayerCity('بغداد', 'العراق', 33.3152, 44.3661, 'muslim_world_league'),
  // مصر وشمال أفريقيا
  PrayerCity('القاهرة', 'مصر', 30.0444, 31.2357, 'egyptian'),
  PrayerCity('الإسكندرية', 'مصر', 31.2001, 29.9187, 'egyptian'),
  PrayerCity('الخرطوم', 'السودان', 15.5007, 32.5599, 'egyptian'),
  PrayerCity('طرابلس', 'ليبيا', 32.8872, 13.1913, 'egyptian'),
  PrayerCity('تونس', 'تونس', 36.8065, 10.1815, 'muslim_world_league'),
  PrayerCity('الجزائر', 'الجزائر', 36.7538, 3.0588, 'muslim_world_league'),
  PrayerCity('الرباط', 'المغرب', 34.0209, -6.8416, 'muslim_world_league'),
  PrayerCity(
      'الدار البيضاء', 'المغرب', 33.5731, -7.5898, 'muslim_world_league'),
  PrayerCity('نواكشوط', 'موريتانيا', 18.0735, -15.9582, 'muslim_world_league'),
  // آسيا وأوروبا وأمريكا
  PrayerCity('إسطنبول', 'تركيا', 41.0082, 28.9784, 'turkey'),
  PrayerCity('كراتشي', 'باكستان', 24.8607, 67.0011, 'karachi'),
  PrayerCity('كوالالمبور', 'ماليزيا', 3.1390, 101.6869, 'singapore'),
  PrayerCity('جاكرتا', 'إندونيسيا', -6.2088, 106.8456, 'singapore'),
  PrayerCity('لندن', 'بريطانيا', 51.5072, -0.1276, 'muslim_world_league'),
  PrayerCity('باريس', 'فرنسا', 48.8566, 2.3522, 'muslim_world_league'),
  PrayerCity('برلين', 'ألمانيا', 52.5200, 13.4050, 'muslim_world_league'),
  PrayerCity('نيويورك', 'أمريكا', 40.7128, -74.0060, 'north_america'),
  PrayerCity('تورونتو', 'كندا', 43.6532, -79.3832, 'north_america'),
];
