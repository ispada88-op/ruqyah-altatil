// فحص عقد البيانات بين Dart وSwift (يعمل في CI على macOS — ios-compile.yml):
//   swiftc ios/Shared/WidgetStore.swift ios/PrayerWidget/WidgetSnapshot.swift \
//          ios/PrayerWidget/AdhkarNow.swift ios/PrayerWidget/Tests/main.swift -o contract
//   TZ=Asia/Riyadh ./contract ios/PrayerWidget/Tests/snapshot_sample.json
// المثال snapshot_sample.json يقابله test/widget_sync_test.dart من جهة Dart.
import Foundation

var failures = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String, line: Int = #line) {
    if !condition() {
        failures += 1
        print("FAIL (line \(line)): \(message)")
    }
}

let args = CommandLine.arguments
guard args.count >= 2, let data = FileManager.default.contents(atPath: args[1]) else {
    print("usage: contract <snapshot_sample.json>")
    exit(2)
}
guard let snap = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
    print("FAIL: snapshot_sample.json does not decode as WidgetSnapshot")
    exit(1)
}

check(snap.v == 1, "version")
check(snap.city == "أبها", "city")
check(snap.days.count == 3, "three days")
check(snap.days.allSatisfy { $0.t.count == 6 }, "six times per day")

guard let schedule = PrayerSchedule(snapshot: snap) else {
    print("FAIL: PrayerSchedule is nil")
    exit(1)
}

// ٥ أكتوبر ٢٠٢٦ — ٥:٢٠ مساءً بتوقيت أبها: المغرب بعد ٣٠ دقيقة، والعصر قبله.
let now = Date(timeIntervalSince1970: 1791210000)
if let info = schedule.info(at: now) {
    check(info.next.slot == .maghrib, "next prayer at 17:20 is maghrib")
    check(info.previous?.slot == .asr, "previous prayer at 17:20 is asr")
    check(info.today.count == 6, "today has six times (run with TZ=Asia/Riyadh)")
    check(info.todayPrayers.count == 5, "sunrise is not a prayer")
    check(info.progress > 0 && info.progress < 1, "progress is inside (0,1)")
    check(abs(info.next.date.timeIntervalSince(now) - 1800) < 1, "30 minutes left")
    check(info.city == "أبها", "city is carried")
} else {
    check(false, "info(at: now) is nil")
}

// عند وقت المغرب بالضبط: المغرب صار «السابق» والعشاء «القادم».
let atMaghrib = Date(timeIntervalSince1970: 1791211800)
let i2 = schedule.info(at: atMaghrib)
check(i2?.next.slot == .isha, "at maghrib the next is isha")
check(i2?.previous?.slot == .maghrib, "at maghrib the previous is maghrib")

// بعد عشاء اليوم: القادم فجر الغد.
let lateNight = Date(timeIntervalSince1970: snap.days[1].t[5] + 3600)
let i3 = schedule.info(at: lateNight)
check(i3?.next.slot == .fajr, "after isha the next is tomorrow's fajr")
check(i3?.previous?.slot == .isha, "after isha the previous is isha")

// بعد آخر يوم مخزّن: لا معلومات (الودجت يطلب فتح التطبيق).
let lastIsha = snap.days.last!.t[5]
check(schedule.info(at: Date(timeIntervalSince1970: lastIsha + 60)) == nil, "stale after the last stored day")

// قبل أول وقت: لا «سابق».
let firstFajr = snap.days.first!.t[0]
check(schedule.info(at: Date(timeIntervalSince1970: firstFajr - 3600))?.previous == nil, "no previous before the first time")

// مدخلات الجدول الزمني: ٦ أوقات خلال ٢٤ ساعة من الآن.
check(schedule.boundaries(from: now, to: now.addingTimeInterval(24 * 3600)).count == 6, "boundaries in 24h")

// الورد.
if case .active(let w) = WirdState.resolve(snapshot: snap, at: now) {
    check(w.page == 123 && w.start == 120 && w.end == 127, "wird pages")
    check(w.target == 8 && w.read == 3 && w.left == 24 && w.fin == 0, "wird counters")
    check(w.prog == 0.2 && !w.done, "wird progress")
} else {
    check(false, "wird should be active the same day")
}
if case .stale = WirdState.resolve(snapshot: snap, at: now.addingTimeInterval(86400)) {
} else {
    check(false, "wird of yesterday is stale")
}
var off = snap
var w = snap.wird!
w.on = false
w.done = false
off.wird = w
if case .inactive = WirdState.resolve(snapshot: off, at: now) {
} else {
    check(false, "khatma off → inactive")
}
w.done = true
off.wird = w
if case .finished = WirdState.resolve(snapshot: off, at: now) {
} else {
    check(false, "khatma off + done → finished")
}
off.wird = nil
if case .inactive = WirdState.resolve(snapshot: off, at: now) {
} else {
    check(false, "no wird → inactive")
}

