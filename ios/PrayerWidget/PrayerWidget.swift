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
        .description("الصلاة القادمة وما تبقّى عليها، والمدة منذ آخر أذان.")
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
            .widgetBackgroundFor(family)
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

// MARK: - مكوّنات مشتركة

/// «مضى ساعة و٥٥ دقيقة منذ العصر» — الوقت يتحرك وحده (Text style: .relative).
struct ElapsedLine: View {
    let previous: PrayerPoint
    var size: CGFloat = 11

    var body: some View {
        (Text(verbatim: "مضى ")
            + Text(previous.date, style: .relative)
            + Text(verbatim: " منذ " + previous.slot.name))
            .font(WTheme.font(size))
            .foregroundColor(WTheme.cream.opacity(0.85))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}

// MARK: - صغير: «الحلقة»

struct PrayerSmallView: View {
    let info: PrayerInfo

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RingView(progress: info.progress, lineWidth: 7)
                VStack(spacing: 0) {
                    Text(verbatim: info.next.slot.name)
                        .font(WTheme.font(14, .bold))
                        .foregroundColor(WTheme.goldSoft)
                    Text(info.next.date, style: .timer)
                        .font(WTheme.font(20, .bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(info.next.date, style: .time)
                        .font(WTheme.font(11))
                        .foregroundColor(WTheme.cream.opacity(0.85))
                }
                .padding(.horizontal, 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let prev = info.previous {
                ElapsedLine(previous: prev, size: 10.5)
            }
        }
    }
}

// MARK: - متوسط: «قوس اليوم»

struct PrayerMediumView: View {
    let info: PrayerInfo

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: info.next.slot.name)
                        .font(WTheme.font(19, .bold))
                        .foregroundColor(WTheme.goldSoft)
                    (Text(verbatim: "بعد ") + Text(info.next.date, style: .timer))
                        .font(WTheme.font(13, .medium))
                        .monospacedDigit()
                        .foregroundColor(.white)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 1) {
                    Text(verbatim: info.city)
                        .font(WTheme.font(12, .medium))
                        .foregroundColor(WTheme.cream)
                        .lineLimit(1)
                    if let prev = info.previous {
                        ElapsedLine(previous: prev, size: 10.5)
                    }
                }
            }

            PrayerDayArc(info: info)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            PrayerCells(info: info)
        }
    }
}

/// خمس خلايا: اسم الصلاة ووقتها، والقادمة مظلَّلة بالذهبي.
struct PrayerCells: View {
    let info: PrayerInfo

    var body: some View {
        HStack(spacing: 2) {
            ForEach(info.todayPrayers) { p in
                PrayerCell(point: p, isNext: p.slot == info.next.slot)
            }
        }
    }
}

struct PrayerCell: View {
    let point: PrayerPoint
    let isNext: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(verbatim: point.slot.name)
                .font(WTheme.font(11, .medium))
                .foregroundColor(isNext ? WTheme.goldSoft : WTheme.cream)
            Text(point.date, style: .time)
                .font(WTheme.font(10))
                .foregroundColor(isNext ? WTheme.goldSoft : WTheme.cream.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isNext ? WTheme.gold.opacity(0.22) : Color.clear)
        )
    }
}

// MARK: - قوس اليوم

enum DayArcGeometry {
    /// f=0 الفجر (يمين الشاشة) … f=1 العشاء (يسارها) — اتجاه القراءة العربية.
    static func point(f: Double, in size: CGSize) -> CGPoint {
        let inset: CGFloat = 8
        let usable = size.width - inset * 2
        let x = inset + usable * CGFloat(1.0 - f)
        let rise = (size.height - 14) * CGFloat(sin(Double.pi * f))
        let y = size.height - 6 - rise
        return CGPoint(x: x, y: y)
    }

    static func fraction(of date: Date, fajr: Date, isha: Date) -> Double {
        let total = isha.timeIntervalSince(fajr)
        if total <= 0 { return 0 }
        let value = date.timeIntervalSince(fajr) / total
        return min(max(value, 0), 1)
    }
}

struct DayArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = 48
        for i in 0...steps {
            let f = Double(i) / Double(steps)
            let pt = DayArcGeometry.point(f: f, in: rect.size)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        return path
    }
}

struct PrayerDayArc: View {
    let info: PrayerInfo

    var body: some View {
        GeometryReader { geo in
            arc(size: geo.size)
        }
    }

    @ViewBuilder
    private func arc(size: CGSize) -> some View {
        let prayers = info.todayPrayers
        if let first = prayers.first, let last = prayers.last, prayers.count >= 2 {
            let fajr = first.date
            let isha = last.date
            ZStack {
                DayArcShape()
                    .stroke(
                        Color.white.opacity(0.28),
                        style: StrokeStyle(lineWidth: 1.6, lineCap: .round, dash: [3, 4])
                    )
                ForEach(prayers) { p in
                    marker(
                        point: p,
                        position: DayArcGeometry.point(
                            f: DayArcGeometry.fraction(of: p.date, fajr: fajr, isha: isha),
                            in: size
                        )
                    )
                }
                sun(
                    position: DayArcGeometry.point(
                        f: DayArcGeometry.fraction(of: info.now, fajr: fajr, isha: isha),
                        in: size
                    )
                )
            }
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func marker(point: PrayerPoint, position: CGPoint) -> some View {
        if point.slot == info.next.slot {
            Circle()
                .stroke(WTheme.gold, lineWidth: 2)
                .frame(width: 10, height: 10)
                .position(position)
        } else if point.date <= info.now {
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
                .position(position)
        } else {
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 1.4)
                .frame(width: 6, height: 6)
                .position(position)
        }
    }

    private func sun(position: CGPoint) -> some View {
        Circle()
            .fill(WTheme.goldSoft)
            .frame(width: 11, height: 11)
            .shadow(color: WTheme.gold.opacity(0.9), radius: 5)
            .position(position)
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
                Text(info.next.date, style: .time)
                    .font(WTheme.font(13, .medium))
            }
            (Text(verbatim: "بعد ") + Text(info.next.date, style: .timer))
                .font(WTheme.font(12))
                .monospacedDigit()
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
        Text(verbatim: info.next.slot.name + " ") + Text(info.next.date, style: .time)
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
