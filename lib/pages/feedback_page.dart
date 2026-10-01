import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roqia_altatil/config/app_links.dart';
import 'package:roqia_altatil/services/error_reporter.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = '🌟 اقتراح';
  bool _isSending = false;

  final List<String> _messageTypes = [
    '🌟 اقتراح',
    '🐞 مشكلة تقنية',
    '❤️ شكر وتقدير',
    '📝 ملاحظة عامة',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSending = true);

    try {
      final now = DateTime.now();
      final dateTime = '${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      
      final name = _nameController.text.trim().isEmpty ? 'مستخدم مجهول' : _nameController.text.trim();
      final message = _messageController.text.trim();
      
      final subject = 'رسالة من تطبيق رقية التعطيل - $_selectedType';
      final plainBody = '''
نوع الرسالة: $_selectedType
الاسم: $name
التاريخ والوقت: $dateTime

الرسالة:
$message
''';

      final emailUri = Uri(
        scheme: 'mailto',
        path: AppLinks.feedbackEmail,
        query: 'subject=${Uri.encodeComponent(subject)}'
            '&body=${Uri.encodeComponent(plainBody)}',
      );

      // إصلاح 2026-09-28: كان الكود يسأل canLaunchUrl أولاً — على أندرويد 11+
      // يرجع false دائماً بدون <queries> لـ mailto، وعلى أي جهاز بدون تطبيق بريد
      // تضيع رسالة المستخدم. الآن نحاول الفتح مباشرة، وإن فشل ننسخ الرسالة.
      var opened = false;
      try {
        opened = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } catch (e, st) {
        ErrorReporter.report(e, st, context: 'FeedbackPage.launchUrl');
      }

      if (!mounted) return;
      if (opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('شكراً! تم فتح تطبيق البريد لإرسال رسالتك ✅'),
            backgroundColor: AppColors.primaryTeal,
            duration: const Duration(seconds: 3),
          ),
        );
        _nameController.clear();
        _messageController.clear();
        setState(() => _selectedType = '🌟 اقتراح');
      } else {
        // لا يوجد تطبيق بريد: لا نضيّع ما كتبه المستخدم.
        await Clipboard.setData(ClipboardData(
          text: 'إلى: ${AppLinks.feedbackEmail}\nالموضوع: $subject\n\n$plainBody',
        ));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'لم نجد تطبيق بريد على جهازك — نسخنا رسالتك، '
              'الصقها في أي بريد وأرسلها إلى ${AppLinks.feedbackEmail}',
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'FeedbackPage._sendFeedback');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ، حاول مجدداً'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
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
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'اقتراحات وملاحظات',
                    style: AppTextStyles.header(
                      color: isDark ? AppColors.textOnDark : AppColors.primaryTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'رأيك يهمنا — شاركنا اقتراحاتك لتحسين التطبيق',
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSecondary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body(
                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اسمك (اختياري)',
                        hintStyle: AppTextStyles.body(
                          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSecondary : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message Type Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSecondary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                      ),
                      style: AppTextStyles.body(
                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.category_outlined,
                          color: isDark ? AppColors.accentGold : AppColors.primaryTeal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSecondary : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      dropdownColor: isDark ? AppColors.darkSecondary : Colors.white,
                      items: _messageTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            type,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.body(
                              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSecondary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _messageController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 8,
                      style: AppTextStyles.body(
                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك هنا...',
                        hintStyle: AppTextStyles.body(
                          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.darkSecondary : Colors.white,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء كتابة رسالتك';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkTeal : AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                            .withValues(alpha: 0.4),
                        disabledBackgroundColor: (isDark ? AppColors.darkTeal : AppColors.primaryTeal)
                            .withValues(alpha: 0.5),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'إرسال',
                                  style: AppTextStyles.subheader(color: Colors.white)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
