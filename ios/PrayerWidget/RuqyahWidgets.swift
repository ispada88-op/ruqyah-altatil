import SwiftUI
import WidgetKit

/// حزمة ودجتات «الرقية الشاملة».
@main
struct RuqyahWidgets: WidgetBundle {
    var body: some Widget {
        PrayerWidget()
        AdhkarNowWidget()
        WirdWidget()
        ProgramWidget()
    }
}
