import 'package:flutter/widgets.dart';

/// زر الرجوع في أندرويد خارج الرئيسية يعود إلى الرئيسية بدل إغلاق التطبيق.
///
/// يحتاج إلى أمرين معاً:
/// 1. [PopScope] يلتقط الرجوع حين لا يبقى شيء ليُفتح للخلف (التنقّل بين التبويبات
///    بـ `context.go` يستبدل المكدّس).
/// 2. اعتراض إشعارات التنقّل: الـNavigator الداخلي للتبويبات يعلن «لا أستطيع
///    الرجوع» فيُطفئ إدارة الرجوع من Flutter (`setFrameworkHandlesBack(false)`)
///    فيغلق النظام التطبيق دون أن يصل الحدث إلى [PopScope] (أندرويد ١٣+ مع
///    `enableOnBackInvokedCallback`). نعيد الإعلان بأن الإطار يتولّى الرجوع.
class BackToHomeScope extends StatelessWidget {
  const BackToHomeScope({
    super.key,
    required this.atHome,
    required this.onBackToHome,
    required this.child,
  });

  /// في الرئيسية يُترك الرجوع للنظام (يغلق التطبيق).
  final bool atHome;
  final VoidCallback onBackToHome;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: atHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBackToHome();
      },
      child: NotificationListener<NavigationNotification>(
        onNotification: (n) {
          if (!atHome && !n.canHandlePop) {
            const NavigationNotification(canHandlePop: true).dispatch(context);
            return true;
          }
          return false;
        },
        child: child,
      ),
    );
  }
}
