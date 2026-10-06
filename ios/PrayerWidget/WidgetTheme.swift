import SwiftUI
import WidgetKit

/// ألوان وخطوط الودجت — نفس هوية التطبيق (تيل + ذهبي + كريمي).
enum WTheme {
    static let teal = Color(red: 0.0, green: 0.42, blue: 0.42)          // #006B6B
    static let tealDark = Color(red: 0.0, green: 0.294, blue: 0.294)    // #004B4B
    static let gold = Color(red: 0.831, green: 0.686, blue: 0.216)      // #D4AF37
    static let goldSoft = Color(red: 0.898, green: 0.757, blue: 0.345)  // #E5C158
    static let cream = Color(red: 0.961, green: 0.961, blue: 0.863)     // #F5F5DC

    /// Tajawal مضمّن مع الإضافة (UIAppFonts)؛ إن لم يُحمَّل يرجع النظام لخطه.
    static func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if weight == .bold || weight == .semibold || weight == .heavy {
            return Font.custom("Tajawal-Bold", fixedSize: size)
        }
        if weight == .medium {
            return Font.custom("Tajawal-Medium", fixedSize: size)
        }
        return Font.custom("Tajawal-Regular", fixedSize: size)
    }
}

struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [WTheme.teal, WTheme.tealDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension WidgetFamily {
    var isAccessory: Bool {
        switch self {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return true
        default:
            return false
        }
    }
}

extension View {
    /// خلفية الودجت: iOS 17+ تتطلب containerBackground، وiOS 16 تحتاج حشوة يدوية.
    @ViewBuilder
    func widgetBackgroundFor(_ family: WidgetFamily) -> some View {
        if #available(iOS 17.0, *) {
            if family.isAccessory {
                self.containerBackground(for: .widget) { Color.clear }
            } else {
                self.containerBackground(for: .widget) { WidgetBackground() }
            }
        } else {
            if family.isAccessory {
                self
            } else {
                self.padding(12).background(WidgetBackground())
            }
        }
    }
}

/// حلقة تقدّم دائرية (تبدأ من الأعلى مع عقارب الساعة).
struct RingView: View {
    let progress: Double
    let lineWidth: CGFloat
    var track: Color = Color.white.opacity(0.18)
    var tint: Color = WTheme.gold

    var body: some View {
        let p = min(max(progress, 0.0), 1.0)
        ZStack {
            Circle().stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(max(p, 0.004)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
