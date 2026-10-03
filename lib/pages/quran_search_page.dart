import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/mushaf_pages_repository.dart';
import 'package:roqia_altatil/services/quran_repository.dart';
import 'package:roqia_altatil/services/quran_search_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/utils/arabic_search.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// البحث في نص القرآن الكريم (يتجاهل التشكيل وأشكال الألف والهمزة والياء والتاء).
class QuranSearchPage extends StatefulWidget {
  const QuranSearchPage({super.key});

  @override
  State<QuranSearchPage> createState() => _QuranSearchPageState();
}

class _QuranSearchPageState extends State<QuranSearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _seq = 0; // يتجاهل نتائج استعلام قديم وصلت متأخرة

  SearchResults? _results;
  List<String> _texts = const []; // نص الآية بخط المصحف، بنفس ترتيب النتائج
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // ابنِ الفهرس مبكراً حتى لا ينتظر أول بحث.
    QuranSearchService.instance.index().then<void>((_) {}, onError: (Object _) {});
    QuranRepository.instance.preload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _run(v));
  }

  Future<void> _run(String q) async {
    final my = ++_seq;
    if (normalizeArabic(q).replaceAll(' ', '').length < 2) {
      setState(() {
        _results = null;
        _texts = const [];
        _loading = false;
        _failed = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final r = await QuranSearchService.instance.search(q);
      final cache = <int, List<String>>{};
      final texts = <String>[];
      for (final v in r.shown) {
        final s = cache[v.surah] ??= await QuranRepository.instance.surah(v.surah);
        texts.add(v.ayah <= s.length ? withAyahNumber(s[v.ayah - 1], v.ayah) : '');
      }
      if (!mounted || my != _seq) return;
      setState(() {
        _results = r;
        _texts = texts;
        _loading = false;
      });
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'QuranSearchPage.run');
      if (!mounted || my != _seq) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _open(SearchVerse v) async {
    Haptic.light();
    try {
      final layout = await MushafPagesRepository.instance.layout();
      if (!mounted) return;
      context.push(AppRoutes.mushafPage(layout.pageOfAyah(v.surah, v.ayah)));
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'QuranSearchPage.open');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    final r = _results;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const SectionBackBar(title: 'البحث في القرآن', fallbackRoute: AppRoutes.mushaf),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _run,
              decoration: InputDecoration(
                hintText: 'اكتب كلمة أو أكثر من الآية',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          _run('');
                        },
                      ),
                filled: true,
                fillColor: c.isDark ? AppColors.darkSecondary : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (r != null && r.total > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  r.total > r.shown.length
                      ? '${arDigits(r.total)} آية — أول ${arDigits(r.shown.length)}، ضيّق البحث بكلمة إضافية'
                      : '${arDigits(r.total)} آية',
                  style: AppTextStyles.caption(color: c.sub),
                ),
              ),
            ),
          Expanded(child: _body(c, r)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'نص البحث: مشروع تنزيل tanzil.net — العرض بنص مجمع الملك فهد',
              style: AppTextStyles.caption(color: c.sub),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(PageColors c, SearchResults? r) {
    if (_failed) {
      return Center(
          child: Text('تعذّر البحث، أعد المحاولة', style: AppTextStyles.body(color: c.ink)));
    }
    if (_loading && r == null) return const Center(child: CircularProgressIndicator());
    if (r == null) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text('يتجاهل البحث التشكيل، ويقبل «الصلاة» و«الصلاه»، و«الله» و«اللّه».',
              style: AppTextStyles.caption(color: c.sub), textAlign: TextAlign.center),
        ),
      );
    }
    if (r.total == 0) {
      return Center(child: Text('لا نتائج', style: AppTextStyles.body(color: c.sub)));
    }
    return ListView.separated(
      padding: AppSpacing.paddingMd,
      itemCount: r.shown.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final v = r.shown[i];
        return AppCard(
          onTap: () => _open(v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    'سورة ${kSurahs[v.surah - 1].name} · الآية ${arDigits(v.ayah)}',
                    style: AppTextStyles.caption(color: c.gold),
                  ),
                ),
                IconButton(
                  tooltip: 'بطاقة للمشاركة',
                  icon: Icon(Icons.image_outlined, color: c.teal),
                  onPressed: () {
                    Haptic.light();
                    context.push(AppRoutes.verseCardFor(v.surah, v.ayah));
                  },
                ),
              ]),
              const SizedBox(height: AppSpacing.xs),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  _texts[i],
                  style: AppTextStyles.mushaf(color: c.ink, fontSize: 22, height: 2.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
