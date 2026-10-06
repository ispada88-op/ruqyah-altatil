/// اسم التطبيق ونسبة «رقية التعطيل» — مصدر واحد لكل الشاشات والنصوص.
///
/// التطبيق اسمه «الرقية الشاملة» (اسم الأيقونة والشريط العلوي). واسمه الكامل
/// «الرقية الشاملة ورقية التعطيل والمصحف الشريف» [fullName]، يظهر في App Store
/// على سطرين: [storeName] (≤ ٣٠ حرفاً) ثم [storeSubtitle] (≤ ٣٠) فيُقرأ كجملة واحدة.
/// أما «رقية التعطيل» فهي رقية الشيخ فهد القرني وحدها، وتُنسب له صراحةً حيثما ظهرت.
class AppIdentity {
  AppIdentity._();

  static const String name = 'الرقية الشاملة';

  /// اسم التطبيق في App Store (حدّه ٣٠ حرفاً).
  static const String storeName = 'الرقية الشاملة ورقية التعطيل';

  /// العنوان الفرعي في App Store (حدّه ٣٠ حرفاً) — يكمل [storeName] بالواو.
  static const String storeSubtitle = 'والمصحف الشريف بلا إعلانات';

  /// الاسم الكامل في النصوص الحرة (المشاركة…): بلا حدّ الثلاثين.
  static const String fullName = 'الرقية الشاملة ورقية التعطيل والمصحف الشريف';

  /// عبارة الصدقة الجارية (الرئيسية ونص مشاركة التطبيق).
  static const String sadaqaLine =
      'شارك التطبيق صدقةً جارية عنّي وعن كل من نشره وشاركه';

  /// بطاقة الرئيسية تحت البسملة: اسم التطبيق ثم نسبة رقية التعطيل للشيخ.
  static const String homeTitle = 'الرقية الشاملة والمصحف';
  static const String homeTaTilLine = 'ورقية التعطيل عن الشيخ فهد القرني';

  static const String taTil = 'رقية التعطيل';
  static const String taTilOwner = 'لفضيلة الشيخ فهد القرني';

  /// «رقية التعطيل لفضيلة الشيخ فهد القرني».
  static const String taTilAttribution = '$taTil $taTilOwner';
}
