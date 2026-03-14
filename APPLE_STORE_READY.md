# جاهزية تطبيق رقية التعطيل لـ App Store

## ما تم إنجازه تلقائياً

### 1. Info.plist
- **ITSAppUsesNonExemptEncryption** = `false` (امتثال التصدير)
- **CFBundleDisplayName** و **CFBundleName** مضبوطان
- **UIBackgroundModes** = `audio` للصوت في الخلفية

### 2. Privacy Manifest
- تم إنشاء **ios/Runner/PrivacyInfo.xcprivacy** وإضافته لمشروع Xcode
- لا تتبع، ولا جمع بيانات شخصية

### 3. Podfile
- **platform :ios, '12.0'** مفعّل (أدنى إصدار iOS 12)

### 4. Xcode
- **PRODUCT_BUNDLE_IDENTIFIER** = `com.ruqyah.altatil`
- **IPHONEOS_DEPLOYMENT_TARGET** = 12.0
- مظروف الخصوصية مضمّن في Resources

---

## بناء iOS من ويندوز (بدون Mac ولا Xcode)

تم إعداد حلّين يعملان من جهازك الحالي:

### الحل 1 — Codemagic (مُفضّل: ينتج IPA جاهز للرفع)

1. سجّل مجاناً على **https://codemagic.io**
2. اضغط **Add application** واربط مستودع المشروع (GitHub أو GitLab أو ارفع المشروع أولاً إلى GitHub)
3. اختر المستودع ثم اضغط **Finish**
4. في **App Store Connect** (حساب Apple Developer):
   - أنشئ **App Store Connect API Key** من Users and Access > Keys
   - حمّل المفتاح (.p8) واحتفظ بـ Key ID و Issuer ID
5. في Codemagic: **Integrations** > **App Store Connect** > أضف المفتاح (Team ID, Key ID, Issuer ID, ملف .p8)
6. في التطبيق اختر الـ workflow **iOS رقية التعطيل** واضغط **Start new build**
7. بعد انتهاء البناء ستجد ملف **.ipa** في الـ Artifacts، ويمكنك رفعه إلى TestFlight/App Store من نفس Codemagic أو تحميله ورفعه يدوياً

الملف **codemagic.yaml** في جذر المشروع جاهز؛ لا تحتاج تغييره إلا إذا أردت تغيير الإصدار أو البريد.

### الحل 2 — GitHub Actions

1. ارفع المشروع إلى **GitHub** (مستودع خاص أو عام)
2. الـ workflow **.github/workflows/ios-build.yml** سيعمل تلقائياً عند الدفع إلى `main` أو عند تشغيله يدوياً (Actions > iOS Build > Run workflow)
3. الناتج: **Runner.app** (تطبيق غير موقع) يُحمّل كـ Artifact — مفيد للتأكد أن البناء ينجح
4. للحصول على **IPA موقع** للرفع على App Store تحتاج إضافة شهادات التوقيع كـ Secrets (معقّد نسبياً)؛ للتسهيل استخدم Codemagic أعلاه

### الحل 3 — استئجار Mac سحابي (مرة واحدة أو نادرة)

- **MacinCloud**: https://www.macincloud.com — استئجار جهاز Mac عن بُعد واستخدام Xcode كما لو كان عندك
- **MacStadium**: للفرق أو الاستخدام الأقوى

ثم تنفّذ الخطوات نفسها المذكورة في القسم «خطواتك قبل الرفع (على Mac)» من هذا الملف.

---

## خطواتك قبل الرفع (على Mac)

### 1. توليد الأيقونة وشاشة الإقلاع
```bash
cd "المسار_إلى_مشروع_الرقية"
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### 2. تثبيت Pods
```bash
cd ios
pod install
cd ..
```

### 3. البناء للأرشفة (Archive)
- افتح **ios/Runner.xcworkspace** في Xcode (ليس .xcodeproj)
- اختر **Product > Scheme > Runner**
- اختر جهاز **Any iOS Device (arm64)**
- **Product > Archive**
- بعد الانتهاء: **Distribute App** > **App Store Connect** > **Upload**

### 4. في App Store Connect
- أنشئ تطبيقاً جديداً إذا لم يكن موجوداً
- Bundle ID: **com.ruqyah.altatil**
- املأ الوصف واللقطات وسياسة الخصوصية
- اختر الإصدار المُرفوع وأرسل للمراجعة

### 5. الحساب والتوقيع
- حساب مطوّر Apple (99$/سنة)
- في Xcode: **Signing & Capabilities** > اختر Team واترك Xcode يدير الشهادات

---

## ملخص الأمان
- لا تخزين حساس بدون حماية: **shared_preferences** للمفضلة فقط (لا كلمات سر)
- لا حزم مخلّة بسياسة التخزين
- **ITSAppUsesNonExemptEncryption** = false مناسب للتطبيق

المشروع جاهز من جهة الإعدادات؛ المتبقي هو تشغيل الأوامر أعلاه على Mac ورفع البناء من Xcode.

للخطوات المتبقية فقط (GitHub، Codemagic، روابط المعاينة) راجع ملف **متبقي_عليك.md** في جذر المشروع.
