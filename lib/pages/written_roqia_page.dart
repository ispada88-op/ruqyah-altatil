import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/data/written_roqia_data.dart';
import 'package:roqia_altatil/utils/arabic_text.dart';

/// Written Roqia page with Quran-style design
class WrittenRoqiaPage extends StatefulWidget {
  const WrittenRoqiaPage({super.key});

  @override
  State<WrittenRoqiaPage> createState() => _WrittenRoqiaPageState();
}

class _WrittenRoqiaPageState extends State<WrittenRoqiaPage> {
  double _fontSize = 20.0;
  static const _kFontSizeKey = 'written_font_size';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSecondary : Colors.white.withValues(alpha: 0.7),
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
                  color: isDark ? AppColors.accentGold : AppColors.accentGoldDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: isDark ? AppColors.accentGold : AppColors.accentGoldDark,
                      inactiveTrackColor: (isDark ? AppColors.accentGold : AppColors.accentGoldDark).withValues(alpha: 0.3),
                      thumbColor: isDark ? AppColors.accentGold : AppColors.accentGoldDark,
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
                  style: const TextStyle(
                    color: Color(0xFF6F4E37),
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
                // Application Method Card (first)
                _buildApplicationMethodCard(),
                const SizedBox(height: 12),
                _buildTahrijCard(),
                const SizedBox(height: 12),
                // كل السور بالنص العثماني الموثّق (verified_quran.dart)
                // + السور الكبيرة من quran_data.dart
                ...writtenSurahs.expand((s) => [
                      _buildSurahCard(
                        s.name,
                        s.totalAyat,
                        s.basmala,
                        s.verses,
                        subtitle: s.subtitle,
                        warning: s.name.contains('الزلزلة')
                            ? '⚠️ الحامل لا تقرأ هذه السورة'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ]),
                // Duas at the end
                _buildDuasCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationMethodCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF1E4D2B).withValues(alpha: 0.6),
                  const Color(0xFF2C5530).withValues(alpha: 0.4),
                ]
              : [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFF1F8E9),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.accentGold.withValues(alpha: 0.3)
              : const Color(0xFF81C784).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accentGold.withValues(alpha: 0.2)
                      : const Color(0xFF66BB6A).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  color: isDark ? AppColors.accentGold : const Color(0xFF388E3C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🌿 طريقة تطبيق الرقية',
                  style: TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textOnDark : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            '١- يجب أن يكون الشخص طاهراً',
            isDark,
          ),
          _buildStepItem(
            '٢- قراءة السور يومياً معاً بدون انقطاع (يمكن استبدال القراءة بالاستماع للمقاطع الصوتية)',
            isDark,
          ),
          _buildStepItem(
            '٣- يمكن قراءة السور على كمية من الماء والنفث فيه',
            isDark,
          ),
          _buildStepItem(
            '٤- من ثم شرب الماء المقروء عليه والاغتسال به يومياً',
            isDark,
          ),
          _buildStepItem(
            '٥- الاغتسال كامل الجسد أو استخدام بخاخ يوضع به الماء ويُبخّ به الجسد بدءاً من منابت الشعر إلى الأقدام',
            isDark,
          ),
          _buildStepItem(
            '٦- لا مانع من زيادة الماء إذا نقص، واستمر في هذه الخطوات حتى حدوث الشفاء بإذن الله',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, left: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.accentGold : const Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.8,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuasCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final duas = [
      'اللهم إني أعوذ بك من كل معطل، ومن كل مبطل، ومن كل ممانعة، ومن كل معصية، ومن كل ظلم، ومن كل بغي، ومن كل عدو، ومن كل كيد، ومن كل حسد، ومن كل عين حاسدة',
      'اللهم إني أعوذ بك من شر كل ذي شر، ومن شر كل ذي عين حاسدة، وشر كل لسان ناطق، وشر كل ذي بلغة ناطقة، وشر كل ذي مكر مكيد، وشر كل ذي قلب مريد، وشر كل ذي نية حاقدة، وشر كل ذي نفس ساخطة',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  AppColors.accentGold.withValues(alpha: 0.15),
                  AppColors.darkTeal.withValues(alpha: 0.2),
                ]
              : [
                  const Color(0xFFFFF8E1),
                  const Color(0xFFFFF9C4).withValues(alpha: 0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.accentGold.withValues(alpha: 0.4)
              : AppColors.accentGold.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: AppColors.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🤲 أدعية إزالة التعطيل',
                  style: TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textOnDark : AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...duas.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final dua = entry.value;
            return _buildDuaItem(
              number: index,
              text: dua,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDuaItem({
    required int number,
    required String text,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondary.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.accentGold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: _fontSize - 6,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkPrimary : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الدعاء $number',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentGold : AppColors.accentGold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ الدعاء'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                color: isDark ? AppColors.accentGold : AppColors.accentGold,
                tooltip: 'نسخ 📋',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.8,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildTahrijCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'طريقة التحريج على النفس',
              style: TextStyle(
                fontSize: _fontSize + 2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6F4E37),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(color: Color(0xFFD4AF37), thickness: 1, height: 24),
          Text(
            'دخلت على جسدي ونفسي بـ لا إله إلا الله\nأناشد كل من سكن في جسدي من الشياطين من السحر والحسد والعين\nترك جسدي طاعة لله ولرسوله\nلا تؤذوني ولا أوذيكم',
            style: TextStyle(
              fontSize: _fontSize,
              height: 2,
              color: const Color(0xFF6F4E37),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: const Color(0xFF6F4E37), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ملاحظة: السكوت ساعتين بعد التحريج',
                    style: TextStyle(
                      fontSize: _fontSize - 2,
                      color: const Color(0xFF6F4E37),
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(
    String surahName,
    int? totalVerses,
    String? basmala,
    List<String> verses, {
    String? subtitle,
    String? warning,
    bool showMore = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37), width: 1.5),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (totalVerses != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary : const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37)),
                  ),
                  child: Text(
                    '$totalVerses آية',
                    style: TextStyle(
                      fontSize: _fontSize - 4,
                      color: isDark ? AppColors.textOnDark : const Color(0xFF6F4E37),
                    ),
                  ),
                ),
              if (totalVerses != null) const SizedBox(width: 12),
              Text(
                surahName,
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentGold : const Color(0xFF6F4E37),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: _fontSize - 2,
                color: (isDark ? AppColors.textOnDark : const Color(0xFF6F4E37)).withValues(alpha: 0.7),
              ),
            ),
          ],
          Divider(color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37), thickness: 1, height: 24),
          if (basmala != null) ...[
            Text(
              simplifyQuran(basmala),
              style: GoogleFonts.notoNaskhArabic(
                fontSize: _fontSize + 2,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37),
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
          ],
          ...verses.map((verse) => verse.isEmpty
              ? const SizedBox(height: 12)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    simplifyQuran(verse),
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: _fontSize,
                      height: 2,
                      color: isDark ? AppColors.textOnDark : const Color(0xFF6F4E37),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
          if (showMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... والبقية',
                style: TextStyle(
                  fontSize: _fontSize - 2,
                  fontStyle: FontStyle.italic,
                  color: (isDark ? AppColors.textOnDark : const Color(0xFF6F4E37)).withValues(alpha: 0.6),
                ),
              ),
            ),
          if (warning != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        fontSize: _fontSize - 2,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}
