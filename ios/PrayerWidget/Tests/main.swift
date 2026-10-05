// فحص عقد البيانات بين Dart وSwift (يعمل في CI على macOS — ios-compile.yml):
//   swiftc ios/Shared/WidgetStore.swift ios/PrayerWidget/WidgetSnapshot.swift \
//          ios/PrayerWidget/Tests/main.swift -o contract
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
