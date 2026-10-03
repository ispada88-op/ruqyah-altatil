import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/bookmarks_service.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/mushaf_pages_repository.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/app_card.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

/// العلامات المرجعية: صفحات المصحف التي حفظتها.
class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _svc = BookmarksService.instance;
  late final Future<MushafLayout> _layout = MushafPagesRepository.instance.layout();

  @override
  void initState() {
    super.initState();
    _svc.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final c = PageColors(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const SectionBackBar(title: 'العلامات المرجعية', fallbackRoute: AppRoutes.mushaf),
          Expanded(
            child: ListenableBuilder(
              listenable: _svc,
              builder: (context, _) {
                final items = _svc.items;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.bookmark_border_rounded, size: 48, color: c.sub),
                        const SizedBox(height: AppSpacing.md),
                        Text('لا علامات بعد', style: AppTextStyles.subheader(color: c.ink)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('اضغط أيقونة العلامة أعلى أي صفحة في المصحف لحفظ موضعك.',
                            style: AppTextStyles.caption(color: c.sub),
                            textAlign: TextAlign.center),
                      ]),
                    ),
                  );
                }
                return FutureBuilder<MushafLayout>(
                  future: _layout,
                  builder: (context, snap) {
                    final layout = snap.data;
                    return ListView.separated(
                      padding: AppSpacing.paddingMd,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final b = items[i];
                        final page = layout?.page(b.page);
                        final sub = page == null
                            ? ''
                            : 'سورة ${kSurahs[page.surah - 1].name} · الجزء ${arDigits(page.juz)}';
                        return AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          onTap: () {
                            Haptic.light();
                            context.push(AppRoutes.mushafPage(b.page));
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 64),
                            child: Row(children: [
                              Icon(Icons.bookmark_rounded, color: c.gold),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('صفحة ${arDigits(b.page)}',
                                        style: AppTextStyles.body(color: c.ink)),
                                    if (sub.isNotEmpty)
                                      Text(sub, style: AppTextStyles.caption(color: c.sub)),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'حذف العلامة',
                                icon: Icon(Icons.delete_outline_rounded, color: c.sub),
                                onPressed: () {
                                  Haptic.select();
                                  _svc.remove(b.page);
                                },
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
