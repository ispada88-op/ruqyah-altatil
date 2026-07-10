import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roqia_altatil/data/general_ruqyah_data.dart';
import 'package:roqia_altatil/services/share_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_text.dart';

/// صفحة «الرقية المستقلة» — رقية مستقلة عن رقية التعطيل.
///
/// كل فقرة لها عدّاد تكرار تفاعلي (٧ أو ٣ مرات): اضغط العدّاد بعد كل قراءة،
/// وعند اكتمال العدد يظهر ✓ (والضغط بعدها يعيد العدّاد من جديد).
class GeneralRuqyahPage extends StatefulWidget {
  const GeneralRuqyahPage({super.key});

  @override
  State<GeneralRuqyahPage> createState() => _GeneralRuqyahPageState();
}

class _GeneralRuqyahPageState extends State<GeneralRuqyahPage> {
  double _fontSize = 20.0;
  // نفس مفتاح صفحة الرقية المكتوبة — حجم الخط موحّد في كل صفحات القراءة.
  static const _kFontSizeKey = 'written_font_size';

  /// عدد القراءات الحالية لكل فقرة (index → count). جلسة فقط، بلا حفظ.
  final Map<int, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() => _fontSize = prefs.getDouble(_kFontSizeKey) ?? 20.0);
      }
    } catch (_) {/* ignore */}
  }

  Future<void> _saveFontSize(double size) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kFontSizeKey, size);
    } catch (_) {/* ignore */}
  }

  void _onCount(int index, int target) {
    final current = _counts[index] ?? 0;
    if (current >= target) {
      // اكتمل سابقاً → إعادة العدّاد
      HapticFeedback.selectionClick();
      setState(() => _counts[index] = 0);
      return;
    }
    final next = current + 1;
    if (next >= target) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() => _counts[index] = next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = generalRuqyahItems;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7),
      body: Column(
        children: [
          // شريط حجم الخط (نفس نمط صفحة الرقية المكتوبة)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondary
                  : Colors.white.withValues(alpha: 0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color:
                      isDark ? AppColors.accentGold : AppColors.accentGoldDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: isDark
                          ? AppColors.accentGold
                          : AppColors.accentGoldDark,
                      inactiveTrackColor: (isDark
                              ? AppColors.accentGold
                              : AppColors.accentGoldDark)
                          .withValues(alpha: 0.3),
                      thumbColor: isDark
                          ? AppColors.accentGold
                          : AppColors.accentGoldDark,
                    ),
                    child: Slider(
                      value: _fontSize,
                      min: 14.0,
                      max: 32.0,
                      divisions: 18,
                      label: _fontSize.round().toString(),
                      onChanged: (value) {
                        setState(() => _fontSize = value);
                        _saveFontSize(value);
                      },
                    ),
                  ),
                ),
                Text(
                  '${_fontSize.round()}',
                  style: TextStyle(
                    color: isDark ? AppColors.textOnDark : const Color(0xFF6F4E37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 12),
                _buildHowToCard(isDark),
                const SizedBox(height: 12),
                ...List.generate(items.length, (i) {
                  final item = items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildItemCard(
                      item: item,
                      order: i + 1,
                      count: _counts[i] ?? 0,
                      onCount: () => _onCount(i, item.repeat),
                      isDark: isDark,
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // شعار القسم: دائرة مكتوب فيها «رقية»
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkTeal, AppColors.accentGold]
                  : [AppColors.primaryTeal, AppColors.accentGold],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                    .withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'رقية',
              style: GoogleFonts.amiri(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'الرقية المستقلة',
          style: AppTextStyles.header(
            color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'رقية مستقلة عن رقية التعطيل — تُقرأ فقراتها بالترتيب وبعدد التكرار المبيَّن',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(
            color: isDark
                ? AppColors.textOnDarkSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHowToCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondary.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.touch_app_outlined,
              color: AppColors.accentGold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'اضغط عدّاد الفقرة بعد كل قراءة حتى يكتمل عددها، '
              'وعند الاكتمال يظهر ✓ (الضغط بعده يعيد العدّاد).',
              style: AppTextStyles.caption(
                color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
              ).copyWith(height: 1.6),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required GeneralRuqyahItem item,
    required int order,
    required int count,
    required VoidCallback onCount,
    required bool isDark,
  }) {
    final gold = isDark ? AppColors.accentGold : const Color(0xFFD4AF37);
    final textColor = isDark ? AppColors.textOnDark : const Color(0xFF6F4E37);
    final done = count >= item.repeat;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // العنوان + شارة التكرار
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold),
                ),
                child: Center(
                  child: Text(
                    '$order',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: _fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: _fontSize - 5,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gold),
                ),
                child: Text(
                  item.repeatLabel,
                  style: TextStyle(
                    fontSize: _fontSize - 6,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: gold, thickness: 1, height: 24),
          // النصوص
          ...item.blocks.expand((block) sync* {
            if (block.heading != null) {
              yield Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  block.heading!,
                  style: TextStyle(
                    fontSize: _fontSize - 2,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            for (final line in block.lines) {
              yield Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  item.isQuran ? simplifyQuran(line) : line,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: _fontSize,
                    height: 2,
                    color: textColor,
                  ),
                  textAlign: item.isQuran ? TextAlign.right : TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              );
            }
          }),
          // ملاحظة سنيّة / مصدر
          if (item.note != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                item.note!,
                style: TextStyle(
                  fontSize: _fontSize - 5,
                  height: 1.6,
                  color: textColor.withValues(alpha: 0.8),
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          if (item.source != null)
            Text(
              '— ${item.source!}',
              style: TextStyle(
                fontSize: _fontSize - 6,
                fontStyle: FontStyle.italic,
                color: gold,
              ),
              textDirection: TextDirection.rtl,
            ),
          const SizedBox(height: 10),
          // العدّاد + نسخ + مشاركة
          Row(
            children: [
              Expanded(
                child: Material(
                  color: done
                      ? AppColors.success.withValues(alpha: isDark ? 0.35 : 0.15)
                      : (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                          .withValues(alpha: isDark ? 0.35 : 0.12),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: onCount,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            done ? Icons.check_circle : Icons.touch_app,
                            size: 20,
                            color: done
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.darkTeal
                                    : AppColors.primaryTeal),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            done ? 'اكتمل ✓' : '$count / ${item.repeat}',
                            style: TextStyle(
                              fontSize: _fontSize - 3,
                              fontWeight: FontWeight.bold,
                              color: done
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.textOnDark
                                      : AppColors.primaryTeal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await Clipboard.setData(
                      ClipboardData(text: item.plainText));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم النسخ ✅'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(Icons.copy_rounded, size: 20, color: gold),
                tooltip: 'نسخ',
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ShareService.shareText(
                    context,
                    text: '${item.plainText}\n\nمن تطبيق رقية التعطيل',
                    subject: item.title,
                  );
                },
                icon: Icon(Icons.share_rounded, size: 20, color: gold),
                tooltip: 'مشاركة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
