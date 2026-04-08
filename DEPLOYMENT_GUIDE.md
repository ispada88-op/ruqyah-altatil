# 🚀 دليل النشر النهائي — رقية التعطيل

## 📋 الملفات الجاهزة

| الملف | الوصف |
|-------|-------|
| `build\app\outputs\flutter-apk\app-release.apk` | APK جاهز للرفع على Google Play (~184 MB) |
| `codemagic.yaml` | إعدادات Codemagic CI/CD للبناء التلقائي |
| `.github\workflows\codemagic.yml` | سير عمل GitHub Actions |
| `privacy_policy.html` | سياسة الخصوصية |
| `CHANGELOG.md` | سجل التغييرات |

---

## 🤖 الخطوة 1: رفع سياسة الخصوصية

### الخيار أ) رفع على GitHub Pages (الأسهل):
1. ارفع ملف `privacy_policy.html` على مستودع GitHub
2. اذهب لـ Settings → Pages
3. اختر Branch: main, Folder: / (root)
4. الرابط يكون: `https://kajoker88.github.io/ruqyah-altatil/privacy_policy.html`

### الخيار ب) رفع على أي استضافة مجانية:
- Netlify (سحب وإفلات الملف)
- Vercel
- Google Sites

**⚠️ لازم تكون الرابط HTTPS**

---

## 🤖 الخطوة 2: رفع على Google Play

### عبر المتصفح مباشرة:
1. افتح: https://play.google.com/console
2. اختر التطبيق (أو أنشئ جديد)
3. **Setup** → **App content** → **Privacy policy**
4. أضف رابط سياسة الخصوصية
5. **Production** → **Create new release**
6. ارفع `app-release.apk`
7. املأ Release Notes:

**بالعربي:**
```
الإصدار 1.0.0 — رقية التعطيل

🎵 جديد:
• تشغيل رقية بصوت المعيقلي والغامدي
• قراءة الآيات بخط عثماني (مصحف المدينة)
• عداد تسبيح ذكي مع الأذكار المأثورة
• وضع ليلي / نهاري
• شاشة ترحيب للمستخدم الجديد
```

---

## 🍎 الخطوة 3: تحديث iOS عبر Codemagic

### الإعداد الأولي (مرة واحدة):
1. افتح: https://codemagic.io
2. سجّل دخول بـ GitHub
3. **Add application** → اختر `ruqyah-altatil`
4. **Build configuration** → اختر `codemagic.yaml`

### إضافة مفاتيح التوقيع:

#### Android:
1. اذهب لـ **Teams** → **Environment variables**
2. أضف:
   - `CM_KEY_ALIAS` = اسم الـ alias
   - `CM_KEY_PASSWORD` = كلمة مرور الـ key
   - `CM_KEYSTORE_PASSWORD` = كلمة مرور الـ keystore
3. ارفع ملف الـ keystore (.jks) في **Code signing identities**

#### iOS:
1. ارفع شهادة Apple في **Code signing identities** → **iOS certificates**
2. ارفع Provisioning Profile
3. أضف متغيرات:
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_PRIVATE_KEY`

### تشغيل البناء:
1. اختر workflow: `ios-release`
2. اضغط **Start new build**
3. انتظر البناء (حوالي 15-20 دقيقة)
4. الـ IPA يُرفع تلقائياً لـ TestFlight
5. من TestFlight → Submit for Review

---

## 📋 Checklist قبل الرفع

### Android (Google Play):
- [x] `flutter analyze` → No issues found ✅
- [x] `flutter build apk --release` → Success ✅
- [x] سياسة الخصوصية جاهزة ✅
- [ ] رفع سياسة الخصوصية على رابط HTTPS
- [ ] إضافة رابط الخصوصية في Google Play Console
- [ ] لقطات شاشة (Screenshots) — 2 على الأقل لكل حجم
- [ ] أيقونة التطبيق (512x512 PNG)
- [ ] بانر (1024x500 PNG)
- [ ] تصنيف المحتوى (Content Rating)
- [ ] فئة التطبيق: Lifestyle

### iOS (App Store via Codemagic):
- [x] `codemagic.yaml` جاهز ✅
- [x] Bundle ID: `com.ruqyah.altatil` ✅
- [x] Version: `1.0.0+2` ✅
- [ ] شهادة Apple مرفوعة على Codemagic
- [ ] Provisioning Profile مرفوع
- [ ] App Store Connect metadata محدّث
- [ ] لقطات شاشة iOS (6.7", 6.5", iPad)
- [ ] What's New text محدّث

---

## 🔗 روابط مهمة

| الخدمة | الرابط |
|--------|--------|
| Google Play Console | https://play.google.com/console |
| App Store Connect | https://appstoreconnect.apple.com |
| Codemagic | https://codemagic.io |
| GitHub Repo | https://github.com/kajoker88/ruqyah-altatil |
| سياسة الخصوصية | (بعد رفعها) |

---

## 📞 للتواصل
المطور: kajoker88
البريد: kajoker88@gmail.com
