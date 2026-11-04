/// أصوات الأذان المضمَّنة لتنبيه دخول الوقت (بإذن وزارة الشؤون الإسلامية لاستعمال
/// أصوات مؤذني الحرمين). [id] يُحفظ في الجهاز ولا يتغيّر أبداً.
///
/// - iOS: صوت الإشعار ≤ ٣٠ ثانية بصيغة wav، فيُشغَّل مقطع من أول الأذان
///   ([clipAsset]) يُنسخ إلى Library/Sounds عند الجدولة.
/// - أندرويد: الأذان كاملاً من res/raw/[androidRaw].mp3، بقناة مستقلة لكل صوت
///   لأن صوت القناة لا يتغيّر بعد إنشائها.
enum AdhanVoice {
  none('none', 'صوت الإشعار المعتاد'),
  qassas('qassas', 'محمد مروان قصاص'),
  a1('a1', 'أذان ٢'),
  a2('a2', 'أذان ٣');

  final String id;
  final String label;
  const AdhanVoice(this.id, this.label);

  static AdhanVoice byId(String? id) {
    for (final v in values) {
      if (v.id == id) return v;
    }
    return AdhanVoice.none;
  }

  String get clipAsset => 'assets/adhan/$id.wav';

  /// الأذان كاملاً للتشغيل داخل التطبيق (زر «جرّب»، وفتح إشعار الصلاة على iPhone).
  String get fullAsset => 'assets/adhan/$id.mp3';
  String get iosSoundName => 'adhan_$id.wav';
  String get androidRaw => 'adhan_$id';
  String get androidChannelId => 'prayer_adhan_$id';
}
