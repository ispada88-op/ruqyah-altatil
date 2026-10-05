import SwiftUI
import WidgetKit

// MARK: - Timeline

struct ProgramEntry: TimelineEntry {
    let date: Date
    let state: ProgramState
}

struct ProgramProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgramEntry {
        return ProgramSample.entry()
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgramEntry) -> Void) {
        if context.isPreview {
            completion(ProgramSample.entry())
            return
        }
        completion(makeEntry(snapshot: SnapshotLoader.load(), at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgramEntry>) -> Void) {
        let now = Date()
        let snapshot = SnapshotLoader.load()
        var entries = [makeEntry(snapshot: snapshot, at: now)]

        // بعد منتصف الليل تبدأ بنود يوم جديد فارغة: مدخل ثانٍ يبدّل الحالة.
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

    private func makeEntry(snapshot: WidgetSnapshot?, at date: Date) -> ProgramEntry {
        return ProgramEntry(date: date, state: ProgramState.resolve(snapshot: snapshot, at: date))
    }
}

enum ProgramSample {
    static func entry() -> ProgramEntry {
        let today = ProgramToday(
            done: [.morning, .wird],
            streak: 6,
            goal: 21,
            isNewDay: false
        )
        return ProgramEntry(date: Date(), state: .today(today))
    }
}

// MARK: - الودجت

struct ProgramWidget: Widget {
    let kind = "RuqyahProgramWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgramProvider()) { entry in
            ProgramWidgetView(entry: entry)
        }
        .configurationDisplayName("المداومة")
        .description("ما أنجزتَه اليوم من برنامج المداومة وسلسلة أيامك.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}

struct ProgramWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ProgramEntry

    var body: some View {
        content
            .environment(\.layoutDirection, .rightToLeft)
            .environment(\.locale, Locale(identifier: "ar_SA"))
            .widgetURL(URL(string: "ruqyah://open/program"))
            .widgetBackgroundFor(family)
    }

    @ViewBuilder
    private var content: some View {
        switch entry.state {
        case .unknown:
            ProgramUnknownView(family: family)
        case .today(let t):
            switch family {
            case .systemMedium:
                ProgramMediumView(today: t)
            case .accessoryCircular:
                ProgramLockCircular(today: t)
            case .accessoryRectangular:
                ProgramLockRectangular(today: t)
            default:
                ProgramSmallView(today: t)
            }
        }
    }
}

// MARK: - نصوص

extension ProgramToday {
    /// «سلسلتك ٧ أيام» أو دعوة لبدء السلسلة.
    var streakText: String {
        if streak <= 0 { return "ابدأ سلسلتك اليوم" }
        return "سلسلتك " + daysText(streak)
    }

    /// «الهدف ٢١ يوماً» — يُعرض مع السلسلة حين تكون الأرقام مفيدة.
    var goalText: String {
        return "الهدف " + daysText(goal)
    }
}

// MARK: - صغير

struct ProgramSmallView: View {
    let today: ProgramToday

    var body: some View {
        VStack(spacing: 4) {
            Text(verbatim: "المداومة")
                .font(WTheme.font(12, .medium))
                .foregroundColor(WTheme.goldSoft)
            ZStack {
                RingView(progress: today.fraction, lineWidth: 7)
                if today.isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    VStack(spacing: 0) {
                        Text(verbatim: ar(today.count) + "/" + ar(today.total))
                            .font(WTheme.font(22, .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(verbatim: "اليوم")
                            .font(WTheme.font(10))
                            .foregroundColor(WTheme.cream.opacity(0.85))
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                Text(verbatim: today.isComplete ? "اكتمل يومك" : today.streakText)
                    .font(WTheme.font(11, .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(WTheme.goldSoft)
        }
    }
}

// MARK: - متوسط

struct ProgramChip: View {
    let slot: ProgramSlot
    let done: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(done ? WTheme.gold : Color.white.opacity(0.12))
                Image(systemName: done ? "checkmark" : slot.symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(done ? WTheme.tealDark : WTheme.cream.opacity(0.75))
            }
            .frame(width: 38, height: 38)
            Text(verbatim: slot.label)
                .font(WTheme.font(11, done ? .bold : .regular))
                .foregroundColor(done ? .white : WTheme.cream.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProgramMediumView: View {
    let today: ProgramToday

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verbatim: "المداومة اليوم")
                    .font(WTheme.font(16, .bold))
                    .foregroundColor(WTheme.goldSoft)
                Spacer(minLength: 4)
                Text(verbatim: today.isComplete ? "اكتمل يومك ✓" : ar(today.count) + " من " + ar(today.total))
                    .font(WTheme.font(13, .medium))
                    .foregroundColor(.white)
            }
            HStack(spacing: 4) {
                ForEach(ProgramSlot.allCases, id: \.rawValue) { slot in
                    ProgramChip(slot: slot, done: today.done.contains(slot))
                }
            }
            Spacer(minLength: 0)
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                Text(verbatim: today.streakText + " · " + today.goalText)
                    .font(WTheme.font(11.5, .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(WTheme.cream.opacity(0.9))
        }
    }
}

// MARK: - شاشة القفل

struct ProgramLockCircular: View {
    let today: ProgramToday

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .trim(from: 0, to: CGFloat(max(today.fraction, 0.03)))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)
            Text(verbatim: today.isComplete ? "✓" : ar(today.count) + "/" + ar(today.total))
                .font(WTheme.font(14, .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal, 8)
        }
    }
}

struct ProgramLockRectangular: View {
    let today: ProgramToday

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(verbatim: "المداومة")
                    .font(WTheme.font(14, .bold))
                Spacer(minLength: 4)
                Text(verbatim: today.isComplete ? "اكتمل" : ar(today.count) + " من " + ar(today.total))
                    .font(WTheme.font(13, .medium))
            }
            ProgressView(value: today.fraction)
                .progressViewStyle(.linear)
            Text(verbatim: today.streakText)
                .font(WTheme.font(10.5))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

// MARK: - بلا بيانات

struct ProgramUnknownView: View {
    let family: WidgetFamily

    private let message = "افتح التطبيق لتفعيل المداومة"

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "checklist")
            }
        case .accessoryRectangular, .accessoryInline:
            Text(verbatim: message)
                .font(WTheme.font(13, .medium))
        default:
            VStack(spacing: 8) {
                Image(systemName: "checklist")
                    .font(.system(size: 28))
                    .foregroundColor(WTheme.goldSoft)
                Text(verbatim: message)
                    .font(WTheme.font(13, .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
        }
    }
}
