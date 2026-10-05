/// اسم التطبيق ونسبة «رقية التعطيل» — مصدر واحد لكل الشاشات والنصوص.
///
/// التطبيق اسمه «الرقية الشاملة» (اسم الأيقونة والشريط العلوي). واسمه الكامل
/// في المتجر [fullName]. أما «رقية التعطيل» فهي رقية الشيخ فهد القرني وحدها،
/// وتُنسب له صراحةً حيثما ظهرت.
class AppIdentity {
  AppIdentity._();

  static const String name = 'الرقية الشاملة';

  /// الاسم الكامل (اسم التطبيق في App Store؛ حدّه ٣٠ حرفاً).
  static const String fullName = 'رقية شاملة رقية تعطيل ومصحف';

  /// عبارة الصدقة الجارية (الرئيسية ونص مشاركة التطبيق).
  static const String sadaqaLine =
      'شارك التطبيق صدقةً جارية عنّي وعن كل من نشره وشاركه';
  static const String taTil = 'رقية التعطيل';
  static const String taTilOwner = 'لفضيلة الشيخ فهد القرني';

  /// «رقية التعطيل لفضيلة الشيخ فهد القرني».
  static const String taTilAttribution = '$taTil $taTilOwner';
}
