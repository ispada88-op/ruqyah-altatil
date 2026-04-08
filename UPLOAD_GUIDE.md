# Upload Guide — Ruqyah Altatil

## 📦 Files Ready for Upload

| Platform | File | Size | Path |
|----------|------|------|------|
| Android | `app-release.apk` | ~184 MB | `build\app\outputs\flutter-apk\app-release.apk` |
| iOS | Build via Xcode | — | See iOS section below |

---

## 🤖 Google Play Store Upload

### Step 1: Prepare Store Listing
Go to: https://play.google.com/console

**App Details:**
- **App name**: رقية التعطيل — الشيخ فهد القرني
- **Package name**: `com.ruqyah.altatil`
- **Category**: Lifestyle / Religion
- **Content rating**: Everyone (3+)

**Short description (80 chars max):**
```
رقية التعطيل والسحر بصوت الشيخ ماهر المعيقلي والشيخ سعد الغامدي
```

**Full description:**
```
تطبيق رقية التعطيل والسحر — الشيخ فهد القرني

🎙️ الرقية الصوتية:
استمع إلى الرقية الشرعية بأصوات أفاضل المشايخ:
• الشيخ ماهر المعيقلي
• الشيخ سعد الغامدي

📖 الرقية المكتوبة:
اقرأ آيات الرقية بخط عثماني واضح مطابق لمصحف المدينة المنورة:
• سورة الفاتحة
• سورة البقرة (الآيات 1-5، آية الكرسي، خواتيم البقرة)
• سورة الأنفال
• سورة الدخان
• سورة الصافات
• سورة الحاقة
• سورة الزلزلة
• سورة الكافرون
• سورة الإخلاص
• سورة الفلق
• سورة الناس
• سورة القارعة

🤲 الأذكار:
عداد تسبيح ذكي مع أدعية الرقية المأثورة:
• سبحان الله
• الحمد لله
• الله أكبر
• لا إله إلا الله
• اللهم صل على محمد

✨ المميزات:
• وضع ليلي / نهاري
• التحكم بحجم الخط
• نسخ الآيات والأدعية
• طريقة تطبيق الرقية
• طريقة التحريج على النفس

ملاحظة: هذا التطبيق لا يغني عن زيارة الطبيب المختص.
```

### Step 2: Upload APK
1. Go to **Production** → **Create new release**
2. Upload `app-release.apk`
3. Release name: `1.0.0 (2)`
4. Release notes (Arabic):
```
الإصدار الأول من تطبيق رقية التعطيل
• تشغيل الرقية الصوتية
• قراءة الآيات المكتوبة
• عداد التسبيح والأذكار
```

### Step 3: Screenshots Required
- **Phone**: Minimum 2, Maximum 8 (16:9 or 9:16)
- **Tablet (7-inch)**: Minimum 2, Maximum 8
- **Tablet (10-inch)**: Minimum 2, Maximum 8

Take screenshots of:
1. الشاشة الرئيسية
2. صفحة الرقية الصوتية (أثناء التشغيل)
3. صفحة الرقية المكتوبة
4. صفحة الأذكار
5. الوضع الليلي

### Step 4: Content Rating
Answer the IARC questionnaire:
- Contains religious content: Yes
- Violence: No
- User-generated content: No
- In-app purchases: No

### Step 5: Data Privacy
- App collects: No personal data
- App uses: Audio playback, Local storage (for preferences)

---

## 🍎 Apple App Store Upload (iOS Update)

### Step 1: Build for iOS
```bash
cd C:\Users\khale\ruqyah-altatil
flutter build ios --release
```
**Note**: Must be done on macOS with Xcode installed.

### Step 2: Open Xcode
```bash
open ios/Runner.xcworkspace
```

### Step 3: Verify Settings
- **Bundle Identifier**: `com.ruqyah.altatil` (must match existing)
- **Version**: `1.0.0`
- **Build**: `2`
- **Minimum iOS**: `12.0`
- **Deployment Target**: iOS 15.0+

### Step 4: Archive & Upload
1. In Xcode: **Product** → **Archive**
2. Wait for archive to complete
3. **Distribute App** → **App Store Connect**
4. **Upload** → follow prompts
5. Submit for review

### Step 5: App Store Connect
Go to: https://appstoreconnect.apple.com

**What's New (Arabic):**
```
الإصدار 1.0.0:

• إضافة صفحة ترحيب للمستخدمين الجدد
• تحسين أداء تشغيل الصوت
• إضافة ميزة إبقاء الشاشة مضاءة أثناء التشغيل
• تحسينات في التصميم والواجهة
• إصلاح أخطاء في عرض الآيات
```

**What's New (English):**
```
Version 1.0.0:

• Added onboarding screens for new users
• Improved audio playback performance
• Added screen wake lock during playback
• UI/UX improvements
• Fixed verse display issues
```

### Step 6: Screenshots Required (iOS)
- **iPhone 6.7"** (iPhone 14 Pro Max / 15 Pro Max)
- **iPhone 6.5"** (iPhone 11 Pro Max / XS Max)
- **iPad 12.9"** (if supporting iPad)
- **iPad 11"** (if supporting iPad)

---

## ⚠️ Pre-Upload Checklist

- [x] `flutter analyze` → No issues found
- [x] `flutter build apk --release` → Success (183.8 MB)
- [x] Version: `1.0.0+2`
- [x] minSdkVersion: 23
- [x] Package: `com.ruqyah.altatil`
- [x] No debug prints in release mode
- [x] No hardcoded API keys
- [x] ProGuard/R8 enabled
- [ ] Screenshots taken
- [ ] Store listing prepared
- [ ] Content rating completed
- [ ] Privacy policy URL provided

---

## 📋 Privacy Policy Template

Create a simple privacy policy page (required by both stores):

```
سياسة الخصوصية — تطبيق رقية التعطيل

لا يجمع هذا التطبيق أي بيانات شخصية من المستخدمين.

• لا يجمع معلومات الهاتف
• لا يتطلب إنشاء حساب
• لا يشارك أي بيانات مع أطراف ثالثة
• يخزن تفضيلات المستخدم (الوضع الليلي، عدد التسبيح) محلياً فقط

للتواصل: [YOUR EMAIL]
```
