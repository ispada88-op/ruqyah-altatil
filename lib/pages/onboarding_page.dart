import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roqia_altatil/theme.dart';

/// Onboarding page shown on first app launch
class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentPage = 0;
  
  static const _onboardingColor = Color(0xFF006B6B);

  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      icon: '🎙️',
      title: 'الرقية الصوتية',
      description: 'استمع إلى الرقية الشرعية بأصوات أفاضل المشايخ\nمع إمكانية التشغيل في الخلفية',
      gradient: [_onboardingColor, Color(0xFF008B8B)],
    ),
    _OnboardingItem(
      icon: '📖',
      title: 'الرقية المكتوبة',
      description: 'اقرأ آيات الرقية بخط عثماني واضح\nمطابق لمصحف المدينة المنورة',
      gradient: [Color(0xFFD4AF37), Color(0xFFE5C158)],
    ),
    _OnboardingItem(
      icon: '🤲',
      title: 'الأذكار والتسبيح',
      description: 'عداد تسبيح ذكي مع أدعية الرقية المأثورة\nحافظ على أذكارك اليومية',
      gradient: [Color(0xFF2E7D32), Color(0xFF43A047)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundCreamLight,
              AppColors.backgroundCream,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'تخطي',
                    style: AppTextStyles.body(color: AppColors.textTertiary),
                  ),
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _animController.reset();
                    _animController.forward();
                    HapticFeedback.selectionClick();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _currentPage == index ? 1.0 : 0.5,
                          child: Transform.scale(
                            scale: _currentPage == index ? 1.0 : 0.95,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon circle
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: page.gradient,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: page.gradient[0].withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                page.icon,
                                style: const TextStyle(fontSize: 72),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Title
                          Text(
                            page.title,
                            style: AppTextStyles.header(
                              color: AppColors.primaryTeal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              page.description,
                              style: AppTextStyles.body(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Page indicators
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryTeal
                            : AppColors.textTertiary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Action button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _currentPage == _pages.length - 1
                        ? _completeOnboarding
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'ابدأ الآن ✨' : 'التالي',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String icon;
  final String title;
  final String description;
  final List<Color> gradient;
  
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
