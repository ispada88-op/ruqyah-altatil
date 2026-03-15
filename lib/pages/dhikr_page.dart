import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roqia_altatil/theme.dart';

class DhikrPage extends StatefulWidget {
  const DhikrPage({super.key});

  @override
  State<DhikrPage> createState() => _DhikrPageState();
}

class _DhikrPageState extends State<DhikrPage> {
  int _count = 0;
  int _target = 33;
  String _activeDhikr = 'سُبْحَانَ اللهِ';
  bool _isLoading = true;
  
  // Counters for La ilaha illa Allah and Salawat
  int _laIlahaCount = 0;
  int _salawatCount = 0;
  final int _laIlahaTarget = 100;
  final int _salawatTarget = 100;

  final List<DhikrModel> _adhkar = [
    DhikrModel(text: 'سُبْحَانَ اللهِ', icon: Icons.circle_outlined),
    DhikrModel(text: 'الحَمْدُ للهِ', icon: Icons.favorite_border),
    DhikrModel(text: 'اللهُ أَكْبَرُ', icon: Icons.star_border),
    DhikrModel(text: 'لَا إِلَهَ إِلَّا اللهُ', icon: Icons.brightness_1_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _count = prefs.getInt('dhikr_count') ?? 0;
        _target = prefs.getInt('dhikr_target') ?? 33;
        _activeDhikr = prefs.getString('active_dhikr') ?? 'سُبْحَانَ اللهِ';
        _laIlahaCount = prefs.getInt('la_ilaha_count') ?? 0;
        _salawatCount = prefs.getInt('salawat_count') ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading dhikr data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dhikr_count', _count);
      await prefs.setInt('dhikr_target', _target);
      await prefs.setString('active_dhikr', _activeDhikr);
      await prefs.setInt('la_ilaha_count', _laIlahaCount);
      await prefs.setInt('salawat_count', _salawatCount);
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving dhikr data: $e');
    }
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_count < _target) {
        _count++;
        _saveData();
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _count = 0;
      _saveData();
    });
  }

  void _setActiveDhikr(String dhikr) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeDhikr = dhikr;
      _count = 0;
      _saveData();
    });
  }

  void _setTarget(int target) {
    setState(() {
      _target = target;
      if (_count > _target) {
        _count = _target;
      }
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _count / _target;
    
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'reset',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _resetCounter();
            },
            tooltip: 'إعادة تعيين',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: 'target',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('اختر الهدف'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        _setTarget(33);
                        Navigator.pop(context);
                      },
                      child: const Text('33 مرة'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        _setTarget(100);
                        Navigator.pop(context);
                      },
                      child: const Text('100 مرة'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'اختر الهدف',
            child: const Icon(Icons.flag),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkPrimary, AppColors.darkSurface]
                : [AppColors.backgroundCreamLight, AppColors.backgroundCream],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _activeDhikr,
                  style: AppTextStyles.header(
                    color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: _adhkar.map((dhikr) {
                    final isActive = _activeDhikr == dhikr.text;
                    return InkWell(
                      onTap: () => _setActiveDhikr(dhikr.text),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(
                                  colors: isDark
                                      ? [AppColors.darkTeal, AppColors.accentGold]
                                      : [AppColors.primaryTeal, AppColors.accentGold],
                                )
                              : null,
                          color: isActive ? null : (isDark ? AppColors.darkSecondary : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              dhikr.icon,
                              size: 18,
                              color: isActive
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTeal : AppColors.primaryTeal),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dhikr.text,
                              style: AppTextStyles.caption(
                                color: isActive
                                    ? Colors.white
                                    : (isDark ? AppColors.textOnDark : AppColors.primaryTeal),
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          isDark ? AppColors.accentGold : AppColors.primaryTeal,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$_count',
                          style: TextStyle(
                            color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 72,
                          ),
                        ),
                        Text(
                          'من $_target',
                          style: AppTextStyles.subheader(
                            color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: _incrementCounter,
                  child: Container(
                    width: 180,
                    height: 180,
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
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'اضغط للتسبيح',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_count == _target) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSecondary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'بارك الله فيك!',
                          style: AppTextStyles.subheader(
                            color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSecondary : const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'أدعية الرقية',
                        style: AppTextStyles.subheader(
                          color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDuaCard(
                        '(3 مرات)',
                        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDuaCard(
                        '',
                        'أَذْهِبِ البَاسَ رَبَّ النَّاسِ، وَاشْفِ أَنْتَ الشَّافِي، لاَ شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لاَ يُغَادِرُ سَقَمًا.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDuaCard(
                        '',
                        'بِاسْمِ اللهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللهُ يَشْفِيكَ بِاسْمِ اللهِ أَرْقِيكَ.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDuaCard(
                        '',
                        'بِاسْمِ اللهِ (ثلاثاً)، ثم تقول: أَعُوذُ بِاللهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (سبعاً).',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDuaCard(
                        '(3 مرات)',
                        'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDuaCard(
                        '',
                        'اللَّهُمَّ رَبَّ السَّمَوَاتِ وَرَبَّ الْأَرْضِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ.',
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // La ilaha illa Allah Counter
                _buildSpecialCounter(
                  title: 'لَا إِلَهَ إِلَّا اللَّهُ',
                  count: _laIlahaCount,
                  target: _laIlahaTarget,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (_laIlahaCount < _laIlahaTarget) {
                        _laIlahaCount++;
                      } else {
                        HapticFeedback.heavyImpact();
                      }
                      _saveData();
                    });
                  },
                  onReset: () {
                    setState(() {
                      _laIlahaCount = 0;
                      _saveData();
                    });
                  },
                  isDark: isDark,
                  backgroundColor: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFE8F5E9),
                ),
                const SizedBox(height: 16),
                // Salawat Counter
                _buildSpecialCounter(
                  title: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
                  count: _salawatCount,
                  target: _salawatTarget,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (_salawatCount < _salawatTarget) {
                        _salawatCount++;
                      } else {
                        HapticFeedback.heavyImpact();
                      }
                      _saveData();
                    });
                  },
                  onReset: () {
                    setState(() {
                      _salawatCount = 0;
                      _saveData();
                    });
                  },
                  isDark: isDark,
                  backgroundColor: isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF8DC),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialCounter({
    required String title,
    required int count,
    required int target,
    required VoidCallback onTap,
    required VoidCallback onReset,
    required bool isDark,
    required Color backgroundColor,
  }) {
    final progress = count / target;
    final isComplete = count >= target;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            title,
            style: AppTextStyles.subheader(
              color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
            ).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Progress Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    isDark ? AppColors.accentGold : AppColors.primaryTeal,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 56,
                    ),
                  ),
                  Text(
                    'من $target',
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tap Button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 140,
              height: 140,
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
                        .withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'اضغط',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accentGold : AppColors.primaryTeal)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'أحسنت ✅',
                    style: AppTextStyles.subheader(
                      color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Reset Button
          TextButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onReset();
            },
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
            ),
            label: Text(
              'إعادة',
              style: AppTextStyles.body(
                color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(String repetition, String text, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.accentGold : const Color(0xFFD4AF37))
              .withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: (isDark ? AppColors.accentGold : const Color(0xFFD4AF37))
              .withValues(alpha: 0.1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(
            Icons.bookmark_border,
            color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37),
          ),
          title: Text(
            text.length > 40 ? '${text.substring(0, 40)}...' : text,
            style: AppTextStyles.body(
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          children: [
            Divider(
              color: isDark ? AppColors.accentGold : const Color(0xFFD4AF37),
              thickness: 1,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.subheader(
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ).copyWith(height: 1.8),
            ),
            if (repetition.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.accentGold : const Color(0xFFD4AF37))
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  repetition,
                  style: AppTextStyles.caption(
                    color: isDark ? AppColors.accentGold : AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DhikrModel {
  final String text;
  final IconData icon;

  DhikrModel({
    required this.text,
    required this.icon,
  });
}
