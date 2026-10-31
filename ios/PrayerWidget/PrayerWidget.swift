import SwiftUI
import WidgetKit

// MARK: - Timeline

struct PrayerEntry: TimelineEntry {
    enum Status {
        case ok
        /// لا لقطة أو لا موقع محدّد.
        case noData
        /// انتهت الأيام المخزّنة.
        case stale
    }

    let date: Date
    let info: PrayerInfo?
    let status: Status
}

struct PrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        return PrayerEntry(date: Date(), info: PrayerSample.info(), status: .ok)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        if context.isPreview {
            completion(PrayerEntry(date: Date(), info: PrayerSample.info(), status: .ok))
            return
        }
        completion(makeEntry(schedule: PrayerSchedule.load(), at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let now = Date()
        guard let schedule = PrayerSchedule.load() else {
            let entry = PrayerEntry(date: now, info: nil, status: .noData)
            completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(1800))))
            return
        }

        // مدخل كل ١٠ دقائق (لتحريك الحلقة) + مدخل عند كل وقت صلاة (لتبديل «القادم»).
        // العدّاد نفسه يتحرك كل ثانية بلا مدخلات (Text style: .timer).
        let horizon = now.addingTimeInterval(24 * 3600)
        var dates: [Date] = [now]
        var t = now.addingTimeInterval(600)
        while t < horizon {
            dates.append(t)
            t = t.addingTimeInterval(600)
        }
        dates.append(contentsOf: schedule.boundaries(from: now, to: horizon))
        dates.sort()

        let entries = dates.map { makeEntry(schedule: schedule, at: $0) }
        completion(Timeline(entries: entries, policy: .after(horizon)))
    }

    private func makeEntry(schedule: PrayerSchedule?, at date: Date) -> PrayerEntry {
        guard let schedule = schedule else {
            return PrayerEntry(date: date, info: nil, status: .noData)
        }
        guard let info = schedule.info(at: date) else {
            return PrayerEntry(date: date, info: nil, status: .stale)
        }
        return PrayerEntry(date: date, info: info, status: .ok)
    }
}

/// بيانات نموذجية لمعرض الودجت والمعاينة (المغرب بعد ٤٢ دقيقة، والعصر منذ ساعتين تقريباً).
enum PrayerSample {
    static func info() -> PrayerInfo {
        let now = Date()
        func at(_ minutes: Double) -> Date { return now.addingTimeInterval(minutes * 60) }
        let fajr = PrayerPoint(slot: .fajr, date: at(-12 * 60))
        let sunrise = PrayerPoint(slot: .sunrise, date: at(-10.5 * 60))
        let dhuhr = PrayerPoint(slot: .dhuhr, date: at(-5.2 * 60))
        let asr = PrayerPoint(slot: .asr, date: at(-115))
        let maghrib = PrayerPoint(slot: .maghrib, date: at(42))
        let isha = PrayerPoint(slot: .isha, date: at(132))
        return PrayerInfo(
            city: "أبها",
            now: now,
            next: maghrib,
            previous: asr,
            today: [fajr, sunrise, dhuhr, asr, maghrib, isha]
        )
    }
}

// MARK: - الودجت

struct PrayerWidget: Widget {
    let kind = "RuqyahPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("مواقيت الصلاة")
        .description("الصلاة القادمة وما تبقّى عليها، وأوقات اليوم بأرقام واضحة، والتاريخ الهجري والميلادي.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

struct PrayerWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PrayerEntry

    var body: some View {
        content
            .environment(\.layoutDirection, .rightToLeft)
            .environment(\.locale, Locale(identifier: "ar_SA"))
            .widgetURL(URL(string: "ruqyah://open/prayer-times"))
            .nightBackgroundFor(family)
    }

    @ViewBuilder
    private var content: some View {
        if let info = entry.info {
            switch family {
            case .systemSmall:
                PrayerSmallView(info: info)
            case .systemMedium:
                PrayerMediumView(info: info)
            case .accessoryCircular:
                PrayerLockCircular(info: info)
            case .accessoryRectangular:
                PrayerLockRectangular(info: info)
            case .accessoryInline:
                PrayerLockInline(info: info)
            default:
                PrayerSmallView(info: info)
            }
        } else {
            PrayerEmptyView(status: entry.status, family: family)
        }
    }
}


// MARK: - مكوّنات مشتركة («ليل ذهبي»)

/// الوقت بأرقام إنجليزية بارزة مع «ص/م» — يُرسم يسار-إلى-يمين دائماً حتى لا ينقلب «4:52».
struct NightClock: View {
    let date: Date
    let size: CGFloat
    let meridiemSize: CGFloat
    var color: Color = WNight.goldBright

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(verbatim: WClock.clock(date))
                .font(WTheme.font(size, .bold))
                .monospacedDigit()
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(verbatim: WClock.meridiem(date))
                .font(WTheme.font(meridiemSize, .bold))
                .foregroundColor(color)
        }
        .environment(\.layoutDirection, .leftToRight)
        .shadow(color: WNight.gold.opacity(0.30), radius: 10)
    }
}

/// «بعد 0:59:12» — العدّاد يتحرك وحده، بأرقام إنجليزية.
struct NightCountdown: View {
    let target: Date
    var size: CGFloat = 12.5

    var body: some View {
        (Text(verbatim: "بعد ") + Text(target, style: .timer))
            .font(WTheme.font(size, .medium))
            .monospacedDigit()
            .foregroundColor(WNight.text)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .environment(\.locale, Locale(identifier: "en_US"))
    }
}

