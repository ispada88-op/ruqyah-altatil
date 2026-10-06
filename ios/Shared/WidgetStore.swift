import Foundation
import Security

/// جسر البيانات بين التطبيق والودجت.
///
/// التطبيق (Flutter) يكتب لقطة JSON واحدة صغيرة، والودجت يقرؤها فقط. نستعمل
/// Keychain Sharing بدل App Groups: المجموعة `$(AppIdentifierPrefix)com.ruqyah.altatil.shared`
/// مشمولة بملف التوقيع الافتراضي (`TEAMID.*`) فلا تحتاج تسجيلاً في حساب المطوّر.
///
/// لا نمرّر kSecAttrAccessGroup عمداً: الإضافة تذهب لأول مجموعة في
/// `keychain-access-groups` (وهي المشتركة عند الطرفين)، والبحث يغطي كل مجموعات
/// الهدف — فلا نحتاج معرفة رقم الفريق وقت التشغيل.
///
/// الملف مضمَّن في هدفين: Runner (كتابة) وPrayerWidget (قراءة).
enum WidgetStore {
    private static let service = "com.ruqyah.altatil.widget"
    private static let account = "snapshot.v1"

    private static func baseQuery() -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    /// يحفظ اللقطة (إنشاء أو تحديث). يعيد true عند النجاح.
    @discardableResult
    static func write(_ data: Data) -> Bool {
        let update: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        let status = SecItemUpdate(baseQuery() as CFDictionary, update as CFDictionary)
        if status == errSecSuccess { return true }
        if status == errSecItemNotFound {
            var add = baseQuery()
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
        }
        return false
    }

    /// آخر لقطة محفوظة أو nil.
    static func read() -> Data? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
}
