import SwiftUI
import WidgetKit

// MARK: - Timeline

struct WirdEntry: TimelineEntry {
    let date: Date
    let state: WirdState
    /// نسبة الختمة كلها (0...1).
    let overall: Double
}

struct WirdProvider: TimelineProvider {
    func placeholder(in context: Context) -> WirdEntry {
        return WirdSample.entry()
    }

    func getSnapshot(in context: Context, completion: @escaping (WirdEntry) -> Void) {
        if context.isPreview {
            completion(WirdSample.entry())
            return
        }
        completion(makeEntry(snapshot: SnapshotLoader.load(), at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WirdEntry>) -> Void) {
        let now = Date()
        let snapshot = SnapshotLoader.load()
        var entries = [makeEntry(snapshot: snapshot, at: now)]

        // بعد منتصف الليل يصير ورد اليوم قديماً حتى يُفتح التطبيق: مدخل ثانٍ يبدّل الحالة.
        let cal = Calendar.current
        if let startOfTomorrow = cal.date(
            byAdding: .day, value: 1, to: cal.startOfDay(for: now)
        ) {
            let flip = startOfTomorrow.addingTimeInterval(5)
            entries.append(makeEntry(snapshot: snapshot, at: flip))
            completion(Timeline(entries: entries, policy: .after(flip.addingTimeInterval(3600))))
        } else {
            completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600))))
        }
    }

    private func makeEntry(snapshot: WidgetSnapshot?, at date: Date) -> WirdEntry {
        let state = WirdState.resolve(snapshot: snapshot, at: date)
        let overall = snapshot?.wird?.prog ?? 0
        return WirdEntry(date: date, state: state, overall: overall)
    }
}

enum WirdSample {
    static func entry() -> WirdEntry {
        let info = WirdInfo(
            on: true,
            day: dayKey(Date()),
            page: 123,
            start: 120,
            end: 127,
            target: 8,
            read: 3,
            done: false,
            prog: 0.2,
            left: 24,
            fin: 0
        )
        return WirdEntry(date: Date(), state: .active(info), overall: 0.2)
    }
}

// MARK: - الودجت

struct WirdWidget: Widget {
    let kind = "RuqyahWirdWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WirdProvider()) { entry in
            WirdWidgetView(entry: entry)
        }
        .configurationDisplayName("وردي اليوم")
        .description("ورد اليوم من القرآن وتقدّم ختمتك؛ اضغط لتكمل من حيث وقفت.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}

struct WirdWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WirdEntry

    private var url: URL? {
        switch entry.state {
        case .active(let w), .stale(let w):
            let page = min(max(w.page, 1), 604)
            return URL(string: "ruqyah://open/mushaf/page/\(page)")
        default:
            return URL(string: "ruqyah://open/khatma")
        }
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
        switch family {
        case .systemMedium:
            WirdMediumView(entry: entry)
        case .accessoryCircular:
            WirdLockCircular(entry: entry)
        case .accessoryRectangular:
            WirdLockRectangular(entry: entry)
        default:
            WirdSmallView(entry: entry)
        }
    }
}

// MARK: - مساعدات العرض

extension WirdInfo {
    /// نسبة ورد اليوم (0...1).
    var todayFraction: Double {
        if done { return 1 }
        if target <= 0 { return 0 }
        return min(max(Double(read) / Double(target), 0), 1)
    }

    var remainingToday: Int {
        return max(target - read, 0)
    }
}

func percentText(_ fraction: Double) -> String {
    let n = Int((min(max(fraction, 0), 1) * 100).rounded())
    return ar(n) + "٪"
}

// MARK: - صغير

struct WirdSmallView: View {
    let entry: WirdEntry

