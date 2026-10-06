import 'package:flutter/material.dart';

import 'package:roqia_altatil/services/mushaf_pages_repository.dart';

/// صفحة واحدة من مصحف المدينة كما في المطبوع (١٥ سطراً، تقسيم الأسطر نفسه).
///
/// كل كلمة رمز واحد من خط الصفحة (انظر [MushafPagesRepository])، فلا يُعاد
/// تشكيل الحروف ولا تُغيَّر: الرسم هو رسم المجمع. التخطيط يُحسب على «لوحة»
/// ثابتة المقاييس ثم تُصغَّر/تُكبَّر كلها بنسبة واحدة لتلائم الشاشة، فتبقى
/// النسب كما هي على كل الأجهزة.
class MushafPageView extends StatefulWidget {
  const MushafPageView({
    super.key,
    required this.page,
    required this.color,
    required this.accent,
  });

  final MushafPage page;
  final Color color;

  /// لون إطار اسم السورة.
  final Color accent;

  @override
  State<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends State<MushafPageView> {
  late Future<void> _fonts;

  @override
  void initState() {
    super.initState();
    _fonts = MushafPagesRepository.instance.ensureFonts(widget.page.fonts);
  }

  @override
  void didUpdateWidget(MushafPageView old) {
    super.didUpdateWidget(old);
    if (old.page.number != widget.page.number) {
      _fonts = MushafPagesRepository.instance.ensureFonts(widget.page.fonts);
    }
  }

  void _retry() => setState(() {
        _fonts = MushafPagesRepository.instance.ensureFonts(widget.page.fonts);
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fonts,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('تعذّر تحميل الصفحة، أعد المحاولة'),
            ),
          );
        }
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        // لا تكبير للخط ولا غمق نظام: يفسدان قياس الأسطر.
        final mq = MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.noScaling, boldText: false);
        return MediaQuery(
          data: mq,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: FittedBox(
              fit: BoxFit.contain,
              child: MushafPageCanvas(
                page: widget.page,
                color: widget.color,
                accent: widget.accent,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// لوحة الصفحة بمقاييس التصميم (لا تتأثر بحجم الشاشة).
class MushafPageCanvas extends StatelessWidget {
  const MushafPageCanvas({
    super.key,
    required this.page,
    required this.color,
    required this.accent,
  });

  final MushafPage page;
  final Color color;
  final Color accent;

  /// حجم الخط على اللوحة.
  static const double fs = 30;

  /// أعرض سطر في المصحف ≈ ١٧٫٤ em؛ العرض الكامل أوسع قليلاً.
  static const double fullWidth = fs * 17.6;
  static const double lineHeight = fs * 1.9;
  static const int fullLines = 15;

  /// السطر «ممتلئ» (يُوزَّع) إن بلغ هذه النسبة من العرض المستهدف، وإلا يتوسّط
  /// بمسافاته الطبيعية (آخر سطر في السورة، ونحوه).
  static const double justifyRatio = 0.9;

  static double _glyphWidth(String glyph, String family, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(fontFamily: family, fontSize: size, height: 1.0),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    final w = tp.width;
    tp.dispose();
    return w;
  }

  /// عرض السطر الطبيعي = مجموع عرض كلماته (كل كلمة تُرسم في ويدجت مستقل، فمجموع
  /// القياسات المنفردة هو ما يلزم لضمان عدم الفيضان عند التوزيع).
  static double natural(String glyphs, String family, double size) => [
        for (final r in glyphs.runes) _glyphWidth(String.fromCharCode(r), family, size),
      ].fold(0.0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final widths = <MushafLine, double>{
      for (final l in page.lines)
        if (l.kind == MushafLineKind.body) l: natural(l.glyphs, l.font, fs),
    };
    final maxBody = widths.isEmpty ? fullWidth : widths.values.reduce((a, b) => a > b ? a : b);
    // الصفحات القصيرة (١ و٢) أضيق: تُوزَّع الأسطر على أعرض سطر فيها (+هامش قياس).
    final target = maxBody >= fullWidth * 0.85 ? fullWidth : maxBody + 4;
    final height = lineHeight * (page.lines.length >= 15 ? fullLines : page.lines.length + 1);

    return SizedBox(
      width: fullWidth,
      height: height,
      child: Column(
        mainAxisAlignment: page.lines.length >= 15
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [for (final l in page.lines) _buildLine(l, target, widths[l])],
      ),
    );
  }

  Widget _buildLine(MushafLine l, double target, double? nat) {
    final style = TextStyle(
      fontFamily: l.font,
      fontSize: l.kind == MushafLineKind.suraName ? fs * 1.15 : fs,
      color: color,
      height: 1.0,
    );
    switch (l.kind) {
      case MushafLineKind.suraName:
        return SizedBox(
          height: lineHeight,
          width: fullWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: accent, width: 1.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(l.glyphs, style: style, textDirection: TextDirection.rtl)),
          ),
        );
      case MushafLineKind.basmala:
        return SizedBox(
          height: lineHeight,
          width: fullWidth,
          child: Center(child: Text(l.glyphs, style: style, textDirection: TextDirection.rtl)),
        );
      case MushafLineKind.body:
        final justify = (nat ?? 0) >= target * justifyRatio;
        final words = [
          for (final r in l.glyphs.runes)
            Text(String.fromCharCode(r), style: style, textDirection: TextDirection.rtl),
        ];
        return SizedBox(
          height: lineHeight,
          width: fullWidth,
          child: Center(
            child: SizedBox(
              width: justify ? target : null,
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisSize: justify ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment:
                    justify ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: words,
              ),
            ),
          ),
        );
    }
  }
}
