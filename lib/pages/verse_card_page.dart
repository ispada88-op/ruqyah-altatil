import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/config/app_identity.dart';
import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/quran_repository.dart';
import 'package:roqia_altatil/services/share_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/quran_text.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// ألوان بطاقة الآية: (خلفية أولى، خلفية ثانية، نص الآية، المرجع/الزخرفة).
class VerseCardTheme {
  final String label;
  final Color from, to, ink, accent;
  const VerseCardTheme(this.label, this.from, this.to, this.ink, this.accent);
}

const List<VerseCardTheme> kVerseCardThemes = [
  VerseCardTheme('زمردي', Color(0xFF006B6B), Color(0xFF004B4B), Colors.white,
      Color(0xFFE5C158)),
  VerseCardTheme('عاجي', Color(0xFFFFFEF0), Color(0xFFF5F5DC),
      Color(0xFF1A1A1A), Color(0xFF7A5F0F)),
  VerseCardTheme('ليلي', Color(0xFF1A1A2E), Color(0xFF0F0F1E),
      Color(0xFFFAFAFA), Color(0xFFD4AF37)),
];

/// البطاقة نفسها (تُرسم كما تُلتقط صورةً): آية واحدة بنص مجمع الملك فهد دون
/// أي تغيير في الحروف، ومرجعها، واسم التطبيق.
class VerseCard extends StatelessWidget {
  const VerseCard({
    super.key,
    required this.verse,
    required this.surah,
    required this.ayah,
    required this.theme,
  });

  /// نص الآية مع علامة نهايتها ([withAyahNumber]).
  final String verse;
  final int surah;
  final int ayah;
  final VerseCardTheme theme;

  static const double width = 360;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.from, theme.to],
          ),
          border:
              Border.all(color: theme.accent.withValues(alpha: 0.7), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuranText(
              verse,
              textAlign: TextAlign.center,
              style: AppTextStyles.mushaf(
                  fontSize: 27, height: 2.1, color: theme.ink),
            ),
            const SizedBox(height: 20),
            Container(
                height: 1,
                width: 72,
                color: theme.accent.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(
              'سورة ${kSurahs[surah - 1].name}، الآية ${arDigits(ayah)}',
              style: AppTextStyles.body(color: theme.accent)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Text(
              AppIdentity.name,
              style: AppTextStyles.caption(
                  color: theme.ink.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}

/// معاينة بطاقة آية واختيار لونها ثم مشاركتها صورة.
class VerseCardPage extends StatefulWidget {
  const VerseCardPage({super.key, required this.surah, required this.ayah});

  final int surah;
  final int ayah;

  @override
  State<VerseCardPage> createState() => _VerseCardPageState();
}

class _VerseCardPageState extends State<VerseCardPage> {
  final _boundary = GlobalKey();
  int _theme = 0;
  bool _busy = false;
  late final Future<String?> _verse = _load();

  bool get _valid =>
      widget.surah >= 1 &&
      widget.surah <= 114 &&
      widget.ayah >= 1 &&
      widget.ayah <= kSurahs[widget.surah - 1].ayahCount;

  Future<String?> _load() async {
    if (!_valid) return null;
    try {
      final s = await QuranRepository.instance.surah(widget.surah);
      return withAyahNumber(s[widget.ayah - 1], widget.ayah);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'VerseCardPage.load');
      return null;
    }
  }

  Future<void> _share(BuildContext btnContext) async {
    if (_busy) return;
    setState(() => _busy = true);
    Haptic.medium();
    try {
      // اللقطة تُؤخذ بعد اكتمال الرسم (الخط والتدرّج).
      await WidgetsBinding.instance.endOfFrame;
      final box = _boundary.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (box == null) return;
      final img = await box.toImage(pixelRatio: 3);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      if (data == null || !mounted) return;
      await ShareService.shareImage(
        // ignore: use_build_context_synchronously
        btnContext,
        bytes: data.buffer.asUint8List(),
        fileName: 'ayah-${widget.surah}-${widget.ayah}.png',
        text:
            'سورة ${kSurahs[widget.surah - 1].name}: ${widget.ayah} — ${AppIdentity.name}',
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'VerseCardPage.share');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const SectionBackBar(
              title: 'بطاقة آية', fallbackRoute: AppRoutes.mushaf),
          Expanded(
            child: FutureBuilder<String?>(
              future: _verse,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final verse = snap.data;
                if (verse == null) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.image_not_supported_outlined,
                            size: 48, color: c.sub),
                        const SizedBox(height: AppSpacing.md),
                        Text('تعذّر تحميل الآية',
                            style: AppTextStyles.subheader(color: c.ink)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                            'اختر آية من المصحف أو من نتائج البحث ثم اختر «بطاقة صورة» لتصميمها ومشاركتها.',
                            style: AppTextStyles.caption(color: c.sub),
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          style: c.filled,
                          icon: const Icon(Icons.auto_stories_outlined),
                          label: const Text('افتح المصحف'),
                          onPressed: () {
                            Haptic.light();
                            context.go(AppRoutes.mushaf);
                          },
                        ),
                      ]),
                    ),
                  );
                }
                return ListView(
                  padding: AppSpacing.paddingMd,
                  children: [
                    Center(
                      child: RepaintBoundary(
                        key: _boundary,
                        child: VerseCard(
                          verse: verse,
                          surah: widget.surah,
                          ayah: widget.ayah,
                          theme: kVerseCardThemes[_theme],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < kVerseCardThemes.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs),
                              child: ChoiceChip(
                                label: Text(kVerseCardThemes[i].label),
                                selected: _theme == i,
                                onSelected: (_) {
                                  Haptic.select();
                                  setState(() => _theme = i);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Builder(
                      builder: (btnContext) => FilledButton.icon(
                        style: c.filled,
                        icon: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.share_outlined),
                        label: const Text('مشاركة كصورة'),
                        onPressed: _busy ? null : () => _share(btnContext),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'النص بخط مجمع الملك فهد دون أي تغيير في الحروف.',
                      style: AppTextStyles.caption(color: c.sub),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
