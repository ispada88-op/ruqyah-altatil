/// أصوات الأذان المضمَّنة لتنبيه دخول الوقت (بإذن وزارة الشؤون الإسلامية لاستعمال
/// أصوات مؤذني الحرمين). [id] يُحفظ في الجهاز ولا يتغيّر أبداً.
///
/// - iOS: صوت الإشعار ≤ ٣٠ ثانية بصيغة wav، فيُشغَّل مقطع من أول الأذان
///   ([clipAsset]) يُنسخ إلى Library/Sounds عند الجدولة.
/// - أندرويد: الأذان كاملاً من res/raw/[androidRaw].mp3، بقناة مستقلة لكل صوت
///   لأن صوت القناة لا يتغيّر بعد إنشائها.
enum AdhanVoice {
  none('none', 'صوت الإشعار المعتاد', []),
  qassas('qassas', 'محمد مروان قصاص',
      [28.0, 28.0, 27.19, 28.0, 28.0, 22.97, 28.0, 22.39, 15.15]),
  a1('a1', 'أذان ٢', [28.0, 28.0, 28.0, 28.0, 24.65, 28.0, 28.0, 9.75]),
  a2('a2', 'أذان ٣', [28.0, 28.0, 28.0, 28.0, 20.78]);

  final String id;
  final String label;

  /// مدد مقاطع الأذان الكامل بالثواني (assets/adhan/seg/{id}_{n}.wav). iOS يقصّ صوت
  /// الإشعار عند ٣٠ث، فيُجدوَل الأذان الكامل على شكل سلسلة إشعارات، مقطع لكل إشعار.
  final List<double> segmentSecs;
  const AdhanVoice(this.id, this.label, this.segmentSecs);

  int get segmentCount => segmentSecs.length;

  /// ‏n من ١ إلى [segmentCount].
  String segmentAsset(int n) => 'assets/adhan/seg/${id}_$n.wav';
  String segmentSoundName(int n) => 'adhan_${id}_$n.wav';

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

/// سلسلة أذان الفجر الكامل على iOS: عدد أقرب أيام فجر تُجدوَل سلسلتها، وأول ID
/// (فوق ١٠٠٠+١٦×٧ لتنبيهات الصلاة)، وفاصل ثانية بين المقاطع لتأخر وصول الإشعار.
const int kAdhanChainDays = 2;
const int kAdhanChainIdBase = 2000;
const double kAdhanChainGapSec = 0.5;
