import 'package:flutter/material.dart';

/// نص قرآني بخط مجمع الملك فهد (`AppTextStyles.mushaf`).
///
/// الخط له وزن واحد فقط. عند تفعيل «النص الغامق» في iOS/Android يدمج
/// `Text` وزناً غامقاً في كل نص، فيصطنع المحرّك غمقاً مشوِّهاً يطمس التشكيل
/// وعلامات الوقف — لذلك يُعطَّل هنا لهذا النص وحده.
class QuranText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  const QuranText(
    this.data, {
    super.key,
    required this.style,
    this.textAlign,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(boldText: false),
      child: Text(data, style: style, textAlign: textAlign, textDirection: textDirection),
    );
  }
}
