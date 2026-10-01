/// اسم التطبيق ونسبة «رقية التعطيل» — مصدر واحد لكل الشاشات والنصوص.
///
/// التطبيق اسمه «الرقية الشاملة». أما «رقية التعطيل» فهي رقية الشيخ فهد القرني
/// وحدها، وتُنسب له صراحةً حيثما ظهرت.
class AppIdentity {
  AppIdentity._();

  static const String name = 'الرقية الشاملة';
  static const String taTil = 'رقية التعطيل';
  static const String taTilOwner = 'لفضيلة الشيخ فهد القرني';

  /// «رقية التعطيل لفضيلة الشيخ فهد القرني».
  static const String taTilAttribution = '$taTil $taTilOwner';
}
