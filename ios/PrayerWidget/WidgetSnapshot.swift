import Foundation

// MARK: - اللقطة التي يكتبها التطبيق (lib/services/widget_sync_service.dart)

struct WidgetSnapshot: Codable {
    var v: Int
    var gen: Double
    var city: String
    var days: [DayTimes]
    var wird: WirdInfo?
    /// برنامج المداومة اليومي — غائب في لقطات الإصدارات الأقدم.
    var program: ProgramInfo?
}

/// أوقات يوم واحد: الفجر، الشروق، الظهر، العصر، المغرب، العشاء (ثوانٍ منذ 1970).
struct DayTimes: Codable {
    var d: String
    var t: [Double]
}

struct WirdInfo: Codable {
    var on: Bool
    var day: String
    var page: Int
    var start: Int
    var end: Int
    var target: Int
    var read: Int
    var done: Bool
    var prog: Double
    var left: Int
    var fin: Int
}

/// بنود المداومة المنجزة اليوم + سلسلة أيام الرقية (lib/services/widget_sync_service.dart).
struct ProgramInfo: Codable {
    var day: String
    /// معرّفات البنود المنجزة اليوم (ProgramSlot.rawValue).
    var done: [String]
    var streak: Int
    var goal: Int
    /// هل سُجّل اليوم في سجل الرقية (يحدّد بقاء السلسلة بعد منتصف الليل).
    var logged: Bool
}

enum SnapshotLoader {
    static func load() -> WidgetSnapshot? {
        guard let data = WidgetStore.read() else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}

// MARK: - الصلوات

/// الترتيب مطابق لـ PrayerKind في Dart.
enum PrayerSlot: Int, CaseIterable {
    case fajr = 0, sunrise, dhuhr, asr, maghrib, isha

    var name: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    /// الشروق وقت لا صلاة.
    var isPrayer: Bool { return self != .sunrise }
}

struct PrayerPoint: Identifiable {
    let slot: PrayerSlot
    let date: Date
    var id: Int { return slot.rawValue }
}

/// ما يحتاجه العرض في لحظة معيّنة.
struct PrayerInfo {
    let city: String
    let now: Date
    let next: PrayerPoint
    let previous: PrayerPoint?
    /// أوقات يوم [now] (الشروق مشمول)، تصاعدياً.
    let today: [PrayerPoint]

    /// نسبة ما مضى بين آخر أذان والقادم (0...1).
    var progress: Double {
        guard let p = previous else { return 0 }
        let total = next.date.timeIntervalSince(p.date)
        if total <= 0 { return 0 }
        let value = now.timeIntervalSince(p.date) / total
        return min(max(value, 0), 1)
    }

    var todayPrayers: [PrayerPoint] {
        return today.filter { $0.slot.isPrayer }
    }
}

struct PrayerSchedule {
    let points: [PrayerPoint]
    let city: String

    init?(snapshot: WidgetSnapshot) {
        var pts: [PrayerPoint] = []
        for day in snapshot.days {
            if day.t.count != 6 { continue }
            for slot in PrayerSlot.allCases {
                let date = Date(timeIntervalSince1970: day.t[slot.rawValue])
                pts.append(PrayerPoint(slot: slot, date: date))
            }
        }
        if pts.isEmpty { return nil }
        pts.sort { $0.date < $1.date }
        self.points = pts
        self.city = snapshot.city
    }

    static func load() -> PrayerSchedule? {
        guard let snap = SnapshotLoader.load() else { return nil }
        return PrayerSchedule(snapshot: snap)
    }

    /// null حين انتهت الأيام المخزّنة (لم يُفتح التطبيق منذ مدة).
    func info(at now: Date) -> PrayerInfo? {
        guard let next = points.first(where: { $0.slot.isPrayer && $0.date > now }) else {
            return nil
        }
        let previous = points.last(where: { $0.slot.isPrayer && $0.date <= now })
        let cal = Calendar.current
        let day = points.filter { cal.isDate($0.date, inSameDayAs: now) }
        return PrayerInfo(city: city, now: now, next: next, previous: previous, today: day)
    }

