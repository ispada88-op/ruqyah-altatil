# 📋 دليل رفع الآيفون — رقية التعطيل

## 📦 طريقة البناء
 عبر Codemagic (تلقائي) أو Xcode (يدوي)

---

## 🍎 الطريقة 1: عبر Codemagic (الموصى بها)

### 1. افتح Codemagic
https://codemagic.io

### 2. ربط المستودع
- **Sign in with GitHub**
- اختر المستودع: `ispada88-op/ruqyah-altatil`
- **Build configuration**: اختر `codemagic.yaml`

### 3. إضافة مفاتيح التوقيع (مرة واحدة فقط)

#### أ) شهادة Apple:
1. افتح Mac → **Keychain Access**
2. صدّر شهادة التوزيع كـ `.p12`
3. على Codemagic: **Teams** → **Code signing identities** → **iOS certificates**
4. ارفع ملف `.p12` مع كلمة المرور

#### ب) Provisioning Profile:
1. من Apple Developer: https://developer.apple.com
2. **Certificates, Identifiers & Profiles** → **Profiles**
3. حمّل App Store Distribution Profile
4. على Codemagic: ارفعه في **Provisioning profiles**

#### ج) App Store Connect API Key:
1. من App Store Connect: **Users and Access** → **Integrations**
2. أنشئ API Key بصلاحية **Admin**
3. حمّل ملف `.p8`
4. سجّل: **Issuer ID**, **Key ID**
5. على Codemagic أضف متغيرات البيئة:

| المتغير | القيمة |
|---------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | من App Store Connect |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | محتوى ملف .p8 |

### 4. تشغيل البناء
- اختر workflow: `ios-release`
- اضغط **Start new build**
- انتظر 15-20 دقيقة
- الـ IPA يُرفع تلقائياً لـ **TestFlight**

### 5. من TestFlight للنشر
1. افتح App Store Connect
2. **TestFlight** → اختر البناء
3. **Add build to review**
4. أضف **What's New**:

```
الإصدار 1.0.0:

• إضافة صفحة ترحيب للمستخدمين الجدد
• تحسين أداء تشغيل الصوت
• إضافة ميزة إبقاء الشاشة مضاءة أثناء التشغيل
• تحسينات في التصميم والواجهة
• إصلاح أخطاء في عرض الآيات
```

5. **Submit for Review**

---

## 🍎 الطريقة 2: يدوي عبر Xcode (لو عندك Mac)

### 1. نقل المشروع للـ Mac
```bash
git clone https://github.com/ispada88-op/ruqyah-altatil.git
cd ruqyah-altatil
flutter pub get
```

### 2. فتح Xcode
```bash
open ios/Runner.xcworkspace
```

### 3. تحقق من الإعدادات
| الإعداد | القيمة |
|---------|--------|
| Bundle Identifier | `com.ruqyah.altatil` |
| Version | `1.0.0` |
| Build | `2` |
| Minimum iOS | `12.0` |
| Deployment Target | iOS 15.0+ |

### 4. بناء وأرشفة
```bash
flutter build ios --release
```

في Xcode:
- **Product** → **Archive**
- **Distribute App** → **App Store Connect**
- **Upload** → التالي حتى النهاية

---

## ✅ Checklist iOS

- [x] الكود مرفوع على GitHub ✅
- [x] codemagic.yaml جاهز ✅
- [x] Bundle ID: `com.ruqyah.altatil` ✅
- [x] Version: `1.0.0+2` ✅
- [ ] شهادة Apple مرفوعة على Codemagic
- [ ] Provisioning Profile مرفوع
- [ ] App Store Connect API Key
- [ ] تشغيل البناء
- [ ] What's New محدّث
- [ ] لقطات شاشة iOS

### لقطات الشاشة المطلوبة (iOS):

| الجهاز | الحجم |
|--------|-------|
| iPhone 6.7" | 1290×2796 |
| iPhone 6.5" | 1284×2778 |
| iPad 12.9" | 2048×2732 |

---

## 📞 للتواصل
المطور: kajoker88
البريد: kajoker88@gmail.com
