import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'error_reporter.dart';
import '../config/app_identity.dart';
import '../config/app_links.dart';

/// خدمة مشاركة ونسخ النصوص القرآنية.
///
/// ملاحظة مهمة (إصلاح 2026-07-10): على iPad تفشل المشاركة بصمت إذا لم يُمرَّر
/// `sharePositionOrigin` (يرمي النظام PlatformException كانت تُبتلع في try/catch
/// فلا تظهر نافذة المشاركة إطلاقاً). لذلك كل الدوال الآن تستقبل BuildContext
/// لحساب موضع النافذة، وتُظهر رسالة للمستخدم عند الفشل بدل الصمت.
class ShareService {
  ShareService._();

  /// رابط مشاركة التطبيق: صفحة الهبوط (فيها زر App Store + Google Play عند نشره).
  static const String appShareUrl = AppLinks.shareUrl;

  /// موضع نافذة المشاركة — إلزامي على iPad (popover anchor).
  /// يستخدم موضع الـ widget الضاغط إن وُجد، وإلا منتصف الشاشة.
  static Rect _sharePosition(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 2,
      height: 2,
    );
  }

  /// التنفيذ الموحّد للمشاركة + إشعار المستخدم عند الفشل.
  static Future<void> _share(
    BuildContext context, {
    required String text,
    String? subject,
  }) async {
    final origin = _sharePosition(context);
    try {
      // ignore: deprecated_member_use
      await Share.share(text, subject: subject, sharePositionOrigin: origin);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ShareService._share');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّرت المشاركة — حاول مرة أخرى'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// مشاركة صورة PNG (بطاقة آية) مع نص مرافق.
  static Future<void> shareImage(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
    String? text,
  }) async {
    final origin = _sharePosition(context);
    try {
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'image/png')],
        fileNameOverrides: [fileName],
        text: text,
        sharePositionOrigin: origin,
      );
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'ShareService.shareImage');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّرت مشاركة الصورة — حاول مرة أخرى'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// مشاركة التطبيق نفسه (الدال على الخير كفاعله).
  static Future<void> shareApp(BuildContext context) async {
    const text = 'تطبيق الرقية الشاملة (ومعه ${AppIdentity.taTilAttribution}) 🕊\n'
        'رقية شرعية مكتوبة وصوتية وأذكار يومية — تطبيق خيري بدون إعلانات.\n\n'
        '$appShareUrl';
    await _share(context, text: text, subject: 'تطبيق الرقية الشاملة');
  }

  /// مشاركة نص عام (ذِكر/دعاء) مع ذيل التطبيق.
  static Future<void> shareText(
    BuildContext context, {
    required String text,
    String? subject,
  }) =>
      _share(context, text: text, subject: subject);

  /// نسخ آية للحافظة مع المصدر.
  static Future<void> copyVerse({
    required BuildContext context,
    required String verseText,
    required String surahName,
    int? verseNumber,
  }) async {
    final formatted = _formatVerse(
      verseText: verseText,
      surahName: surahName,
      verseNumber: verseNumber,
    );

    try {
      await Clipboard.setData(ClipboardData(text: formatted));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نسخ الآية ✅'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'copyVerse');
    }
  }

  /// مشاركة آية عبر تطبيقات أخرى (واتساب، تويتر، إلخ).
  static Future<void> shareVerse(
    BuildContext context, {
    required String verseText,
    required String surahName,
    int? verseNumber,
  }) async {
    final formatted = _formatVerse(
      verseText: verseText,
      surahName: surahName,
      verseNumber: verseNumber,
    );
    await _share(context, text: formatted, subject: surahName);
  }

  /// مشاركة سورة كاملة.
  static Future<void> shareSurah(
    BuildContext context, {
    required String surahName,
    required List<String> verses,
  }) async {
    final body = StringBuffer()
      ..writeln('﷽')
      ..writeln()
      ..writeln(surahName)
      ..writeln();
    for (final v in verses) {
      body.writeln(v);
    }
    body
      ..writeln()
      ..writeln('— من تطبيق الرقية الشاملة');
    await _share(context, text: body.toString(), subject: surahName);
  }

  static String _formatVerse({
    required String verseText,
    required String surahName,
    int? verseNumber,
  }) {
    final ref = verseNumber != null ? '$surahName: $verseNumber' : surahName;
    return '$verseText\n\n— $ref\n\nمن تطبيق الرقية الشاملة';
  }
}