    var body: some View {
        switch entry.state {
        case .active(let w):
            if w.done {
                WirdCenterMessage(
                    symbol: "checkmark.circle.fill",
                    title: "أتممتَ ورد اليوم",
                    subtitle: "الختمة " + percentText(w.prog)
                )
            } else {
                activeView(w)
            }
        case .stale(let w):
            VStack(spacing: 4) {
                ZStack {
                    RingView(progress: w.prog, lineWidth: 7)
                    Text(verbatim: percentText(w.prog))
                        .font(WTheme.font(18, .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text(verbatim: "وردك الجديد بانتظارك")
                    .font(WTheme.font(11, .medium))
                    .foregroundColor(WTheme.goldSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        case .finished:
            WirdCenterMessage(
                symbol: "star.circle.fill",
                title: "ختمتَ القرآن",
                subtitle: "تقبّل الله منك"
            )
        case .inactive:
            WirdCenterMessage(
                symbol: "book.closed.fill",
                title: "ابدأ ختمة القرآن",
                subtitle: "اضغط للبدء"
            )
        }
    }

    private func activeView(_ w: WirdInfo) -> some View {
        VStack(spacing: 3) {
            Text(verbatim: "وردك اليوم")
                .font(WTheme.font(12, .medium))
                .foregroundColor(WTheme.goldSoft)
            ZStack {
                RingView(progress: w.todayFraction, lineWidth: 7)
                VStack(spacing: 0) {
                    Text(verbatim: ar(w.read) + "/" + ar(w.target))
                        .font(WTheme.font(22, .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(verbatim: "صفحات")
                        .font(WTheme.font(10))
                        .foregroundColor(WTheme.cream.opacity(0.85))
                }
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(verbatim: "الصفحة " + ar(w.page))
                .font(WTheme.font(11))
                .foregroundColor(WTheme.cream.opacity(0.9))
        }
    }
}

/// أيقونة + عنوان + سطر ثانوي (الحالات الفارغة والمكتملة).
struct WirdCenterMessage: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 34))
                .foregroundColor(WTheme.goldSoft)
            Text(verbatim: title)
                .font(WTheme.font(15, .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(verbatim: subtitle)
                .font(WTheme.font(11))
                .foregroundColor(WTheme.cream.opacity(0.85))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - متوسط

struct WirdMediumView: View {
    let entry: WirdEntry

    var body: some View {
        switch entry.state {
        case .active(let w):
            if w.done {
                WirdCenterMessage(
                    symbol: "checkmark.circle.fill",
                    title: "أتممتَ ورد اليوم",
                    subtitle: "الختمة " + percentText(w.prog)
                        + " · باقي " + daysText(w.left)
                )
            } else {
                activeView(w)
            }
        case .stale(let w):
            WirdCenterMessage(
                symbol: "sun.max.fill",
                title: "وردك الجديد بانتظارك",
                subtitle: "افتح التطبيق · الختمة " + percentText(w.prog)
            )
        case .finished:
            WirdCenterMessage(
                symbol: "star.circle.fill",
                title: "ختمتَ القرآن — تقبّل الله منك",
                subtitle: "اضغط لبدء ختمة جديدة"
            )
        case .inactive:
            WirdCenterMessage(
                symbol: "book.closed.fill",
                title: "ابدأ ختمة القرآن",
                subtitle: "ورد يومي يتقدّم بقراءتك في المصحف"
            )
        }
    }

    private func activeView(_ w: WirdInfo) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RingView(progress: w.todayFraction, lineWidth: 8)
                VStack(spacing: 0) {
                    Text(verbatim: ar(w.read) + "/" + ar(w.target))
                        .font(WTheme.font(22, .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(verbatim: "صفحات")
                        .font(WTheme.font(10))
                        .foregroundColor(WTheme.cream.opacity(0.85))
                }
                .padding(.horizontal, 12)
            }
            .aspectRatio(1, contentMode: .fit)

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: "وردك اليوم")
                    .font(WTheme.font(16, .bold))
                    .foregroundColor(WTheme.goldSoft)
                Text(verbatim: "من صفحة " + ar(w.start) + " إلى " + ar(w.end))
                    .font(WTheme.font(12, .medium))
                    .foregroundColor(.white)
                Text(verbatim: "المتبقي " + pagesText(w.remainingToday) + " · تابع من صفحة " + ar(w.page))
                    .font(WTheme.font(11))
                    .foregroundColor(WTheme.cream.opacity(0.9))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 2)
                ProgressView(value: min(max(w.prog, 0), 1))
                    .progressViewStyle(.linear)
                    .tint(WTheme.gold)
                Text(verbatim: "الختمة " + percentText(w.prog) + " · باقي " + daysText(w.left))
                    .font(WTheme.font(10.5))
                    .foregroundColor(WTheme.cream.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - شاشة القفل

struct WirdLockCircular: View {
    let entry: WirdEntry

    private var fraction: Double {
        switch entry.state {
        case .active(let w): return w.todayFraction
        case .stale(let w): return w.prog
        case .finished: return 1
        case .inactive: return 0
        }
    }

    private var label: String {
        switch entry.state {
        case .active(let w): return w.done ? "✓" : ar(w.read) + "/" + ar(w.target)
        case .stale: return "جديد"
        case .finished: return "✓"
        case .inactive: return "ختمة"
        }
    }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .trim(from: 0, to: CGFloat(max(fraction, 0.03)))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)
            Text(verbatim: label)
                .font(WTheme.font(14, .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal, 8)
        }
    }
}

struct WirdLockRectangular: View {
    let entry: WirdEntry

    var body: some View {
        switch entry.state {
        case .active(let w):
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(verbatim: "وردك اليوم")
                        .font(WTheme.font(14, .bold))
                    Spacer(minLength: 4)
                    Text(verbatim: w.done ? "تمّ" : ar(w.read) + " من " + ar(w.target))
                        .font(WTheme.font(13, .medium))
                }
                ProgressView(value: w.todayFraction)
                    .progressViewStyle(.linear)
                Text(verbatim: "الصفحة " + ar(w.page) + " · الختمة " + percentText(w.prog))
                    .font(WTheme.font(10.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        case .stale:
            Text(verbatim: "وردك الجديد بانتظارك — افتح التطبيق")
                .font(WTheme.font(13, .medium))
        case .finished:
            Text(verbatim: "ختمتَ القرآن — تقبّل الله منك")
                .font(WTheme.font(13, .medium))
        case .inactive:
            Text(verbatim: "ابدأ ختمة القرآن من التطبيق")
                .font(WTheme.font(13, .medium))
        }
    }
}
