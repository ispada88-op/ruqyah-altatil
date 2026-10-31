import 'package:flutter/material.dart';

import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';

/// يسأل عن رقم صفحة من المصحف (١–٦٠٤). يقبل الأرقام العربية واللاتينية،
/// ويعيد null عند الإلغاء. وحقل الإدخال تملكه حالة الحوار نفسها فلا يُتلَف
/// قبل أن ينتهي إغلاقه.
Future<int?> showPageNumberDialog(
  BuildContext context, {
  String title = 'الانتقال إلى صفحة',
  String confirmLabel = 'انتقال',
  int? initial,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _PageNumberDialog(
        title: title, confirmLabel: confirmLabel, initial: initial),
  );
}

class _PageNumberDialog extends StatefulWidget {
  const _PageNumberDialog(
      {required this.title, required this.confirmLabel, this.initial});

  final String title;
  final String confirmLabel;
  final int? initial;

  @override
  State<_PageNumberDialog> createState() => _PageNumberDialogState();
}

class _PageNumberDialogState extends State<_PageNumberDialog> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial?.toString() ?? '');
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final n = parseArabicInt(_c.text);
    if (n == null || n < 1 || n > kMushafPages) {
      setState(() => _error = 'أدخل رقماً من ١ إلى ${arDigits(kMushafPages)}');
      return;
    }
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: _c,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: '١ – ${arDigits(kMushafPages)}', errorText: _error),
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
        ],
      ),
    );
  }
}
