import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/mushaf_pages_repository.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/mushaf_page_view.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// آخر صفحة قُرئت (١..٦٠٤).
const kLastPageKey = 'mushaf_last_page';

/// قارئ مصحف المدينة بالصفحات: ٦٠٤ صفحة، السحب لليسار للصفحة التالية.
class MushafPageReaderPage extends StatefulWidget {
  const MushafPageReaderPage({super.key, required this.page});

  final int page;

  @override
  State<MushafPageReaderPage> createState() => _MushafPageReaderPageState();
}

class _MushafPageReaderPageState extends State<MushafPageReaderPage> {
  late final PageController _controller;
  late int _current;
  late final Future<MushafLayout> _layout;

  @override
  void initState() {
    super.initState();
    _current = widget.page.clamp(1, MushafLayout.pageCount);
    _controller = PageController(initialPage: _current - 1);
    _layout = MushafPagesRepository.instance.layout();
    _save(_current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save(int p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(kLastPageKey, p);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'MushafPageReader.save');
    }
  }

  void _onChanged(MushafLayout layout, int index) {
    final p = index + 1;
    setState(() => _current = p);
    _save(p);
    // حمّل خط الصفحتين المجاورتين مسبقاً ليكون السحب سلساً.
    for (final n in [p - 1, p + 1]) {
      if (n >= 1 && n <= MushafLayout.pageCount) {
        MushafPagesRepository.instance
            .ensureFonts(layout.page(n).fonts)
            .then<void>((_) {}, onError: (Object _) {});
      }
    }
  }

  Future<void> _jumpDialog() async {
    final c = TextEditingController();
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('الانتقال إلى صفحة'),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '١ – ٦٠٤'),
            onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, int.tryParse(c.text)),
              child: const Text('انتقال'),
            ),
          ],
        ),
      ),
    );
    c.dispose();
    if (n != null && n >= 1 && n <= MushafLayout.pageCount && _controller.hasClients) {
      _controller.jumpToPage(n - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7);
    final ink = isDark ? AppColors.textOnDark : const Color(0xFF1B1B1B);
    final gold = isDark ? AppColors.accentGold : AppColors.accentGoldDark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;

    return Scaffold(
      body: FutureBuilder<MushafLayout>(
        future: _layout,
        builder: (context, snap) {
          final layout = snap.data;
          final page = layout?.page(_current);
          final surah = page == null ? null : kSurahs[page.surah - 1];
          return Column(
            children: [
              SectionBackBar(
                title: surah == null ? 'المصحف الشريف' : 'سورة ${surah.name}',
                fallbackRoute: AppRoutes.mushaf,
              ),
              Material(
                color: isDark ? AppColors.darkSecondary : Colors.white.withValues(alpha: 0.7),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Text(
                      page == null ? '' : 'الجزء ${arDigits(page.juz)}',
                      style: AppTextStyles.caption(color: gold),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'الانتقال إلى صفحة',
                      icon: Icon(Icons.pin_outlined, color: teal),
                      onPressed: layout == null ? null : _jumpDialog,
                    ),
                    IconButton(
                      tooltip: 'نص السورة متصلاً (خط قابل للتكبير)',
                      icon: Icon(Icons.text_fields_rounded, color: teal),
                      onPressed: page == null
                          ? null
                          : () {
                              Haptic.light();
                              context.push(AppRoutes.mushafSurah(page.surah));
                            },
                    ),
                    IconButton(
                      tooltip: 'الفهرس',
                      icon: Icon(Icons.list_rounded, color: teal),
                      onPressed: () => context.go(AppRoutes.mushaf),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: bg,
                  child: snap.hasError
                      ? Center(
                          child: Text('تعذّر تحميل المصحف، أعد المحاولة',
                              style: AppTextStyles.body(color: ink)),
                        )
                      : layout == null
                          ? const Center(child: CircularProgressIndicator())
                          : Directionality(
                              textDirection: TextDirection.rtl,
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: MushafLayout.pageCount,
                                onPageChanged: (i) => _onChanged(layout, i),
                                itemBuilder: (context, i) => MushafPageView(
                                  key: ValueKey(i),
                                  page: layout.page(i + 1),
                                  color: ink,
                                  accent: gold,
                                ),
                              ),
                            ),
                ),
              ),
              Container(
                color: bg,
                padding: EdgeInsets.fromLTRB(
                    16, 2, 16, 6 + MediaQuery.of(context).padding.bottom * 0),
                alignment: Alignment.center,
                child: Text(arDigits(_current),
                    style: AppTextStyles.caption(color: gold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
