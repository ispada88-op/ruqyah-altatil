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
| Storage | shared_preferences (key/value) فقط |
| Theme | Material 3 + Tajawal (UI) + Amiri/Noto Naskh (القرآن) | الخطوط مضمّنة في `assets/google_fonts/` (تعمل بدون إنترنت) |
| Error handling | `lib/services/error_reporter.dart` | كل try-catch يستدعي `ErrorReporter.report` |

## Layout

```
lib/
├── main.dart                         # نقطة البداية - تستخدم ErrorReporter.runGuarded
├── theme.dart                        # ThemeProvider + ألوان + خطوط
├── nav.dart                          # GoRouter
├── config/
│   └── app_links.dart               # App Store id + روابط المشاركة + بريد الاقتراحات (مصدر واحد)
├── data/
│   ├── release_notes.dart           # ملاحظات «الجديد» لكل إصدار — حدّثها مع كل رفع نسخة
│   ├── adhkar_data.dart             # أذكار الصباح والمساء (حصن المسلم) — تُفحص بـ scripts/verify_adhkar.py
│   ├── ruqyah_types_data.dart       # رقى حسب الحالة ⚠️ محتوى شرعي يراجعه خالد قبل كل إصدار
│   ├── quran_index.dart             # مولَّد: أسماء السور/عدد الآيات/الأجزاء (لا تعدّله)
│   ├── quran_extracts.dart          # مولَّد: مقاطع آيات من ملف تنزيل (لا تعدّله)
│   ├── verified_quran.dart          # ⚠️  نص قرآني عثماني موثّق - لا تعدّله يدوياً
│   ├── written_roqia_data.dart      # يجمع البيانات لصفحة الرقية المكتوبة
│   └── quran_data.dart              # مولَّد: سور الأنفال/الدخان/الصافات/الحاقة (لا تعدّله)
├── pages/                            # Home, AudioRoqia, WrittenRoqia, GeneralRuqyah, Tahseen, Dhikr, Feedback, Onboarding
├── services/                         # audio, notifications, share, review, whats_new, error_reporter, haptic
└── widgets/
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

CI/CD:
- `.github/workflows/ci.yml` — analyze + test على كل push/PR (البوابة الأساسية).
- `.github/workflows/ios-release.yml` — عند push لتاق `v*`: analyze + test ثم IPA → TestFlight.
- `codemagic.yaml` — خط بديل (Android internal + iOS). البوابات فيه لم تعد `|| true`.

## ✅ Release checklist (كل تحديث)

1. عدّل الكود + أضف/حدّث الاختبارات.
2. ارفع `version:` في `pubspec.yaml` (مثلاً `1.0.6+13`) — رقم البناء يزيد دائماً.
3. أضف مدخلاً في `lib/data/release_notes.dart` بنفس الإصدار (الاختبار يفشل بدونه).
4. `flutter analyze` = 0 errors/warnings، و`flutter test` كله أخضر.
5. commit → push → انتظر CI أخضر → `git tag vX.Y.Z && git push origin vX.Y.Z` (يطلق TestFlight).
6. من App Store Connect: أضف البناء للإصدار وأرسله للمراجعة.

لا تضف حزمة جديدة إلا إذا استُخدمت فعلاً (أُزيلت 10 حزم غير مستخدمة في 1.0.5).
وحدة `credit_card` القديمة حُذفت من هذا التطبيق — محفوظة في التاق `archive/credit-card-module-20260928`.

## Quran Text Workflow

- المصحف الكامل: `assets/quran/quran-uthmani.txt` — نسخة حرفية من تنزيل 1.1
  (خيارات: علامات الوقف + السجدة + الألف الخنجرية، بدون تطويل). بصمته SHA-256
  مثبّتة في `test/quran_asset_test.dart`. لا تعدّله؛ أعد تنزيله فقط (الرابط في
  `scripts/gen_quran_data.py`).
- الملف مطابق لـ Quran.com (text_uthmani) في كل الآيات الـ6236 حرفاً وضبطاً،
  ولنص مجمع الملك فهد (حفص) في الحروف (تدقيق 2026-09-28).
- `python3 scripts/verify_quran.py` يفحص كل نص قرآني في الكود (442 نصاً) — يعمل في CI:
  الملفات المولَّدة (`quran_data.dart`، `quran_extracts.dart`) يجب أن تطابق الملف بايتاً
  ببايت، و`verified_quran.dart` بتكافؤين تمثيليين فقط موثّقين في السكربت، وأي نص عثماني
  خارج ملفات القرآن الثلاثة يُفشل الفحص. لا توجد فروق مسموحة.
- لإضافة مقطع آيات جديد: أضفه إلى `EXTRACTS` في `scripts/gen_quran_data.py` ثم شغّل
  السكربت — لا تنسخ آية يدوياً.
- **العرض حرفي**: يُعرض النص القرآني كما هو بلا أي تحويل. لا تحذف علامات
  U+06D6–U+06ED «للتبسيط»: فيها الواو/الياء الصغيرة (مدّ)، ونون «نُـۨجِى»، وميم
  الإقلاب، وسكتات حفص، والإمالة والإشمام والتسهيل — حذفها يغيّر التلاوة
  (`test/quran_display_test.dart` يثبت ذلك). الخطوط: Noto Naskh/Amiri فقط (Tajawal لا
  يحوي هذه العلامات).
- البسملة في تنزيل مكتوبة «بِّسْمِ» في التين والقدر، لذا تُفصل بمطابقة الحروف
  (`quranSkeleton`) لا بمطابقة النص.
- الأذكار: `python3 scripts/verify_adhkar.py DIR` (ملفات حصن المسلم JSON) يطابق الحروف.

**القاعدة المطلقة**: لا تكتب أو تُعدِّل آية قرآنية يدوياً. إذا احتجت إضافة سورة:
1. استخرج النص من Tanzil Uthmani XML
2. تحقق من المطابقة باستخدام `scripts/verify_quran.py` (يجب إنشاؤه إذا لم يكن موجوداً)
3. أضف للـ `verified_quran.dart` فقط بعد التحقق
4. وثّق المرجع في commit message

## Notification Scheduling

`NotificationService`:
- المنطقة الزمنية = منطقة الجهاز (`flutter_timezone`)، والرياض احتياط فقط.
- أذكار حتى 59 إشعاراً قادماً (سقف iOS = 64) + تذكير رقية يومي **متكرر** (8م) لا ينتهي.
- يحترم وقت النوم (10م-7ص). يعاد الجدولة عند كل فتح (`rescheduleIfEnabled` في `main`).
- منطق المواعيد في `NotificationPlan` (دوال نقية) ومغطّى بـ `test/notification_plan_test.dart`.

## Deep links

`ruqyah://open/<route>` (اختصارات أندرويد). كل مسار قديم/مجهول يمر على
`AppRoutes.normalize` — المجهول يذهب للرئيسية بدل صفحة خطأ.

## Persona for Claude

أنت مساعد لمطور Flutter سعودي يعمل على تطبيق ديني. ردودك:
- تقنية وموجزة (لا حشو)
- بالإنجليزية للكود، العربية مقبولة في الشرح
- تأخذ أمن المستخدم بالحسبان (لا SMTP credentials في الكود، لا hardcoded secrets)
- تحترم الأذكار والآيات (لا تعديل تلقائي على نصوص قرآنية)
