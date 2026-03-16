# إكمال إجراءات النشر — Roqia Al-Tatil

## ما تم إعداده تلقائياً
- ✅ `codemagic.yaml` — workflows لـ iOS و Android
- ✅ `android/app/build.gradle` — دعم توقيع Codemagic CI
- ✅ دعم Windows — `flutter build windows --release`
- ✅ المستودع: `https://github.com/ispada88-op/ruqyah-altatil.git`

---

## الخطوة 1: دفع التغييرات إلى GitHub

```bash
git add codemagic.yaml android/app/build.gradle pubspec.yaml windows/ docs/ lib/credit_card/ test/
git add .gitignore
git status
git commit -m "feat: add Codemagic CI/CD, Windows support, Credit Card MVP"
git push origin main
```

---

## الخطوة 2: Codemagic — إضافة التطبيق

1. افتح **https://codemagic.io/login**
2. سجّل الدخول بـ **GitHub** (يفضّل لربط المستودع مباشرة)
3. اضغط **Add application**
4. اختر المستودع: `ispada88-op/ruqyah-altatil`
5. اختر الفرع: `main`
6. اضغط **Check for configuration file** — سيُكتشف `codemagic.yaml` تلقائياً

---

## الخطوة 3: Codemagic — توقيع Android

1. من إعدادات التطبيق: **Team settings** → **Code signing identities** → **Android keystores**
2. اضغط **Add keystore**
3. **Reference name:** `android_keystore` (يجب أن يطابق الاسم في codemagic.yaml)
4. ارفع ملف الـ keystore (أنشئه إن لم يكن موجوداً — انظر أدناه)
5. أدخل: Key alias, Key password, Keystore password

### إنشاء Keystore (للمرة الأولى)

```bash
keytool -genkey -v -keystore roqia.keystore -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias roqia
```

---

## الخطوة 4: Codemagic — توقيع iOS (للنشر على App Store)

1. **Team settings** → **Integrations** → **Developer Portal** → **Connect**
2. ارفع مفتاح App Store Connect API من: https://appstoreconnect.apple.com/access/integrations/api
3. أدخل Issuer ID و Key ID

---

## الخطوة 5: Google Play Console

1. افتح **https://play.google.com/console**
2. سجّل الدخول بحساب Google
3. إنشاء تطبيق جديد (إن لم يكن موجوداً)
4. Package name: `com.ruqyah.altatil`
5. ارفع أول AAB يدوياً، أو اربط Codemagic للنشر التلقائي (Service account JSON)

---

## الخطوة 6: تشغيل البناء في Codemagic

بعد إكمال الخطوات 1–4:
- أي **push** إلى `main` يشغّل البناء تلقائياً
- أو اضغط **Start new build** يدوياً من واجهة Codemagic

---

## روابط سريعة

| الخدمة | الرابط |
|--------|--------|
| Codemagic Login | https://codemagic.io/login |
| Codemagic Applications | https://codemagic.io/applications |
| Google Play Console | https://play.google.com/console |
| App Store Connect | https://appstoreconnect.apple.com |
| GitHub Repo | https://github.com/ispada88-op/ruqyah-altatil |