// المداومة.
check(snap.program?.day == "2026-10-05", "program day")
check(snap.program?.done == ["morning", "wird"], "program done ids")
check(snap.program?.streak == 6 && snap.program?.goal == 21 && snap.program?.logged == false, "program counters")
check(ProgramSlot.allCases.map { $0.rawValue } == ["morning", "ruqyah", "wird", "evening", "sleep"], "program slot order = ProgramItem in Dart")
if case .today(let t) = ProgramState.resolve(snapshot: snap, at: now) {
    check(t.done == [.morning, .wird] && t.count == 2 && t.total == 5, "program done today")
    check(t.streak == 6 && t.goal == 21 && !t.isNewDay && !t.isComplete, "program streak today")
    check(abs(t.fraction - 0.4) < 0.0001, "program fraction")
} else {
    check(false, "program should resolve for the same day")
}
if case .today(let t) = ProgramState.resolve(snapshot: snap, at: now.addingTimeInterval(86400)) {
    check(t.isNewDay && t.done.isEmpty, "next day: nothing done yet")
    check(t.streak == 0, "next day: streak is gone when yesterday was not logged")
} else {
    check(false, "program should resolve on the next day")
}
var logged = snap
logged.program?.logged = true
if case .today(let t) = ProgramState.resolve(snapshot: logged, at: now.addingTimeInterval(86400)) {
    check(t.streak == 6, "next day: streak survives when yesterday was logged")
} else {
    check(false, "program (logged) should resolve on the next day")
}
if case .today(let t) = ProgramState.resolve(snapshot: logged, at: now.addingTimeInterval(2 * 86400)) {
    check(t.streak == 0, "two days later: streak is gone")
} else {
    check(false, "program (logged) should resolve two days later")
}
var full = snap
full.program?.done = ["morning", "ruqyah", "wird", "evening", "sleep", "bogus"]
if case .today(let t) = ProgramState.resolve(snapshot: full, at: now) {
    check(t.isComplete && t.count == 5 && t.fraction == 1, "all five done; unknown ids ignored")
} else {
    check(false, "program (full) should resolve")
}
var noProgram = snap
noProgram.program = nil
if case .unknown = ProgramState.resolve(snapshot: noProgram, at: now) {
} else {
    check(false, "no program block → unknown (older snapshot)")
}

// أذكار الآن — الاثنين (٥ أكتوبر ٢٠٢٦).
func moment(_ day: Int, _ slot: PrayerSlot, _ minutes: Double = 0) -> Date {
    return Date(timeIntervalSince1970: snap.days[day].t[slot.rawValue] + minutes * 60)
}
func adhkar(_ day: Int, _ slot: PrayerSlot, _ minutes: Double) -> AdhkarNow? {
    return schedule.adhkarNow(at: moment(day, slot, minutes))
}
check(!isFriday(now), "the sample day is a Monday (run with TZ=Asia/Riyadh)")

