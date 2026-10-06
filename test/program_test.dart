import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/services/program_service.dart';
import 'package:roqia_altatil/services/ruqyah_log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final day = DateTime(2026, 10, 3, 10);

  test('day is complete only when every item is done', () {
    expect(isProgramDayComplete({}), isFalse);
    final almost = {...ProgramItem.values}..remove(ProgramItem.sleep);
    expect(isProgramDayComplete(almost), isFalse);
    expect(isProgramDayComplete({...ProgramItem.values}), isTrue);
  });

  test('wird counts automatically when the khatma day is done', () {
    final rest = {...ProgramItem.values}..remove(ProgramItem.wird);
    expect(isProgramDayComplete(rest), isFalse);
    expect(isProgramDayComplete(rest, wirdFromKhatma: true), isTrue);
  });

  test(
      'checking everything records the day in the ruqyah log; unchecking keeps it',
      () async {
    final log = RuqyahLogService.test();
    final p = ProgramService.test(log: log, khatma: KhatmaService.test());
    for (final i in ProgramItem.values) {
      expect(log.isDone(day), isFalse);
      await p.toggle(i, now: day);
    }
    expect(p.isComplete(day), isTrue);
    expect(log.isDone(day), isTrue);
    await p.toggle(ProgramItem.sleep, now: day); // تراجع
    expect(p.isComplete(day), isFalse);
    expect(log.isDone(day), isTrue); // لا يُلغى تلقائياً
  });

  test('state is per day and survives a reload', () async {
    final log = RuqyahLogService.test();
    final a = ProgramService.test(log: log, khatma: KhatmaService.test());
    await a.toggle(ProgramItem.morning, now: day);
    final b = ProgramService.test(log: log, khatma: KhatmaService.test());
    await b.ensureLoaded();
    expect(b.doneOn(day), {ProgramItem.morning});
    expect(b.doneOn(day.add(const Duration(days: 1))), isEmpty);
  });

  test('old days are pruned and corrupt entries ignored', () async {
    SharedPreferences.setMockInitialValues({
      'program_done': [
        '2026-10-03:morning',
        'bad',
        '2026-10-03:nope',
        'x:y:z',
        '2026-01-01:evening'
      ],
    });
    final p = ProgramService.test(
        log: RuqyahLogService.test(), khatma: KhatmaService.test());
    await p.ensureLoaded();
    expect(p.doneOn(day), {ProgramItem.morning});
    await p.toggle(ProgramItem.ruqyah, now: day);
    final raw =
        (await SharedPreferences.getInstance()).getStringList('program_done')!;
    expect(raw.any((e) => e.startsWith('2026-01-01')), isFalse);
  });
}
