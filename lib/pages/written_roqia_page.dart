import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/data/quran_data.dart';

/// Written Roqia page with Quran-style design
class WrittenRoqiaPage extends StatefulWidget {
  const WrittenRoqiaPage({super.key});

  @override
  State<WrittenRoqiaPage> createState() => _WrittenRoqiaPageState();
}

class _WrittenRoqiaPageState extends State<WrittenRoqiaPage> {
  double _fontSize = 20.0;


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
                      onChanged: (value) => setState(() => _fontSize = value),
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
                // 1. Al-Fatiha (full)
                _buildSurahCard(
                  'سورة الفاتحة',
                  7,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿١﴾',
                    'الرَّحْمَٰنِ الرَّحِيمِ ﴿٢﴾',
                    'مَٰلِكِ يَوْمِ الدِّينِ ﴿٣﴾',
                    'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٤﴾',
                    'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿٥﴾',
                    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ﴿٦﴾',
                  ],
                ),
                const SizedBox(height: 12),
                // 2. Al-Baqarah (1-5) - أول خمس آيات
                _buildSurahCard(
                  'سورة البقرة',
                  null,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'الم ﴿١﴾',
                    'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ ﴿٢﴾',
                    'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ ﴿٣﴾',
                    'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ ﴿٤﴾',
                    'أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ ﴿٥﴾',
                  ],
                  subtitle: 'الآيات (١-٥)',
                ),
                const SizedBox(height: 12),
                // 3. Ayat Al-Kursi (255)
                _buildSurahCard(
                  'سورة البقرة',
                  null,
                  null,
                  [
                    'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ ﴿٢٥٥﴾',
                  ],
                  subtitle: 'آية الكرسي (٢٥٥)',
                ),
                const SizedBox(height: 12),
                // 4. Al-Baqarah (285-286) - خواتيم البقرة
                _buildSurahCard(
                  'سورة البقرة',
                  null,
                  null,
                  [
                    'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ ﴿٢٨٥﴾',
                    'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ ﴿٢٨٦﴾',
                  ],
                  subtitle: 'خواتيم البقرة (٢٨٥-٢٨٦)',
                ),
                const SizedBox(height: 12),
                // 4. Al-Anfal (full 75 verses - first 5 + button)
                _buildSurahCard(
                  'سورة الأنفال',
                  75,
                  basmala,
                  anfalVerses,
                ),
                const SizedBox(height: 12),
                // 5. Ad-Dukhan (full 59 verses - first 5 + button)
                _buildSurahCard(
                  'سورة الدخان',
                  59,
                  basmala,
                  dukhanVerses,
                ),
                const SizedBox(height: 12),
                // 6. As-Saffat (full 182 verses - first 5 + button)
                _buildSurahCard(
                  'سورة الصافات',
                  182,
                  basmala,
                  saffatVerses,
                ),
                const SizedBox(height: 12),
                // 7. Al-Haqqah (full 52 verses - first 5 + button)
                _buildSurahCard(
                  'سورة الحاقة',
                  52,
                  basmala,
                  haqqaVerses,
                ),
                const SizedBox(height: 12),
                // 8. Zalzalah (full)
                _buildSurahCard(
                  'سورة الزلزلة',
                  8,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'إِذَا زُلْزِلَتِ الْأَرْضُ زِلْزَالَهَا ﴿١﴾',
                    'وَأَخْرَجَتِ الْأَرْضُ أَثْقَالَهَا ﴿٢﴾',
                    'وَقَالَ الْإِنْسَانُ مَا لَهَا ﴿٣﴾',
                    'يَوْمَئِذٍ تُحَدِّثُ أَخْبَارَهَا ﴿٤﴾',
                    'بِأَنَّ رَبَّكَ أَوْحَى لَهَا ﴿٥﴾',
                    'يَوْمَئِذٍ يَصْدُرُ النَّاسُ أَشْتَاتًا لِيُرَوْا أَعْمَالَهُمْ ﴿٦﴾',
                    'فَمَنْ يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ ﴿٧﴾',
                    'وَمَنْ يَعْمَلْ مِثْقَالَ ذَرَّةٍ شَرًّا يَرَهُ ﴿٨﴾',
                  ],
                  warning: '⚠️ الحامل لا تقرأ هذه السورة',
                ),
                const SizedBox(height: 12),
                // 9. Al-Kafirun (full)
                _buildSurahCard(
                  'سورة الكافرون',
                  6,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'قُلْ يَا أَيُّهَا الْكَافِرُونَ ﴿١﴾',
                    'لَا أَعْبُدُ مَا تَعْبُدُونَ ﴿٢﴾',
                    'وَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ ﴿٣﴾',
                    'وَلَا أَنَا عَابِدٌ مَا عَبَدْتُمْ ﴿٤﴾',
                    'وَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ ﴿٥﴾',
                    'لَكُمْ دِينُكُمْ وَلِيَ دِينِ ﴿٦﴾',
                  ],
                ),
                const SizedBox(height: 12),
                // 10. Al-Ikhlas (full)
                _buildSurahCard(
                  'سورة الإخلاص',
                  4,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'قُلْ هُوَ اللَّهُ أَحَدٌ ﴿١﴾',
                    'اللَّهُ الصَّمَدُ ﴿٢﴾',
                    'لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾',
                    'وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ ﴿٤﴾',
                  ],
                ),
                const SizedBox(height: 12),
                // 11. Al-Falaq (full)
                _buildSurahCard(
                  'سورة الفلق',
                  5,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ﴿١﴾',
                    'مِنْ شَرِّ مَا خَلَقَ ﴿٢﴾',
                    'وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾',
                    'وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ﴿٤﴾',
                    'وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾',
                  ],
                ),
                const SizedBox(height: 12),
                // 12. An-Nas (full)
                _buildSurahCard(
                  'سورة الناس',
                  6,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ﴿١﴾',
                    'مَلِكِ النَّاسِ ﴿٢﴾',
                    'إِلَهِ النَّاسِ ﴿٣﴾',
                    'مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ﴿٤﴾',
                    'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ﴿٥﴾',
                    'مِنَ الْجِنَّةِ وَالنَّاسِ ﴿٦﴾',
                  ],
                ),
                const SizedBox(height: 12),
                // 13. Al-Qari'ah (full)
                _buildSurahCard(
                  'سورة القارعة',
                  11,
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  [
                    'الْقَارِعَةُ ﴿١﴾',
                    'مَا الْقَارِعَةُ ﴿٢﴾',
                    'وَمَا أَدْرَاكَ مَا الْقَارِعَةُ ﴿٣﴾',
                    'يَوْمَ يَكُونُ النَّاسُ كَالْفَرَاشِ الْمَبْثُوثِ ﴿٤﴾',
                    'وَتَكُونُ الْجِبَالُ كَالْعِهْنِ الْمَنْفُوشِ ﴿٥﴾',
                    'فَأَمَّا مَنْ ثَقُلَتْ مَوَازِينُهُ ﴿٦﴾',
                    'فَهُوَ فِي عِيشَةٍ رَاضِيَةٍ ﴿٧﴾',
                    'وَأَمَّا مَنْ خَفَّتْ مَوَازِينُهُ ﴿٨﴾',
                    'فَأُمُّهُ هَاوِيَةٌ ﴿٩﴾',
                    'وَمَا أَدْرَاكَ مَا هِيَهْ ﴿١٠﴾',
                    'نَارٌ حَامِيَةٌ ﴿١١﴾',
                  ],
                ),
                const SizedBox(height: 12),
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
              basmala,
              style: TextStyle(
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
                    verse,
                    style: TextStyle(
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