    /// لحظات تتغيّر عندها الشاشة: كل وقت في (start, end).
    func boundaries(from start: Date, to end: Date) -> [Date] {
        return points.map { $0.date }.filter { $0 > start && $0 < end }
    }
}

// MARK: - الورد

/// «yyyy-MM-dd» لتاريخ جهاز المستخدم — نفس صيغة khatmaDayKey في Dart.
func dayKey(_ date: Date) -> String {
    let c = Calendar(identifier: .gregorian)
    let parts = c.dateComponents(in: TimeZone.current, from: date)
    let y = parts.year ?? 0
    let m = parts.month ?? 0
    let d = parts.day ?? 0
    return String(format: "%04d-%02d-%02d", y, m, d)
}

enum WirdState {
    /// لا ختمة جارية.
    case inactive
    /// أُتمّت الختمة كلها.
    case finished
    /// اللقطة من يوم سابق: يلزم فتح التطبيق ليحسب ورد اليوم الجديد.
    case stale(WirdInfo)
    case active(WirdInfo)

    static func resolve(snapshot: WidgetSnapshot?, at date: Date) -> WirdState {
        guard let w = snapshot?.wird else { return .inactive }
        if !w.on {
            return w.done ? .finished : .inactive
        }
        if w.day != dayKey(date) { return .stale(w) }
        return .active(w)
    }
}

// MARK: - نصوص عربية

/// أرقام عربية هندية (٠-٩) كما في التطبيق.
func arDigits(_ s: String) -> String {
    let map: [Character: Character] = [
        "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
        "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩",
    ]
    return String(s.map { map[$0] ?? $0 })
}

func ar(_ n: Int) -> String {
    return arDigits(String(n))
}

/// «صفحة / صفحتان / ٣ صفحات / ١١ صفحة».
func pagesText(_ n: Int) -> String {
    if n == 1 { return "صفحة" }
    if n == 2 { return "صفحتان" }
    if n >= 3 && n <= 10 { return "\(ar(n)) صفحات" }
    return "\(ar(n)) صفحة"
}

/// «يوم / يومان / ٣ أيام / ١١ يوماً».
func daysText(_ n: Int) -> String {
    if n == 1 { return "يوم" }
    if n == 2 { return "يومان" }
    if n >= 3 && n <= 10 { return "\(ar(n)) أيام" }
    return "\(ar(n)) يوماً"
}

// MARK: - المداومة

/// بنود برنامج المداومة — الترتيب والمعرّفات مطابقة لـ ProgramItem في Dart (يثبّته اختبار).
enum ProgramSlot: String, CaseIterable {
    case morning, ruqyah, wird, evening, sleep

    var label: String {
        switch self {
        case .morning: return "الصباح"
        case .ruqyah: return "الرقية"
        case .wird: return "الورد"
        case .evening: return "المساء"
        case .sleep: return "النوم"
        }
    }

    var symbol: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .ruqyah: return "headphones"
        case .wird: return "book.fill"
        case .evening: return "sunset.fill"
        case .sleep: return "moon.stars.fill"
        }
    }
}

struct ProgramToday {
    let done: Set<ProgramSlot>
    let streak: Int
    let goal: Int
    /// اللقطة من يوم سابق: لم تُنجز بنود اليوم الجديد بعد (الإنجاز لا يتم إلا داخل التطبيق).
    let isNewDay: Bool

    var count: Int { return done.count }
    var total: Int { return ProgramSlot.allCases.count }
    var fraction: Double { return Double(count) / Double(total) }
    var isComplete: Bool { return count == total }
}

enum ProgramState {
    /// لا لقطة مداومة (التطبيق لم يُفتح بعد بهذا الإصدار).
    case unknown
    case today(ProgramToday)

    static func resolve(snapshot: WidgetSnapshot?, at date: Date) -> ProgramState {
        guard let p = snapshot?.program else { return .unknown }
        if p.day == dayKey(date) {
            let done = Set(p.done.compactMap { ProgramSlot(rawValue: $0) })
            return .today(ProgramToday(done: done, streak: p.streak, goal: p.goal, isNewDay: false))
        }
        // يوم جديد: لا بنود منجزة بعد. السلسلة تبقى فقط إن كان أمس مسجّلاً.
        var streak = 0
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        if p.logged, let yesterday = cal.date(byAdding: .day, value: -1, to: date),
           p.day == dayKey(yesterday) {
            streak = p.streak
        }
        return .today(ProgramToday(done: [], streak: streak, goal: p.goal, isNewDay: true))
    }
}