var a = adhkar(1, .fajr, 10)
check(a?.primary.kind == .afterPrayer(.fajr), "fajr+10: after-prayer adhkar")
check(a?.primary.title == "أذكار بعد صلاة الفجر", "fajr+10: title")
check(a?.secondary?.kind == .morning, "fajr+10: morning adhkar as the second line")
a = adhkar(1, .fajr, 50)
check(a?.primary.kind == .morning && a?.secondary == nil, "fajr+50: morning adhkar")
check(a?.primary.endsAt == moment(1, .dhuhr) && a?.primary.endLabel == "حتى الظهر", "morning runs until dhuhr")
check(a?.primary.url?.absoluteString == "ruqyah://open/adhkar?time=morning", "morning deep link")
a = adhkar(1, .sunrise, 10)
check(a?.primary.kind == .morning, "after sunrise on a weekday: still morning adhkar")
a = adhkar(1, .dhuhr, 10)
check(a?.primary.kind == .afterPrayer(.dhuhr) && a?.secondary == nil, "dhuhr+10: after-prayer only (no tasbeeh line)")
a = adhkar(1, .dhuhr, 60)
check(a?.primary.kind == .tasbeeh && a?.primary.route == "/dhikr", "dhuhr+60: tasbeeh")
a = adhkar(1, .asr, 10)
check(a?.primary.kind == .afterPrayer(.asr) && a?.secondary?.kind == .evening, "asr+10: after-prayer, evening second")
a = adhkar(1, .asr, 50)
check(a?.primary.kind == .evening && a?.primary.endsAt == moment(1, .isha), "asr+50: evening until isha")
check(a?.primary.endLabel == "حتى العشاء", "evening end label")
a = adhkar(1, .maghrib, 10)
check(a?.primary.kind == .afterPrayer(.maghrib) && a?.secondary?.kind == .evening, "maghrib+10")
a = adhkar(1, .maghrib, 50)
check(a?.primary.kind == .evening, "maghrib+50: evening")
a = adhkar(1, .isha, 10)
check(a?.primary.kind == .afterPrayer(.isha) && a?.secondary == nil, "isha+10: after-prayer only")
a = adhkar(1, .isha, 46)
check(a?.primary.kind == .sleep && a?.primary.route == "/tahseen", "isha+46: sleep adhkar")
check(a?.primary.endsAt == moment(2, .fajr) && a?.primary.endLabel == "حتى الفجر", "sleep until tomorrow's fajr")
a = adhkar(1, .fajr, -60)
check(a?.primary.kind == .sleep, "an hour before fajr: still sleep adhkar")
check(adhkar(2, .isha, 60) == nil, "after the last stored day: nil (open the app)")

// الجمعة: نزحف بالجدول أربعة أيام (٩ أكتوبر ٢٠٢٦).
var fri = snap
fri.days = snap.days.map { DayTimes(d: $0.d, t: $0.t.map { $0 + 4 * 86400 }) }
let friSchedule = PrayerSchedule(snapshot: fri)!
func friday(_ slot: PrayerSlot, _ minutes: Double) -> AdhkarNow? {
    return friSchedule.adhkarNow(at: Date(timeIntervalSince1970: fri.days[1].t[slot.rawValue] + minutes * 60))
}
check(isFriday(Date(timeIntervalSince1970: fri.days[1].t[2])), "shifted sample day is a Friday")
var f = friday(.fajr, 50)
check(f?.primary.kind == .morning && f?.primary.endLabel == "حتى الشروق", "friday: morning until sunrise")
f = friday(.sunrise, 10)
check(f?.primary.kind == .kahf && f?.primary.route == "/mushaf/page/293", "friday after sunrise: al-Kahf")
check(f?.primary.endLabel == "حتى العصر", "al-Kahf until asr")
f = friday(.dhuhr, 10)
check(f?.primary.kind == .afterPrayer(.dhuhr) && f?.primary.title == "أذكار بعد صلاة الجمعة", "friday dhuhr is jumu'ah")
check(f?.secondary?.kind == .kahf, "friday dhuhr: al-Kahf as the second line")
f = friday(.dhuhr, 60)
check(f?.primary.kind == .kahf, "friday after dhuhr: al-Kahf")
f = friday(.asr, 50)
check(f?.primary.kind == .evening, "friday asr: evening adhkar again")

// لحظات التبديل خلال ٢٤ ساعة: مغرب وعشاء اليوم، ثم فجر وشروق وظهر وعصر الغد؛ لكلٍّ وقتٌ و+٤٥ د.
check(schedule.adhkarBoundaries(from: now, to: now.addingTimeInterval(24 * 3600)).count == 12, "adhkar boundaries in 24h")

// النصوص العربية.
check(arDigits("2026-10") == "٢٠٢٦-١٠", "arabic-indic digits")
check(ar(604) == "٦٠٤", "ar()")
check(pagesText(1) == "صفحة" && pagesText(2) == "صفحتان", "pages 1/2")
check(pagesText(3) == "٣ صفحات" && pagesText(10) == "١٠ صفحات", "pages 3-10")
check(pagesText(11) == "١١ صفحة", "pages 11+")
check(daysText(1) == "يوم" && daysText(2) == "يومان", "days 1/2")
check(daysText(5) == "٥ أيام" && daysText(12) == "١٢ يوماً", "days 3-10 / 11+")
check(dayKey(now) == "2026-10-05", "dayKey (run with TZ=Asia/Riyadh)")

if failures > 0 {
    print("\(failures) failure(s)")
    exit(1)
}
print("contract OK")
