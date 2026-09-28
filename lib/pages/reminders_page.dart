import 'package:flutter/material.dart';

import 'package:roqia_altatil/services/custom_reminders.dart';
import 'package:roqia_altatil/services/haptic.dart';
import 'package:roqia_altatil/services/notification_service.dart';
import 'package:roqia_altatil/theme.dart';
import 'package:roqia_altatil/utils/arabic_format.dart';
import 'package:roqia_altatil/widgets/section_back_bar.dart';
import 'package:roqia_altatil/nav.dart';

/// تذكيراتي الخاصة (طلب مستخدمة): ذكر يكتبه المستخدم بالوقت الذي يختاره،
/// ويتكرر يومياً. مستقل عن مفتاح «تذكير الأذكار» العام.
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<CustomReminder> _items = [];
  bool _loading = true;

  static const _suggestions = [
    'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
    'أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await CustomRemindersStore.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _commit(List<CustomReminder> items) async {
    setState(() => _items = items);
    await CustomRemindersStore.save(items);
    await NotificationService.instance.reschedule();
  }

  Future<bool> _ensurePermission() async {
    final granted = await NotificationService.instance.requestPermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('إذن الإشعارات مرفوض — لن يظهر التذكير حتى تسمح به'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'فتح الإعدادات',
            textColor: Colors.white,
            onPressed: NotificationService.instance.openSystemSettings,
          ),
        ),
      );
    }
    return granted;
  }

  Future<void> _edit([CustomReminder? existing]) async {
    final result = await showModalBottomSheet<CustomReminder>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ReminderEditor(existing: existing, suggestions: _suggestions),
    );
    if (result == null || !mounted) return;
    await _ensurePermission();
    final items = [..._items];
    final i = items.indexWhere((r) => r.id == result.id);
    if (i >= 0) {
      items[i] = result;
    } else {
      items.add(result);
    }
    await _commit(items);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'سيصلك التذكير يومياً الساعة ${formatTimeAr(result.hour, result.minute)} ✅'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    final full = _items.length >= CustomRemindersStore.maxCount;

    return Column(
      children: [
        const SectionBackBar(
            title: 'تذكيراتي الخاصة', fallbackRoute: AppRoutes.home),
        Expanded(
          child: Scaffold(
            floatingActionButton: full || _loading
                ? null
                : FloatingActionButton.extended(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      Haptic.light();
                      _edit();
                    },
                    icon: const Icon(Icons.alarm_add),
                    label: const Text('إضافة تذكير'),
                  ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      Text(
                        'اكتب الذكر أو الدعاء الذي تريد أن تتذكره، واختر وقته — '
                        'يصلك إشعار به كل يوم في الوقت نفسه.',
                        style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textSecondary,
                        ).copyWith(height: 1.7),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(Icons.alarm_outlined,
                                  size: 56, color: teal.withValues(alpha: 0.5)),
                              const SizedBox(height: 8),
                              const Text('لا توجد تذكيرات بعد'),
                            ],
                          ),
                        ),
                      for (final r in _items)
                        Card(
                          child: ListTile(
                            onTap: () => _edit(r),
                            leading: CircleAvatar(
                              backgroundColor: teal.withValues(alpha: 0.12),
                              child: Icon(Icons.alarm, color: teal),
                            ),
                            title: Text(r.text,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                                'يومياً ${formatTimeAr(r.hour, r.minute)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch.adaptive(
                                  value: r.enabled,
                                  onChanged: (v) {
                                    Haptic.select();
                                    _commit([
                                      for (final x in _items)
                                        x.id == r.id
                                            ? x.copyWith(enabled: v)
                                            : x,
                                    ]);
                                  },
                                ),
                                IconButton(
                                  tooltip: 'حذف',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    Haptic.medium();
                                    _commit(_items
                                        .where((x) => x.id != r.id)
                                        .toList());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (full)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'الحد الأقصى ${arDigits(CustomRemindersStore.maxCount)} تذكيرات.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReminderEditor extends StatefulWidget {
  const _ReminderEditor({this.existing, required this.suggestions});

  final CustomReminder? existing;
  final List<String> suggestions;

  @override
  State<_ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends State<_ReminderEditor> {
  late final _text = TextEditingController(text: widget.existing?.text ?? '');
  late TimeOfDay _time = widget.existing == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay(hour: widget.existing!.hour, minute: widget.existing!.minute);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    final text = CustomRemindersStore.sanitize(_text.text);
    if (text.isEmpty) return;
    Navigator.of(context).pop(
      CustomReminder(
        id: widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        hour: _time.hour,
        minute: _time.minute,
        enabled: widget.existing?.enabled ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teal = isDark ? AppColors.darkTeal : AppColors.primaryTeal;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? 'تذكير جديد' : 'تعديل التذكير',
              style: AppTextStyles.subheader()),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            autofocus: widget.existing == null,
            maxLines: 3,
            minLines: 1,
            maxLength: CustomRemindersStore.maxTextLength,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب الذكر أو الدعاء',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final s in widget.suggestions)
                ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: () => setState(() => _text.text = s),
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule),
            label: Text('الوقت: ${formatTimeAr(_time.hour, _time.minute)}'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _text.text.trim().isEmpty ? null : _save,
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
