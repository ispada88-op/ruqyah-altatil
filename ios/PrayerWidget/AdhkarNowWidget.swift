import SwiftUI
import WidgetKit

// MARK: - Timeline

struct AdhkarNowEntry: TimelineEntry {
    enum Status {
        case ok
        /// لا لقطة أو لا موقع محدّد.
        case noData
        /// انتهت الأيام المخزّنة.
        case stale
    }

    let date: Date
    let now: AdhkarNow?
    let status: Status
}

struct AdhkarNowProvider: TimelineProvider {
    func placeholder(in context: Context) -> AdhkarNowEntry {
        return AdhkarNowSample.entry()
    }

    func getSnapshot(in context: Context, completion: @escaping (AdhkarNowEntry) -> Void) {
        if context.isPreview {
            completion(AdhkarNowSample.entry())
            return
        }
        completion(makeEntry(schedule: PrayerSchedule.load(), at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AdhkarNowEntry>) -> Void) {
        let now = Date()
        guard let schedule = PrayerSchedule.load() else {
            let entry = AdhkarNowEntry(date: now, now: nil, status: .noData)
            completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(1800))))
            return
        }

        // مدخل الآن + مدخل عند كل لحظة يتبدّل فيها الذكر خلال ٢٤ ساعة (بلا تكرار متتالٍ).
        let horizon = now.addingTimeInterval(24 * 3600)
        var dates: [Date] = [now]
        dates.append(contentsOf: schedule.adhkarBoundaries(from: now, to: horizon))

        var entries: [AdhkarNowEntry] = []
        for d in dates {
            let entry = makeEntry(schedule: schedule, at: d)
            if let last = entries.last, last.now == entry.now, last.status == entry.status {
                continue
            }
            entries.append(entry)
        }
        completion(Timeline(entries: entries, policy: .after(horizon)))
    }

    private func makeEntry(schedule: PrayerSchedule?, at date: Date) -> AdhkarNowEntry {
        guard let schedule = schedule else {
            return AdhkarNowEntry(date: date, now: nil, status: .noData)
        }
        guard let result = schedule.adhkarNow(at: date) else {
            return AdhkarNowEntry(date: date, now: nil, status: .stale)
        }
        return AdhkarNowEntry(date: date, now: result, status: .ok)
    }
}

/// بيانات نموذجية لمعرض الودجت: بعد صلاة العصر، وأذكار المساء ثانياً.
enum AdhkarNowSample {
    static func entry() -> AdhkarNowEntry {
        let now = Date()
        let evening = AdhkarNowInfo(
            kind: .evening,
            title: "أذكار المساء",
            shortTitle: "المساء",
            hint: "اختم نهارك بذكر الله",
            symbol: "sunset.fill",
            route: "/adhkar?time=evening",
            endsAt: now.addingTimeInterval(3 * 3600),
            endsSlot: .isha
        )
        let after = AdhkarNowInfo(
            kind: .afterPrayer(.asr),
            title: "أذكار بعد صلاة العصر",
            shortTitle: "بعد الصلاة",
            hint: "تسبيح وتحميد وتكبير وآية الكرسي",
            symbol: "hands.sparkles.fill",
            route: "/after-prayer",
            endsAt: now.addingTimeInterval(30 * 60),
            endsSlot: nil
        )
        return AdhkarNowEntry(
            date: now,
            now: AdhkarNow(primary: after, secondary: evening),
            status: .ok
        )
    }
}

// MARK: - الودجت

