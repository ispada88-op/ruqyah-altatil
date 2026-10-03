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
| Theme | Material 3 + Tajawal (UI) + خط مجمع الملك فهد (المصحف) + Amiri/Noto Naskh (نصوص إملائية) | الخطوط مضمّنة في `assets/google_fonts/` (تعمل بدون إنترنت) |
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
│   ├── quran_extracts.dart          # مولَّد: مقاطع آيات من ملف المجمع (لا تعدّله)
│   ├── verified_quran.dart          # ⚠️  نص قرآني عثماني موثّق - لا تعدّله يدوياً
│   ├── written_roqia_data.dart      # يجمع البيانات لصفحة الرقية المكتوبة
│   └── quran_data.dart              # مولَّد: سور الأنفال/الدخان/الصافات/الحاقة (لا تعدّله)
├── pages/                            # Home, AudioRoqia, WrittenRoqia, GeneralRuqyah, Tahseen, Dhikr, Feedback, Onboarding,
│                                     # PrayerTimes, Qibla, AfterPrayer, Khatma, Bookmarks, QuranSearch, Program, RuqyahRules, VerseCard
├── services/                         # audio, notifications, share, review, whats_new, error_reporter, haptic,
│                                     # prayer_times (adhan), prayer_reminders + prayer_notification_plan, khatma, bookmarks,
│                                     # quran_search, program
├── utils/                            # arabic_format, arabic_search (تطبيع البحث)، hijri (جدولي، لرمضان فقط)
└── widgets/
```

## Code Conventions

- **خط القرآن (الرسم العثماني)**: `AppTextStyles.mushaf()` (خط مجمع الملك فهد فقط — بلا وزن `bold`)؛ `AppTextStyles.quran()` (Amiri) للآيات الإملائية فقط
- **خط الـ UI**: `AppTextStyles.body() / header() / caption()` (Tajawal)
- **الألوان**: من `AppColors` فقط، لا hex literals مباشرة في الكود
- **Spacing**: من `AppSpacing` فقط (xs, sm, md, lg, xl, xxl)
- **RTL**: التطبيق `Locale('ar', 'SA')` ولفّ كل شي بـ `Directionality(rtl)`
- **Error handling**: استخدم `ErrorReporter.report(e, st, context: 'where')` في كل catch
- **Async في initState**: `if (!mounted) return;` بعد كل await قبل setState

## ⛔ Don't Touch

| الملف/المجلد | السبب |
|---|---|
| `lib/data/verified_quran.dart` + `quran_data.dart` + `quran_extracts.dart` + `quran_index.dart` | مولَّدة من ملف مجمع الملك فهد المثبّت عبر `scripts/gen_quran_data.py` — لا تُعدَّل يدوياً أبداً |
| `assets/audio/*.mp3` | ملفات صوت كبيرة، تُضغط مرة واحدة فقط عبر `scripts/compress_audio.sh` |
| `android/app/build.gradle` `targetSdk` | لا تنقصه عن 36 (إلزامي Google Play لتحديثات ما بعد 2026-08-31) |
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

- المصحف = **مصحف المدينة (مجمع الملك فهد لطباعة المصحف الشريف)**: النص
  `assets/quran/hafsData_v18.json` (بيانات «الخط العثماني حفص» الإصدار 0.18، نسخة حرفية) يُعرض
  بالخط نفسه `assets/fonts/kfgqpc/hafs.18.ttf` (عائلة `KFGQPCHafs`، `AppTextStyles.mushaf`).
  بصمتا الملفين SHA-256 مثبّتتان في `test/quran_asset_test.dart` و`scripts/verify_quran.py`.
  مصدرهما: qurancomplex.gov.sa/en/techquran/dev (الموقع يُحجب من بعض الشبكات؛ نُسخا من مرآة
  GitHub `thetruetruth/quran-data-kfgqpc` بنفس البصمة — تحقّق من الموقع الرسمي من جهاز آخر).
- **رخصة الخط (EULA، في `assets/fonts/kfgqpc/KFGQPC-EULA.txt` وصفحة التراخيص)**: الاستخدام والنسخ
  والتوزيع مجاناً؛ **يُمنع** البيع والتعديل والتحويل (لا woff2 ولا subset) وفك الهندسة. لذلك الـTTF
  يُضمَّن كما هو بايتاً ببايت — لا تعدّله ولا تحوّله.
- صيغة الملف: `aya_text` = نص الآية + مسافة غير قاطعة (U+00A0) + رقمها بالأرقام العربية الهندية؛ الخط
  يرسم الرقم علامة نهاية آية مزخرفة. التطبيق يحتفظ بنص الآية بدون الذيل ويضيفه عند العرض بـ
  `withAyahNumber` (`Verse.withMarker` للنصوص المولّدة). النسخ/المشاركة تمر على `quranForSharing`
  فيصير الذيل ﴿N﴾ ليُقرأ في أي خط. **لا تُغيّر أي حرف أو علامة عند العرض** (لا استبدال سكون ولا مسافات):
  خط المجمع يرسم ترميزه الأصلي كما في المطبوع.
- البسملة = الآية ١:١ في الملف؛ الآية الأولى من باقي السور لا تحملها (لا حاجة لفصلها). تُعرض
  عنواناً للسور عدا الفاتحة والتوبة. أول الجزء ٤ = ٣:٩٢ وأول الجزء ١١ = ٩:٩٤ (كما في مصحف المدينة).
- `python3 scripts/verify_quran.py` يفحص كل نص قرآني في الكود — يعمل في CI: ملفات القرآن الثلاثة
  (`verified_quran.dart`، `quran_data.dart`، `quran_extracts.dart`) وكل ثوابت البسملة يجب أن تطابق
  الملف **بايتاً ببايت**، وأي نص عثماني خارج هذه الملفات يُفشل الفحص.
  `python3 scripts/crosscheck_quran.py` يقارن حروف الملف بنص تنزيل المرجعي (`scripts/ref/
  quran-uthmani-tanzil.txt`): الفرق الوحيد المعروف ٢:٧٢ (همزة)، والياء المنقوطة «في/الذي/شيء» في
  المدينة مقابل «فى/الذى/شىء» في تنزيل.
- الاقتباسات القرآنية الإملائية (أذكار فئة `ayah` بعنوان «آية — السورة رقم»،
  `lib/data/quran_quotes.dart`، وأي نص بين ﴿﴾) يجب أن تكون كلمات كاملة من الآية المذكورة في
  `scripts/ref/quran-simple.txt` (تنزيل — النص البسيط، بصمته مثبّتة). انسخها منه بايتاً ببايت.
  لا تُعرض بخط المصحف (هي إملائية، لا رسم عثماني).
- كلمة التوحيد «لا إله إلا الله محمد رسول الله» ذكر وليست آية — لا تُصنَّف `ayah`.
- لإضافة مقطع آيات جديد: أضفه إلى `EXTRACTS` في `scripts/gen_quran_data.py` ثم شغّل
  السكربت — لا تنسخ آية يدوياً.
- **قارئ الصفحات (مصحف المدينة، ٦٠٤ صفحة)**: `/mushaf/page/:n` يرسم كل صفحة بتقسيم المطبوع (١٥ سطراً)
  من ٤٧ خط صفحة `assets/fonts/qcf4/QCF4_Hafs_NN_W.ttf` + `QCF4_QBSML.ttf` (كل كلمة رمز واحد)، وبياناتها
  `assets/quran/mushaf_pages.json` المولَّد بـ `scripts/gen_mushaf_pages.py` من قاعدة «Mushaf Publisher»
  الرسمية (التفاصيل والإذن في `docs/MUSHAF_PAGES.md`). الخطوط تُحمَّل كسولاً بـ FontLoader (ليست تحت
  `fonts:` في pubspec) وتُضمَّن بايتاً ببايت — بصمتها مثبّتة في `test/mushaf_pages_test.dart`. حقوقها محفوظة
  للمجمع (إذن مسبق بحسب المالك). القارئ المتصل `/mushaf/:surah` (خط قابل للتكبير) ما زال متاحاً من زر «نص متصل».
- مقارنة نص Publisher بنص v18: ٧٧٬٤٠٥ كلمة، الفروق الحقيقية ٣٩ فقط (٢:٧٢ همزة، ١١:٤١ إمالة، «كـَلَّا»
  بتطويل في v18، ٣ مواضع فصل «لَوْ مَا / مَا لِيَ»).
- أسماء السور ونوعها (مكية/مدنية) من تنزيل (CC BY 3.0) وتُذكر في الواجهة.
- الأذكار: `python3 scripts/verify_adhkar.py DIR` (ملفات حصن المسلم JSON) يطابق الحروف.

**القاعدة المطلقة**: لا تكتب أو تُعدِّل آية قرآنية يدوياً. إذا احتجت إضافة سورة:
1. أضفه إلى `EXTRACTS`/`VERIFIED` في `scripts/gen_quran_data.py` وشغّله (المصدر: `hafsData_v18.json`)
2. تحقق من المطابقة باستخدام `scripts/verify_quran.py`
3. أضف للـ `verified_quran.dart` فقط بعد التحقق
4. وثّق المرجع في commit message

## Notification Scheduling

`NotificationService`:
- المنطقة الزمنية = منطقة الجهاز (`flutter_timezone`)، والرياض احتياط فقط.
- أذكار حتى 59 إشعاراً قادماً (سقف iOS = 64) + تذكير رقية يومي **متكرر** (8م) لا ينتهي.
- يحترم وقت النوم (10م-7ص). يعاد الجدولة عند كل فتح (`rescheduleIfEnabled` في `main`).
- منطق المواعيد في `NotificationPlan` (دوال نقية) ومغطّى بـ `test/notification_plan_test.dart`.

## المواقيت والتنبيهات المرتبطة بالصلاة (1.1.0)

- المواقيت حساب فلكي داخل الجهاز بحزمة `adhan` (بلا إنترنت)؛ الموقع من GPS (دقة منخفضة، يُقرَّب إحداثياه لخانتين)
  أو من قائمة مدن `lib/data/prayer_cities.dart` بلا إذن. أم القرى: العشاء = المغرب + ٩٠ د (١٢٠ في رمضان — رمضان
  بتحويل هجري جدولي قد يخطئ يوماً عند حدّي الشهر). الإعدادات في `PrayerTimesService` (shared_preferences فقط).
- تنبيهات الصلاة وأذكار «حسب الصلاة» تُجدول **أسبوعاً قادماً غير متكرر** (`planPrayerNotifications`، دالة نقية
  مغطّاة في `test/prayer_plan_test.dart`) وتُجدَّد عند كل فتح. سقف iOS ٦٤ إشعاراً: ميزانية الصلاة تُحجز قبل الأذكار
  الدورية (`NotificationPlan.dhikrBudget(prayerCount:)`)؛ إن لم يُفتح التطبيق لأيام تنقطع. أندرويد ١٥٠.
- معرّفات الإشعارات: دورية 0..58، رقية 500، مخصصة 600+، أذكار الصباح/المساء 700/701، **الصلاة ١٠٠٠ + يوم×١٦ + خانة**.
- الموقع يعني تحديث **سياسة الخصوصية** و«خصوصية التطبيق» في App Store/Play (الموقع يبقى على الجهاز).

## الختمة والعلامات والبحث

- `KhatmaService`: الصفحة التالية تتقدّم فقط حين تُفتح بالتسلسل (القفز لا يُحتسب)؛ ورد اليوم = المتبقي ÷ الأيام
  المتبقية ويُثبَّت أول كل يوم. `BookmarksService`: علامات على صفحات المصحف.
- البحث: `assets/quran/quran-simple-tanzil.txt` نسخة **حرفية** من `scripts/ref/quran-simple.txt` (تنزيل؛ الشروط
  تمنع التعديل وتشترط الإسناد) — بصمتها مثبّتة في `test/quran_tools_test.dart`. التطبيع في `utils/arabic_search.dart`
  والعرض بنص المجمع (حفص).
- `scripts/gen_after_prayer.py [--check]` يولّد `lib/data/after_prayer_data.dart` من `scripts/ref/hisn_after_prayer.json`
  (حصن المسلم)؛ لا تعدّل الملف المولَّد يدوياً.

## Deep links

`ruqyah://open/<route>` (اختصارات أندرويد). كل مسار قديم/مجهول يمر على
`AppRoutes.normalize` — المجهول يذهب للرئيسية بدل صفحة خطأ.

## Persona for Claude

أنت مساعد لمطور Flutter سعودي يعمل على تطبيق ديني. ردودك:
- تقنية وموجزة (لا حشو)
- بالإنجليزية للكود، العربية مقبولة في الشرح
- تأخذ أمن المستخدم بالحسبان (لا SMTP credentials في الكود، لا hardcoded secrets)
- تحترم الأذكار والآيات (لا تعديل تلقائي على نصوص قرآنية)
