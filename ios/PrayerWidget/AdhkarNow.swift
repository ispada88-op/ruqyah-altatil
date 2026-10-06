import Foundation

// MARK: - «أذكار الآن»: أي ذكر يناسب هذه اللحظة؟
//
// منطق نقي (Foundation فقط) يُحسب من أوقات الصلاة المخزّنة في اللقطة؛ لا يحتاج
// بيانات إضافية من التطبيق. يغطيه ios/PrayerWidget/Tests/main.swift (ios-compile.yml).
//
// الترتيب خلال اليوم:
//   • بعد كل أذان بـ٤٥ دقيقة: «أذكار بعد صلاة …» (والذكر العام للوقت سطراً ثانياً).
//   • الفجر → الظهر: أذكار الصباح (الجمعة: حتى الشروق، ثم سورة الكهف إلى العصر).
//   • الظهر → العصر: التسبيح (الجمعة: سورة الكهف).
//   • العصر → العشاء: أذكار المساء.
//   • بعد العشاء بـ٤٥ دقيقة → الفجر: أذكار النوم والتحصين.

enum AdhkarWindows {
    /// مدة «أذكار بعد الصلاة» بعد الأذان.
    static let afterPrayerMinutes = 45.0
    /// أذكار النوم بعد العشاء بكم دقيقة — تطابق kSleepOffsetMin في Dart (يثبّته اختبار).
    static let sleepOffsetMinutes = 45.0
}

enum AdhkarKind: Equatable {
    case afterPrayer(PrayerSlot)
    case morning
    case evening
    case sleep
    case kahf
    case tasbeeh
}

struct AdhkarNowInfo: Equatable {
    let kind: AdhkarKind
    /// «أذكار بعد صلاة العصر».
    let title: String
    /// كلمة أو كلمتان للدائرة الصغيرة على شاشة القفل.
    let shortTitle: String
    /// سطر وصف ثابت لكل نوع.
    let hint: String
    /// رمز SF Symbols.
    let symbol: String
    /// مسار الصفحة داخل التطبيق (يُفتح بـ ruqyah://open<route>) — يطابق AppRoutes في Dart.
    let route: String
    /// آخر وقت يظهر فيه هذا الذكر، ووقت الصلاة الذي ينتهي عنده (لعبارة «حتى الظهر»).
    let endsAt: Date?
    let endsSlot: PrayerSlot?

    var url: URL? { return URL(string: "ruqyah://open" + route) }
    var endLabel: String? {
        guard let slot = endsSlot else { return nil }
        return "حتى " + slot.name
    }
}

struct AdhkarNow: Equatable {
    let primary: AdhkarNowInfo
    /// ذكر الوقت العام أثناء نافذة «بعد الصلاة» (مثلاً أذكار الصباح بعد الفجر).
    let secondary: AdhkarNowInfo?
}

private func makeInfo(
    _ kind: AdhkarKind,
    title: String,
    shortTitle: String,
    hint: String,
    symbol: String,
    route: String,
    endsAt: Date? = nil,
    endsSlot: PrayerSlot? = nil
) -> AdhkarNowInfo {
    return AdhkarNowInfo(
        kind: kind,
        title: title,
        shortTitle: shortTitle,
        hint: hint,
        symbol: symbol,
        route: route,
        endsAt: endsAt,
        endsSlot: endsSlot
    )
}

/// الجمعة بالتقويم الميلادي وتوقيت الجهاز.
func isFriday(_ date: Date) -> Bool {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone.current
    return cal.component(.weekday, from: date) == 6
}

extension PrayerSchedule {
    /// أول وقت للصلاة [slot] بعد [now] (أو nil).
    func nextTime(of slot: PrayerSlot, after now: Date) -> Date? {
        return points.first(where: { $0.slot == slot && $0.date > now })?.date
    }