struct AdhkarNowWidget: Widget {
    let kind = "RuqyahAdhkarNowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AdhkarNowProvider()) { entry in
            AdhkarNowWidgetView(entry: entry)
        }
        .configurationDisplayName("أذكار الآن")
        .description("الذكر المناسب لوقتك: بعد الصلاة، الصباح، المساء، النوم، وسورة الكهف يوم الجمعة.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

struct AdhkarNowWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AdhkarNowEntry

    private var url: URL? {
        if let info = entry.now?.primary {
            return info.url
        }
        return URL(string: "ruqyah://open/prayer-times")
    }

    var body: some View {
        content
            .environment(\.layoutDirection, .rightToLeft)
            .environment(\.locale, Locale(identifier: "ar_SA"))
            .widgetURL(url)
            .widgetBackgroundFor(family)
    }

    @ViewBuilder
    private var content: some View {
        if let now = entry.now {
            switch family {
            case .systemMedium:
                AdhkarMediumView(now: now)
            case .accessoryCircular:
                AdhkarLockCircular(info: now.primary)
            case .accessoryRectangular:
                AdhkarLockRectangular(info: now.primary)
            case .accessoryInline:
                AdhkarLockInline(info: now.primary)
            default:
                AdhkarSmallView(info: now.primary)
            }
        } else {
            AdhkarEmptyView(status: entry.status, family: family)
        }
    }
}

// MARK: - مكوّنات مشتركة

/// «حتى العشاء ٧:١٥ م» — أو «حتى ٦:٠٠ م» حين لا صلاة تحدّ النهاية.
struct AdhkarEndLine: View {
    let info: AdhkarNowInfo
    var size: CGFloat = 11

    var body: some View {
        if let end = info.endsAt, let label = info.endLabel {
            (Text(verbatim: label + " ") + Text(end, style: .time))
                .font(WTheme.font(size))
                .foregroundColor(WTheme.cream.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        } else if let end = info.endsAt {
            (Text(verbatim: "حتى ") + Text(end, style: .time))
                .font(WTheme.font(size))
                .foregroundColor(WTheme.cream.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

struct AdhkarIconBadge: View {
    let symbol: String
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.14))
            Image(systemName: symbol)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(WTheme.goldSoft)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - صغير

struct AdhkarSmallView: View {
    let info: AdhkarNowInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AdhkarIconBadge(symbol: info.symbol, size: 38)
            Spacer(minLength: 0)
            Text(verbatim: info.title)
                .font(WTheme.font(17, .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            AdhkarEndLine(info: info)
            Text(verbatim: "اضغط لتقرأها")
                .font(WTheme.font(10.5))
                .foregroundColor(WTheme.goldSoft)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - متوسط

struct AdhkarMediumView: View {
    let now: AdhkarNow

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            AdhkarIconBadge(symbol: now.primary.symbol, size: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: now.primary.title)
                    .font(WTheme.font(19, .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                Text(verbatim: now.primary.hint)
                    .font(WTheme.font(12))
                    .foregroundColor(WTheme.cream.opacity(0.9))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                AdhkarEndLine(info: now.primary, size: 11.5)
                if let second = now.secondary {
                    Spacer(minLength: 2)
                    HStack(spacing: 6) {
                        Image(systemName: second.symbol)
                            .font(.system(size: 12, weight: .semibold))
                        Text(verbatim: "وأيضاً: " + second.title)
                            .font(WTheme.font(11.5, .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundColor(WTheme.goldSoft)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - شاشة القفل

struct AdhkarLockCircular: View {
    let info: AdhkarNowInfo

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: info.symbol)
                    .font(.system(size: 17, weight: .semibold))
                Text(verbatim: info.shortTitle)
                    .font(WTheme.font(10, .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, 6)
        }
    }
}

struct AdhkarLockRectangular: View {
    let info: AdhkarNowInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 5) {
                Image(systemName: info.symbol)
                    .font(.system(size: 12, weight: .semibold))
                Text(verbatim: info.title)
                    .font(WTheme.font(14, .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            if let end = info.endsAt {
                if let label = info.endLabel {
                    (Text(verbatim: label + " ") + Text(end, style: .time))
                        .font(WTheme.font(12))
                } else {
                    (Text(verbatim: "حتى ") + Text(end, style: .time))
                        .font(WTheme.font(12))
                }
            }
            Text(verbatim: info.hint)
                .font(WTheme.font(10.5))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

struct AdhkarLockInline: View {
    let info: AdhkarNowInfo

    var body: some View {
        Text(verbatim: info.title)
    }
}

// MARK: - حالات بلا بيانات

struct AdhkarEmptyView: View {
    let status: AdhkarNowEntry.Status
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
