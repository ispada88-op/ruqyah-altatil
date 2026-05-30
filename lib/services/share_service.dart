import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'error_reporter.dart';

/// خدمة مشاركة ونسخ النصوص القرآنية.
class ShareService {
  ShareService._();

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
  static Future<void> shareVerse({
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
      // ignore: deprecated_member_use
      await Share.share(formatted, subject: surahName);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'shareVerse');
    }
  }

  /// مشاركة سورة كاملة.
  static Future<void> shareSurah({
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
      ..writeln('— من تطبيق رقية التعطيل');

    try {
      // ignore: deprecated_member_use
      await Share.share(body.toString(), subject: surahName);
    } catch (e, st) {
      ErrorReporter.report(e, st, context: 'shareSurah');
    }
  }

  static String _formatVerse({
    required String verseText,
    required String surahName,
    int? verseNumber,
  }) {
    final ref = verseNumber != null ? '$surahName: $verseNumber' : surahName;
    return '$verseText\n\n— $ref\n\nمن تطبيق رقية التعطيل';
  }
}
