import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roqia_altatil/data/quran_index.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/pages/mushaf_page_reader.dart' show kLastPageKey;
import 'package:roqia_altatil/services/mushaf_pages_repository.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/quran_repository.dart';
import 'package:roqia_altatil/services/share_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/quran_text.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';

const _kLastSurahKey = 'mushaf_last_surah';
const _kLastOffsetKey = 'mushaf_last_offset';
const _kFontSizeKey = 'written_font_size'; // موحّد مع صفحات القراءة

const String kQuranCredit =
    'النص والخط ورسم الصفحات: مجمع الملك فهد لطباعة المصحف الشريف بالمدينة المنورة (رواية حفص عن عاصم)\nأسماء السور والاقتباسات الإملائية: tanzil.net';

/// إزالة التشكيل للبحث في أسماء السور.
String _plain(String s) => s
    .replaceAll(RegExp('[ً-ٰٟ]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .trim();

// ═══════════════════════════════════════════════════════════════════════════
// فهرس المصحف
// ═══════════════════════════════════════════════════════════════════════════

class MushafIndexPage extends StatefulWidget {
  const MushafIndexPage({super.key});

  @override
  State<MushafIndexPage> createState() => _MushafIndexPageState();
}

class _MushafIndexPageState extends State<MushafIndexPage> {
  final _search = TextEditingController();
  String _query = '';
  bool _byJuz = false;
  int? _lastPage;

  @override
  void initState() {
    super.initState();
    QuranRepository.instance.preload();
    MushafPagesRepository.instance.layout().then<void>((_) {}, onError: (Object _) {});
    _loadLast();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadLast() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final p = prefs.getInt(kLastPageKey);
      if (mounted && p != null && p >= 1 && p <= MushafLayout.pageCount) {
        setState(() => _lastPage = p);
      }
    } catch (_) {/* optional */}
  }

  /// يفتح المصحف بالصفحات عند أول صفحة السورة أو الجزء أو الصفحة المحفوظة.
  Future<void> _openPage(int Function(MushafLayout) pick) async {
    Haptic.light();
    try {
      final layout = await MushafPagesRepository.instance.layout();
      if (!mounted) return;
      context.push(AppRoutes.mushafPage(pick(layout)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تحميل المصحف، أعد المحاولة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    final q = _plain(_query);
    final surahs = q.isEmpty
        ? kSurahs
        : kSurahs
            .where((s) => _plain(s.name).contains(q) || '${s.number}' == q)
            .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('المصحف الشريف',
                style: AppTextStyles.header(color: teal)),
          ),
          if (_lastPage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: teal),
                onPressed: () => _openPage((_) => _lastPage!),
                icon: const Icon(Icons.auto_stories_outlined),
                label: Text('متابعة القراءة — صفحة ${arDigits(_lastPage!)}'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (icon, label, route) in [
                  (Icons.manage_search_outlined, 'بحث في الآيات', AppRoutes.quranSearch),
                  (Icons.bookmarks_outlined, 'العلامات', AppRoutes.bookmarks),
                  (Icons.flag_outlined, 'الختمة', AppRoutes.khatma),
                ])
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: teal),
                    onPressed: () {
                      Haptic.light();
                      context.push(route);
                    },
                    icon: Icon(icon, size: 20),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم السورة أو رقمها',
                      prefixIcon: const Icon(Icons.search_outlined),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('السور')),
                    ButtonSegment(value: true, label: Text('الأجزاء')),
                  ],
                  selected: {_byJuz},
                  onSelectionChanged: (s) => setState(() => _byJuz = s.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: _byJuz
                ? ListView.builder(
                    itemCount: kJuzStarts.length,
                    itemBuilder: (context, i) {
                      final j = kJuzStarts[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: teal.withValues(alpha: 0.12),
                          child: Text(arDigits(j.juz),
                              style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('الجزء ${arDigits(j.juz)}'),
                        subtitle: Text(
                            'يبدأ من سورة ${kSurahs[j.surah - 1].name} — آية ${arDigits(j.ayah)}'),
                        onTap: () => _openPage((l) => l.pageOfJuz(j.juz)),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: surahs.length + 1,
                    itemBuilder: (context, i) {
                      if (i == surahs.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(kQuranCredit,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption().copyWith(fontSize: 11)),
                        );
                      }
                      final s = surahs[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: teal.withValues(alpha: 0.12),
                          child: Text(arDigits(s.number),
                              style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('سورة ${s.name}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${s.meccan ? 'مكية' : 'مدنية'} • ${ayatLabel(s.ayahCount)}'),
                        onTap: () => _openPage((l) => l.pageOfSurah(s.number)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// قارئ السورة
// ═══════════════════════════════════════════════════════════════════════════

class MushafReaderPage extends StatefulWidget {
  const MushafReaderPage({
    super.key,
    required this.surah,
    this.ayah,
    this.resume = false,
  });

  final int surah;

  /// آية يُقفز إليها بعد التحميل (مثل بداية جزء).
  final int? ayah;

  /// استكمال آخر موضع محفوظ لهذه السورة.
  final bool resume;

  @override
  State<MushafReaderPage> createState() => _MushafReaderPageState();
}

class _MushafReaderPageState extends State<MushafReaderPage> {
  final _scroll = ScrollController();
  final _targetKey = GlobalKey();
  late Future<List<String>> _verses;
  double _fontSize = 22;

  SurahInfo get _info => kSurahs[widget.surah.clamp(1, 114) - 1];

  @override
  void initState() {
    super.initState();
    _verses = QuranRepository.instance.surah(_info.number);
    _loadPrefs();
    _verses.then((_) => _afterLoad(), onError: (_) {});
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final size = prefs.getDouble(_kFontSizeKey);
      if (mounted && size != null) setState(() => _fontSize = size.clamp(16, 36));
    } catch (_) {/* optional */}
  }

  Future<void> _afterLoad() async {
    double? offset;
    if (widget.resume) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getInt(_kLastSurahKey) == _info.number) {
          offset = prefs.getDouble(_kLastOffsetKey);
        }
      } catch (_) {/* optional */}
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (offset != null && _scroll.hasClients) {
        _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
      } else if (widget.ayah != null && _targetKey.currentContext != null) {
        Scrollable.ensureVisible(_targetKey.currentContext!,
            duration: const Duration(milliseconds: 300));
      }
    });
    _saveLast(offset ?? 0);
  }

  Future<void> _saveLast(double offset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastSurahKey, _info.number);
      await prefs.setDouble(_kLastOffsetKey, offset);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'Mushaf.saveLast');
    }
  }

  Future<void> _saveFontSize(double v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kFontSizeKey, v);
    } catch (_) {/* optional */}
  }

  /// ضغطة مطوّلة على آية: نسخ، مشاركة نصاً، أو بطاقة صورة.
  Future<void> _verseActions(int ayah, String body) async {
    Haptic.medium();
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${_info.name} · الآية ${arDigits(ayah)}',
                    style: AppTextStyles.subheader()),
              ),
              ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.content_copy_outlined),
                title: const Text('نسخ الآية'),
                onTap: () => Navigator.pop(ctx, 'copy'),
              ),
              ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.share_outlined),
                title: const Text('مشاركة نصاً'),
                onTap: () => Navigator.pop(ctx, 'share'),
              ),
              ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.image_outlined),
                title: const Text('بطاقة صورة'),
                onTap: () => Navigator.pop(ctx, 'card'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    final text = quranForSharing(withAyahNumber(body, ayah));
    switch (action) {
      case 'copy':
        await ShareService.copyVerse(
            context: context, verseText: text, surahName: _info.name, verseNumber: ayah);
      case 'share':
        await ShareService.shareVerse(context,
            verseText: text, surahName: _info.name, verseNumber: ayah);
      case 'card':
        context.push(AppRoutes.verseCardFor(_info.number, ayah));
    }
  }

  void _goTo(int surah) {
    Haptic.select();
    context.pushReplacement(AppRoutes.mushafSurah(surah));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : const Color(0xFF3E2C1C);
    final gold = isDark ? AppColors.accentGold : AppColors.accentGoldDark;

    return Scaffold(
      body: Column(
      children: [
        SectionBackBar(
            title: 'سورة ${_info.name}', fallbackRoute: AppRoutes.mushaf),
        Container(
          color: isDark ? AppColors.darkSecondary : Colors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.format_size_outlined, color: gold, size: 20),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 16,
                  max: 36,
                  divisions: 20,
                  activeColor: gold,
                  onChanged: (v) {
                    setState(() => _fontSize = v);
                    _saveFontSize(v);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7),
            child: FutureBuilder<List<String>>(
              future: _verses,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text('تعذّر تحميل السورة، أعد المحاولة',
                        style: AppTextStyles.body(color: textColor)),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final verses = snap.data!;
                return NotificationListener<ScrollEndNotification>(
                  onNotification: (n) {
                    _saveLast(n.metrics.pixels);
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SurahHeader(info: _info, gold: gold, textColor: textColor),
                        if (_info.number != 1 && _info.number != 9)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuranText(
                              QuranRepository.instance.basmala,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.mushaf(
                                  fontSize: _fontSize + 2, color: textColor),
                            ),
                          ),
                        for (var i = 0; i < verses.length; i++)
                          Padding(
                            key: widget.ayah == i + 1 ? _targetKey : null,
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onLongPress: () => _verseActions(i + 1, verses[i]),
                              child: QuranText(
                                withAyahNumber(verses[i], i + 1),
                                textAlign: TextAlign.justify,
                                textDirection: TextDirection.rtl,
                                style: AppTextStyles.mushaf(
                                  fontSize: _fontSize,
                                  height: 2.1,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_info.number > 1)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _goTo(_info.number - 1),
                                  icon: const Icon(Icons.arrow_back),
                                  label: Text(kSurahs[_info.number - 2].name,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            if (_info.number > 1 && _info.number < 114)
                              const SizedBox(width: 12),
                            if (_info.number < 114)
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                                  ),
                                  onPressed: () => _goTo(_info.number + 1),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(kSurahs[_info.number].name,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(kQuranCredit,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                              color: isDark
                                  ? AppColors.textOnDarkSecondary
                                  : AppColors.textTertiary,
                            ).copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.info, required this.gold, required this.textColor});

  final SurahInfo info;
  final Color gold;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: gold, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('سورة ${info.name}',
              style: GoogleFonts.amiri(
                  fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          Text(
            '${info.meccan ? 'مكية' : 'مدنية'} • ${ayatLabel(info.ayahCount)}',
            style: TextStyle(color: gold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