/// التاريخ الهجري (أم القرى) فوق الميلادي.
struct NightDates: View {
    let date: Date
    var hijriSize: CGFloat = 12.5
    var gregorianSize: CGFloat = 11.5

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(verbatim: WClock.hijri(date))
                .font(WTheme.font(hijriSize, .bold))
                .foregroundColor(WNight.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(verbatim: WClock.gregorian(date))
                .font(WTheme.font(gregorianSize, .medium))
                .foregroundColor(WNight.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - صغير

struct PrayerSmallView: View {
    let info: PrayerInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Circle()
                    .fill(WNight.gold)
                    .frame(width: 7, height: 7)
                    .shadow(color: WNight.gold.opacity(0.8), radius: 4)
                Text(verbatim: info.next.slot.name)
                    .font(WTheme.font(15, .bold))
                    .foregroundColor(WNight.gold)
                Spacer(minLength: 4)
                Text(verbatim: info.city)
                    .font(WTheme.font(11, .medium))
                    .foregroundColor(WNight.text.opacity(0.75))
                    .lineLimit(1)
            }
            NightClock(date: info.next.date, size: 48, meridiemSize: 15)
                .padding(.top, 4)
            NightCountdown(target: info.next.date)
            Spacer(minLength: 2)
            NightDates(date: info.now, hijriSize: 12, gregorianSize: 11)
        }
    }
}

// MARK: - متوسط

struct PrayerMediumView: View {
    let info: PrayerInfo

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: "القادمة · " + info.city)
                        .font(WTheme.font(10.5, .medium))
                        .foregroundColor(WNight.text.opacity(0.75))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(verbatim: info.next.slot.name)
                        .font(WTheme.font(22, .bold))
                        .foregroundColor(WNight.gold)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                NightClock(date: info.next.date, size: 44, meridiemSize: 14)
                    .layoutPriority(1)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 2) {
                    NightCountdown(target: info.next.date, size: 12)
                    NightDates(date: info.now, hijriSize: 11.5, gregorianSize: 10.5)
                }
            }
            .frame(maxHeight: .infinity)

            NightCells(info: info)
        }
    }
}

/// خمس خلايا: اسم الصلاة ووقتها بأرقام إنجليزية، والقادمة مظلَّلة بالذهبي.
struct NightCells: View {
    let info: PrayerInfo

    var body: some View {
        HStack(spacing: 4) {
            ForEach(info.todayPrayers) { p in
                NightCell(point: p, isNext: p.slot == info.next.slot)
            }
        }
    }
}

struct NightCell: View {
    let point: PrayerPoint
    let isNext: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(verbatim: point.slot.name)
                .font(WTheme.font(11, .medium))
                .foregroundColor(isNext ? WNight.goldBright : WNight.text)
            Text(verbatim: WClock.clock(point.date))
                .font(WTheme.font(18, .bold))
                .monospacedDigit()
                .foregroundColor(isNext ? WNight.goldBright : WNight.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(verbatim: WClock.meridiem(point.date))
                .font(WTheme.font(9, .medium))
                .foregroundColor(isNext ? WNight.goldBright.opacity(0.8) : WNight.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isNext ? WNight.gold.opacity(0.20) : Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isNext ? WNight.gold.opacity(0.75) : Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}


// MARK: - شاشة القفل

struct PrayerLockCircular: View {
    let info: PrayerInfo

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .trim(from: 0, to: CGFloat(max(info.progress, 0.03)))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)
            VStack(spacing: 0) {
                Text(verbatim: info.next.slot.name)
                    .font(WTheme.font(12, .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(info.next.date, style: .timer)
                    .font(WTheme.font(10, .medium))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .environment(\.locale, Locale(identifier: "en_US"))
            }
            .padding(.horizontal, 7)
        }
    }
}

struct PrayerLockRectangular: View {
    let info: PrayerInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(verbatim: info.next.slot.name)
                    .font(WTheme.font(15, .bold))
                Spacer(minLength: 4)
                Text(verbatim: WClock.clock(info.next.date) + " " + WClock.meridiem(info.next.date))
                    .font(WTheme.font(13, .medium))
            }
            (Text(verbatim: "بعد ") + Text(info.next.date, style: .timer))
                .font(WTheme.font(12))
                .monospacedDigit()
                .environment(\.locale, Locale(identifier: "en_US"))
            ProgressView(value: info.progress)
                .progressViewStyle(.linear)
            if let prev = info.previous {
                (Text(verbatim: "مضى ")
                    + Text(prev.date, style: .relative)
                    + Text(verbatim: " منذ " + prev.slot.name))
                    .font(WTheme.font(10))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

struct PrayerLockInline: View {
    let info: PrayerInfo

    var body: some View {
        Text(verbatim: info.next.slot.name + " " + WClock.clock(info.next.date) + " " + WClock.meridiem(info.next.date))
    }
}

// MARK: - حالات بلا بيانات

struct PrayerEmptyView: View {
    let status: PrayerEntry.Status
    let family: WidgetFamily

    private var message: String {
        switch status {
        case .stale: return "افتح التطبيق لتحديث المواقيت"
        default: return "افتح التطبيق وحدّد موقعك"
        }
    }

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(verbatim: message)
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "mappin.and.ellipse")
            }
        case .accessoryRectangular:
            Text(verbatim: message)
                .font(WTheme.font(13, .medium))
        default:
            VStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 26))
                    .foregroundColor(WTheme.goldSoft)
                Text(verbatim: message)
                    .font(WTheme.font(13, .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
        }
    }
}
