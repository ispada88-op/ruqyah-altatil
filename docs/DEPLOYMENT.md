# دليل النشر — Roqia Al-Tatil

نشر التطبيق على **iOS (App Store)** و **Google Play** و **Windows**.

---

## 1. iOS — App Store عبر Codemagic

### المتطلبات
- اشتراك Apple Developer ($99/سنة)
- حساب Codemagic (مجاني 500 دقيقة/شهر)
- إنشاء سجل التطبيق في App Store Connect يدوياً (الإصدار الأول)

### الخطوات

1. **ربط المستودع في Codemagic**
   - ادخل إلى [codemagic.io](https://codemagic.io) وربط مستودع GitHub/GitLab
   - اختر الفرع `main` للمتابعة

2. **إعداد توقيع iOS**
   - في Codemagic: **Team settings** → **Code signing identities** → **iOS**
   - اربط حساب Apple Developer
   - أو أنشئ مفتاح App Store Connect API:
     - [App Store Connect](https://appstoreconnect.apple.com/access/integrations/api) → Users and Access → App Store Connect API
     - أنشئ مفتاحاً جديداً بصلاحية App Manager
     - حمّل المفتاح الخاص (مرة واحدة فقط) واحفظه

3. **تفعيل النشر في codemagic.yaml**
   - أزل التعليق عن قسم `publishing` في workflow `ios-app-store`
   - أضف المتغيرات في Codemagic: `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`
   - ارفع المفتاح الخاص في إعدادات التكامل

4. **البناء**
   - أي push إلى `main` يشغّل البناء
   - المخرجات: `build/ios/ipa/*.ipa` (للرفع إلى TestFlight أو App Store)

---

## 2. Android — Google Play

### المتطلبات
- حساب مطور Google Play ($25 مرة واحدة)
- حساب Codemagic
- **ملاحظة:** الحسابات الشخصية الجديدة تحتاج 14 يوم اختبار مغلق مع 12 مختبراً قبل الإنتاج

### الخطوات

1. **إنشاء Keystore (للمرة الأولى)**
   ```bash
   keytool -genkey -v -keystore roqia.keystore -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias roqia
   ```

2. **رفع Keystore في Codemagic**
   - Team settings → Code signing identities → Android keystores
   - ارفع الملف وسمّه `android_keystore`
   - أدخل: Key alias, Key password, Keystore password

3. **البناء**
   - أي push إلى `main` يشغّل workflow `android-google-play`
   - المخرجات: `build/app/outputs/bundle/release/*.aab`
   - Google Play يقبل ملف AAB فقط (وليس APK)

4. **تفعيل النشر التلقائي**
   - أزل التعليق عن قسم `publishing` في workflow `android-google-play`
   - اربط حساب Google Play في Codemagic (Service account JSON)

---

## 3. Windows — نسخة سطح المكتب

### البناء المحلي

```bash
flutter pub get
flutter build windows --release
```

المخرجات في: `build/windows/x64/runner/Release/`

### التوزيع
- انسخ مجلد `Release` كاملاً (يحتوي على `.exe` والـ DLLs)
- أو استخدم [msix](https://pub.dev/packages/msix) لتغليف MSIX للنشر في Microsoft Store:

```yaml
# في pubspec.yaml
dev_dependencies:
  msix: ^3.0.0
```

```bash
flutter pub run msix:create
```

### Microsoft Store
- سجّل التطبيق في [Partner Center](https://partner.microsoft.com/dashboard)
- الإصدار الأول يُرفع يدوياً
- يمكن أتمتة الإصدارات التالية عبر Codemagic (يتطلب إعداد Azure AD)

---

## ملخص الأوامر

| المنصة   | الأمر                          | المخرجات                    |
|----------|---------------------------------|-----------------------------|
| iOS      | `flutter build ipa --release`   | `build/ios/ipa/*.ipa`        |
| Android  | `flutter build appbundle --release` | `build/app/outputs/bundle/release/*.aab` |
| Windows  | `flutter build windows --release`   | `build/windows/x64/runner/Release/` |

---

## مراجع

- [Codemagic Flutter Docs](https://docs.codemagic.io/flutter-publishing/)
- [Flutter Deployment](https://docs.flutter.dev/deployment)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Google Play Console](https://play.google.com/console)
- [Microsoft Partner Center](https://partner.microsoft.com/dashboard)
