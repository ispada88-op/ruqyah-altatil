import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/nav.dart';
import 'package:roqia_altatil/services/khatma_service.dart';
import 'package:roqia_altatil/services/prayer_notification_plan.dart';
import 'package:roqia_altatil/services/prayer_times_service.dart';
import 'package:roqia_altatil/services/program_service.dart';
import 'package:roqia_altatil/services/ruqyah_log_service.dart';
import 'package:roqia_altatil/services/widget_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// أبها — إحداثيات مقرّبة كما يحفظها التطبيق.
PrayerDay? _abha(DateTime d) => computePrayerDay(
      lat: 18.22,
      lon: 42.5,
      date: d,
      method: PrayerMethod.ummAlQura,
      madhab: PrayerMadhab.shafi,
    );

void main() {
  final now = DateTime(2026, 10, 5, 17, 20);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('PrayerKind order is the contract with the Swift widget', () {
    // ios/PrayerWidget/WidgetSnapshot.swift: enum PrayerSlot يعتمد هذا الترتيب.
    expect(PrayerKind.values.map((k) => k.name),
        ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']);
    final swift =
        File('ios/PrayerWidget/WidgetSnapshot.swift').readAsStringSync();
    expect(
        swift, contains('case fajr = 0, sunrise, dhuhr, asr, maghrib, isha'));
  });

  test('program slots are the contract with the Swift widget', () {
    // ios/PrayerWidget/WidgetSnapshot.swift: enum ProgramSlot (الترتيب والمعرّفات).
    final names = ProgramItem.values.map((i) => i.name).toList();
    expect(ProgramItem.values.map((i) => i.id).toList(), names);
    final swift =
        File('ios/PrayerWidget/WidgetSnapshot.swift').readAsStringSync();
    expect(swift, contains('case ${names.join(', ')}'));
  });

  test('adhkar-now links are real routes and Swift mirrors the Dart offsets',
      () {
    final swift = File('ios/PrayerWidget/AdhkarNow.swift').readAsStringSync();
    for (final route in [
      AppRoutes.afterPrayer,
      '${AppRoutes.adhkar}?time=morning',
      '${AppRoutes.adhkar}?time=evening',
      AppRoutes.tahseen,
      AppRoutes.dhikr,
      AppRoutes.mushafPage(AppRoutes.kKahfPage),
    ]) {
      expect(swift, contains('route: "$route"'), reason: route);
      expect(AppRoutes.normalize(Uri.parse(route).path), isNull,
          reason: '$route must be canonical');
    }
    expect(swift, contains('sleepOffsetMinutes = $kSleepOffsetMin.0'));
    final program =
        File('ios/PrayerWidget/ProgramWidget.swift').readAsStringSync();
    expect(program, contains('ruqyah://open${AppRoutes.program}'));
    final adhkarNow =
        File('ios/PrayerWidget/AdhkarNowWidget.swift').readAsStringSync();
    expect(adhkarNow, contains('ruqyah://open${AppRoutes.prayerTimes}'));
  });

  test('payload: yesterday + today + 8 days, six increasing epoch times each',
      () {
    final k = KhatmaService.test();
    final p =
        buildWidgetPayload(now: now, city: 'أبها', dayFor: _abha, khatma: k);
    expect(p.keys.toSet(), {'v', 'gen', 'city', 'days', 'wird'});
    expect(p['v'], kWidgetSnapshotVersion);
    expect(p['city'], 'أبها');
    expect(p['gen'], now.millisecondsSinceEpoch ~/ 1000);

    final days = (p['days'] as List).cast<Map<String, dynamic>>();
    expect(days.length, kWidgetDaysBefore + 1 + kWidgetDaysAhead);
    expect(days.first['d'], '2026-10-04');
    expect(days[1]['d'], '2026-10-05');
    expect(days.last['d'], '2026-10-13');
    for (final d in days) {
      final t = (d['t'] as List).cast<int>();
      expect(t.length, 6);
      for (var i = 1; i < t.length; i++) {
        expect(t[i], greaterThan(t[i - 1]), reason: '${d['d']} slot $i');
      }
    }
    final today = _abha(DateTime(2026, 10, 5))!;
    final t = (days[1]['t'] as List).cast<int>();
    for (final kind in PrayerKind.values) {
      expect(t[kind.index], today[kind].millisecondsSinceEpoch ~/ 1000,
          reason: kind.name);
    }
  });

  test('payload shape equals ios/PrayerWidget/Tests/snapshot_sample.json',
      () async {
    // العقد من جهة Swift: ios/PrayerWidget/Tests/main.swift يفك الملف نفسه
    // (ios-compile.yml). أي تغيير في المفاتيح/الأنواع يكسر الاختبارين معاً.
    final sample = jsonDecode(
        File('ios/PrayerWidget/Tests/snapshot_sample.json')
            .readAsStringSync()) as Map<String, dynamic>;
    final k = KhatmaService.test();
    await k.start(30, now: now);
    final log = RuqyahLogService.test();
    final program = ProgramService.test(log: log, khatma: k);
    await program.toggle(ProgramItem.morning, now: now);
    final built = jsonDecode(jsonEncode(buildWidgetPayload(
        now: now,
        city: 'أبها',
        dayFor: _abha,
        khatma: k,
        program: program,
        log: log))) as Map<String, dynamic>;

    String shape(Object? v) => switch (v) {
          Map<String, dynamic> m =>
            '{${(m.keys.toList()..sort()).map((key) => '$key:${shape(m[key])}').join(',')}}',
          List<dynamic> l => '[${l.isEmpty ? '' : shape(l.first)}]',
          int _ => 'int',
          double _ => 'double',
          bool _ => 'bool',
          String _ => 'string',
          _ => 'null',
        };
    expect(shape(built), shape(sample));
  });

  test('payload never carries coordinates (location stays on the device)', () {
    final k = KhatmaService.test();
    final json = jsonEncode(
        buildWidgetPayload(now: now, city: 'أبها', dayFor: _abha, khatma: k));
    expect(json, isNot(contains('lat')));
    expect(json, isNot(contains('lon')));
    expect(json, isNot(contains('18.22')));
    expect(json, isNot(contains('42.5')));
  });

  test('no location: no days, the widget asks to open the app', () {
    final k = KhatmaService.test();
    final p =
        buildWidgetPayload(now: now, city: '', dayFor: (_) => null, khatma: k);
    expect(p['days'], isEmpty);
    expect(p['wird'], isNotNull);
  });

  test('wird payload follows the khatma through a day', () async {
    final k = KhatmaService.test();
    var w = wirdPayload(k, now);
    expect(w['on'], false);
    expect(w['done'], false);

    await k.start(30, now: now);
    w = wirdPayload(k, now);
    expect(w['on'], true);
    expect(w['day'], '2026-10-05');
    expect(w['page'], 1);
    expect(w['start'], 1);
    expect(w['target'], 21); // ⌈٦٠٤ ÷ ٣٠⌉
    expect(w['end'], 21);
    expect(w['read'], 0);
    expect(w['done'], false);
    expect(w['prog'], 0.0);
    expect(w['left'], 29);

    await k.onPageViewed(1, now: now);
    await k.onPageViewed(2, now: now);
    w = wirdPayload(k, now);
    expect(w['page'], 3);
    expect(w['read'], 2);
    expect(w['prog'], double.parse((2 / 604).toStringAsFixed(4)));

    await k.completeToday(now: now);
    w = wirdPayload(k, now);
    expect(w['done'], true);
    expect(w['read'], 21);
    expect(w['page'], 22);

    // اليوم التالي: ورد جديد يبدأ من الصفحة التالية وlefts أقل.
    final tomorrow = now.add(const Duration(days: 1));
    k.refresh(tomorrow);
    w = wirdPayload(k, tomorrow);
    expect(w['day'], '2026-10-06');
    expect(w['done'], false);
    expect(w['start'], 22);
    expect(w['left'], 28);
  });

  test('program payload follows the day and the khatma', () async {
    final k = KhatmaService.test();
    final log = RuqyahLogService.test();
    final program = ProgramService.test(log: log, khatma: k);
    Map<String, dynamic> payload() =>
        programPayload(program: program, log: log, khatma: k, now: now);

    expect(payload(), {
      'day': '2026-10-05',
      'done': <String>[],
      'streak': 0,
      'goal': 7,
      'logged': false,
    });

    // البنود بترتيب ProgramItem لا ترتيب الإنجاز.
    await program.toggle(ProgramItem.sleep, now: now);
    await program.toggle(ProgramItem.morning, now: now);
    expect(payload()['done'], ['morning', 'sleep']);

    // إتمام ورد الختمة يُحتسب «الورد» من تلقاء نفسه.
    await k.start(30, now: now);
    await k.completeToday(now: now);
    expect(payload()['done'], ['morning', 'wird', 'sleep']);

    // اكتمال البنود الخمسة يسجّل اليوم في سجل الرقية فتبدأ السلسلة.
    await program.toggle(ProgramItem.wird, now: now);
    await program.toggle(ProgramItem.ruqyah, now: now);
    await program.toggle(ProgramItem.evening, now: now);
    final p = payload();
    expect(p['done'], ['morning', 'ruqyah', 'wird', 'evening', 'sleep']);
    expect(p['logged'], true);
    expect(p['streak'], 1);

    // اليوم التالي: لا بنود منجزة، والسلسلة تبقى لأن أمس مسجّل.
    final tomorrow = now.add(const Duration(days: 1));
    final next =
        programPayload(program: program, log: log, khatma: k, now: tomorrow);
    expect(next['day'], '2026-10-06');
    expect(next['done'], isNot(contains('morning')));
    expect(next['logged'], false);
    expect(next['streak'], 1);
  });

  group('WidgetSyncService', () {
    late List<String> sent;
    late KhatmaService k;
    late RuqyahLogService log;
    late ProgramService program;

    setUp(() {
      sent = [];
      k = KhatmaService.test();
      log = RuqyahLogService.test();
      program = ProgramService.test(log: log, khatma: k);
      PrayerTimesService.instance
          .debugSet(lat: 18.22, lon: 42.5, label: 'أبها');
    });

    tearDown(() => PrayerTimesService.instance.debugSet());

    WidgetSyncService svc({bool enabled = true}) => WidgetSyncService.test(
          send: (j) async {
            sent.add(j);
            return true;
          },
          enabled: enabled,
          khatma: k,
          program: program,
          log: log,
        );

    test('sends once, then only when something changed', () async {
      final s = svc();
      await s.sync(now: now);
      expect(sent.length, 1);
      final decoded = jsonDecode(sent.single) as Map<String, dynamic>;
      expect(decoded['city'], 'أبها');
      expect((decoded['days'] as List).length, 10);

      // نفس الحالة بعد دقائق: «gen» وحده يتغيّر فلا إرسال.
      await s.sync(now: now.add(const Duration(minutes: 5)));
      expect(sent.length, 1);

      // قراءة صفحة في الختمة → إرسال جديد.
      await k.start(30, now: now);
      await s.sync(now: now);
      expect(sent.length, 2);
      expect((jsonDecode(sent.last) as Map)['wird']['on'], true);

      // إنجاز بند في المداومة → إرسال جديد يحمل البند.
      await program.toggle(ProgramItem.morning, now: now);
      await s.sync(now: now);
      expect(sent.length, 3);
      expect((jsonDecode(sent.last) as Map)['program']['done'], ['morning']);

      // اليوم التالي → أيام مختلفة → إرسال.
      await s.sync(now: now.add(const Duration(days: 1)));
      expect(sent.length, 4);

      await s.sync(now: now.add(const Duration(days: 1)), force: true);
      expect(sent.length, 5);
    });

    test('disabled platforms never send', () async {
      final s = svc(enabled: false);
      await s.sync(now: now);
      expect(sent, isEmpty);
    });

    test('a failing channel is swallowed and retried next time', () async {
      var fail = true;
      final s = WidgetSyncService.test(
        send: (j) async {
          if (fail) throw Exception('channel down');
          sent.add(j);
          return true;
        },
        khatma: k,
        program: program,
        log: log,
      );
      await s.sync(now: now); // لا يرمي
      expect(sent, isEmpty);
      fail = false;
      await s.sync(now: now);
      expect(sent.length, 1);
    });

    test('a refused write (false) is retried too', () async {
      var ok = false;
      final s = WidgetSyncService.test(
        send: (j) async {
          sent.add(j);
          return ok;
        },
        khatma: k,
        program: program,
        log: log,
      );
      await s.sync(now: now);
      ok = true;
      await s.sync(now: now);
      expect(sent.length, 2);
      await s.sync(now: now);
      expect(sent.length, 2);
    });

    test('attach sends after a prayer-settings change', () async {
      final s = svc();
      s.attach();
      addTearDown(s.detach);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sent.length, 1);
      PrayerTimesService.instance
          .debugSet(lat: 21.42, lon: 39.83, label: 'مكة المكرمة');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sent.length, 2);
      expect((jsonDecode(sent.last) as Map)['city'], 'مكة المكرمة');
    });
  });
}