    /// الذكر المناسب للحظة [now]؛ nil حين لا أوقات مخزّنة حولها (افتح التطبيق).
    func adhkarNow(at now: Date) -> AdhkarNow? {
        guard points.contains(where: { $0.date > now }),
              let prev = points.last(where: { $0.date <= now }) else {
            return nil
        }
        let friday = isFriday(now)
        let general = generalAdhkar(prev: prev, now: now, friday: friday)

        let afterEnd = prev.date.addingTimeInterval(AdhkarWindows.afterPrayerMinutes * 60)
        if prev.slot.isPrayer && now < afterEnd {
            let name = (prev.slot == .dhuhr && friday) ? "الجمعة" : prev.slot.name
            let after = makeInfo(
                .afterPrayer(prev.slot),
                title: "أذكار بعد صلاة " + name,
                shortTitle: "بعد الصلاة",
                hint: "تسبيح وتحميد وتكبير وآية الكرسي",
                symbol: "hands.sparkles.fill",
                route: "/after-prayer",
                endsAt: afterEnd
            )
            // التسبيح العام لا يزاحم أذكار بعد الصلاة؛ غيره (صباح/مساء/كهف) يظهر ثانياً.
            if let g = general, g.kind != .tasbeeh {
                return AdhkarNow(primary: after, secondary: g)
            }
            return AdhkarNow(primary: after, secondary: nil)
        }
        if let g = general {
            return AdhkarNow(primary: g, secondary: nil)
        }
        return nil
    }

    private func generalAdhkar(prev: PrayerPoint, now: Date, friday: Bool) -> AdhkarNowInfo? {
        switch prev.slot {
        case .fajr:
            let end: PrayerSlot = friday ? .sunrise : .dhuhr
            return morning(until: end, now: now)
        case .sunrise:
            return friday ? kahf(now: now) : morning(until: .dhuhr, now: now)
        case .dhuhr:
            return friday ? kahf(now: now) : tasbeeh()
        case .asr, .maghrib:
            return makeInfo(
                .evening,
                title: "أذكار المساء",
                shortTitle: "المساء",
                hint: "اختم نهارك بذكر الله",
                symbol: "sunset.fill",
                route: "/adhkar?time=evening",
                endsAt: nextTime(of: .isha, after: now),
                endsSlot: .isha
            )
        case .isha:
            let sleepFrom = prev.date.addingTimeInterval(AdhkarWindows.sleepOffsetMinutes * 60)
            if now < sleepFrom { return nil }
            return makeInfo(
                .sleep,
                title: "أذكار النوم",
                shortTitle: "النوم",
                hint: "التحصين قبل أن تنام",
                symbol: "moon.stars.fill",
                route: "/tahseen",
                endsAt: nextTime(of: .fajr, after: now),
                endsSlot: .fajr
            )
        }
    }

    private func morning(until slot: PrayerSlot, now: Date) -> AdhkarNowInfo {
        return makeInfo(
            .morning,
            title: "أذكار الصباح",
            shortTitle: "الصباح",
            hint: "ابدأ يومك بذكر الله",
            symbol: "sun.max.fill",
            route: "/adhkar?time=morning",
            endsAt: nextTime(of: slot, after: now),
            endsSlot: slot
        )
    }

    private func kahf(now: Date) -> AdhkarNowInfo {
        return makeInfo(
            .kahf,
            title: "سورة الكهف",
            shortTitle: "الكهف",
            hint: "من سنن يوم الجمعة",
            symbol: "book.fill",
            route: "/mushaf/page/293",
            endsAt: nextTime(of: .asr, after: now),
            endsSlot: .asr
        )
    }

    private func tasbeeh() -> AdhkarNowInfo {
        return makeInfo(
            .tasbeeh,
            title: "التسبيح والاستغفار",
            shortTitle: "التسبيح",
            hint: "سبحان الله وبحمده",
            symbol: "sparkles",
            route: "/dhikr"
        )
    }

    /// لحظات يتغيّر عندها الذكر: كل وقت صلاة وبعده بـ٤٥ دقيقة (نهاية «بعد الصلاة» وبدء النوم).
    func adhkarBoundaries(from start: Date, to end: Date) -> [Date] {
        var out: [Date] = []
        let offset = AdhkarWindows.afterPrayerMinutes * 60
        for p in points {
            out.append(p.date)
            out.append(p.date.addingTimeInterval(offset))
            if p.slot == .isha {
                out.append(p.date.addingTimeInterval(AdhkarWindows.sleepOffsetMinutes * 60))
            }
        }
        // بلا تكرار (نهاية «بعد الصلاة» وبدء النوم بعد العشاء يتطابقان الآن).
        return Array(Set(out.filter { $0 > start && $0 < end })).sorted()
    }
}
