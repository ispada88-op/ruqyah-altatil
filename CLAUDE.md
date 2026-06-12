# Ruqyah Altatil — Project Guide for Claude Code

تطبيق رقية شرعية إسلامي مكتوب بـ Flutter. هذا الملف يخبر Claude Code بكيفية العمل
على المشروع بشكل صحيح.

---

## Architecture

| Concern | Choice | Notes |
|---|---|---|
| State management | Provider (`provider: ^6.1.2`) | لا تُحوِّل لـ Riverpod/Bloc بدون نقاش |
| Routing | go_router (`go_router: ^16.2.0`) | الـ routes معرّفة في `lib/nav.dart` |
| Audio | just_audio + just_audio_background | للتشغيل في الخلفية + lock screen controls |
| Notifications | flutter_local_notifications + timezone | إشعارات الأذكار كل 3 ساعات |
| Storage | shared_preferences (key/value) + drift (SQLite، غير مستخدم حالياً) |
| Theme | Material 3 + Tajawal (UI) + Amiri (القرآن) | محفوظ في SharedPreferences |
| Error handling | `lib/services/error_reporter.dart` | كل try-catch يستدعي `ErrorReporter.report` |

## Layout

```
lib/
├── main.dart                         # نقطة البداية - تستخدم ErrorReporter.runGuarded
├── theme.dart                        # ThemeProvider + ألوان + خطوط
├── nav.dart                          # GoRouter
├── data/
│   ├── verified_quran.dart          # ⚠️  نص قرآني عثماني موثّق - لا تعدّله يدوياً
│   ├── written_roqia_data.dart      # يجمع البيانات لصفحة الرقية المكتوبة
│   └── quran_data.dart              # سور الأنفال/الدخان/الصافات/الحاقة
├── pages/                            # 6 صفحات (Home, AudioRoqia, WrittenRoqia, Dhikr, Feedback, Onboarding)
├── services/                         # 5 خدمات
└── widgets/                          # 4 widgets
```

## Code Conventions

- **خط القرآن**: `AppTextStyles.quran()` (Amiri فقط)
- **خط الـ UI**: `AppTextStyles.body() / header() / caption()` (Tajawal)
- **الألوان**: من `AppColors` فقط، لا hex literals مباشرة في الكود
- **Spacing**: من `AppSpacing` فقط (xs, sm, md, lg, xl, xxl)
- **RTL**: التطبيق `Locale('ar', 'SA')` ولفّ كل شي بـ `Directionality(rtl)`
- **Error handling**: استخدم `ErrorReporter.report(e, st, context: 'where')` في كل catch
- **Async في initState**: `if (!mounted) return;` بعد كل await قبل setState

## ⛔ Don't Touch

| الملف/المجلد | السبب |
|---|---|
| `lib/data/verified_quran.dart` | نص قرآني عثماني تم التحقق منه ضد Tanzil Uthmani v1.0.2 |
| `assets/audio/*.mp3` | ملفات صوت كبيرة، تُضغط مرة واحدة فقط عبر `scripts/compress_audio.sh` |
| `android/app/build.gradle` `targetSdk` | لا تنقصه عن 35 (إلزامي Google Play 2025) |
| `applicationId = "com.ruqyah.altatil"` | منشور بهذا الـ id على Apple Store |

## Build & Test

```bash
flutter clean
flutter pub get
flutter analyze              # يجب 0 أخطاء قبل أي commit
flutter test                 # تشغيل الاختبارات
flutter build appbundle --release   # AAB لـ Play Store
flutter build apk --release         # APK للتوزيع المباشر
```

CI/CD عبر **Codemagic** - يبني تلقائياً عند push على `main`.
ملف الإعداد: `codemagic.yaml`.

## Quran Text Workflow

**القاعدة المطلقة**: لا تكتب أو تُعدِّل آية قرآنية يدوياً. إذا احتجت إضافة سورة:
1. استخرج النص من Tanzil Uthmani XML
2. تحقق من المطابقة باستخدام `scripts/verify_quran.py` (يجب إنشاؤه إذا لم يكن موجوداً)
3. أضف للـ `verified_quran.dart` فقط بعد التحقق
4. وثّق المرجع في commit message

## Notification Scheduling

`NotificationService` يجدول 35 إشعار للأسبوع القادم. يحترم وقت النوم (10م-7ص).
الجدولة تنتهي بعد 7 أيام - يحتاج إعادة جدولة عند فتح التطبيق التالي
(يحدث تلقائياً في `markSessionStart()`).

## Persona for Claude

أنت مساعد لمطور Flutter سعودي يعمل على تطبيق ديني. ردودك:
- تقنية وموجزة (لا حشو)
- بالإنجليزية للكود، العربية مقبولة في الشرح
- تأخذ أمن المستخدم بالحسبان (لا SMTP credentials في الكود، لا hardcoded secrets)
- تحترم الأذكار والآيات (لا تعديل تلقائي على نصوص قرآنية)
