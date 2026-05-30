# Claude Code Handoff — Ruqyah Altatil

> ملف تسليم: ملخص المحادثة الأخيرة + البرومبت الجاهز لكلود كود لإكمال العمل.

## السياق (Conversation Context)

شغّلنا جلسة على مجلد `C:\Users\khale\ruqyah-altatil` (مشروع Flutter، ريبو متصل بـ `https://github.com/ispada88-op/ruqyah-altatil.git`).

### الحالة الحالية للريبو
- Branch: `main`
- Local HEAD متطابق مع `origin/main`
- فيه تغييرات **لم يتم عمل commit لها بعد**

### التعديلات المعلّقة

**ملفات معدّلة (Modified):**
- `lib/credit_card/**` — وحدة بطاقات الائتمان (logic, models, repository, db)
- `lib/pages/**` — `home_page.dart`, `dhikr_page.dart`, `feedback_page.dart`, `written_roqia_page.dart`
- `lib/data/quran_data.dart`, `lib/nav.dart`, `lib/theme.dart`, `lib/widgets/main_shell.dart`
- `android/**` — `MainActivity.kt` (لـ `com.ruqyah.altatil` و `com.example.counter`), styles, gradle config
- `ios/**` — Runner project, Info.plist, Podfile, Assets
- `windows/**` — runner config + CMakeLists
- `web/index.html`, `web/manifest.json`
- ملفات الإعداد: `.gitignore`, `.metadata`, `analysis_options.yaml`, `pubspec.lock`
- اختبارات: `test/credit_card/**`
- CI: `.github/workflows/ios-build.yml`, `.github/workflows/static.yml`
- `.cursor/rules/security-playbook.mdc`, `README.md`

**ملفات محذوفة (Deleted):**
- ملفات توثيق قديمة في الجذر: `APPLE_IOS_GUIDE.md`, `APPLE_STORE_READY.md`, `CHANGELOG.md`, `CODEMAGIC_SIGNING_SETUP.md`, `DEPLOYMENT_GUIDE.md`, `GOOGLE_PLAY_GUIDE.md`, `SECURITY.md`, `UPLOAD_GUIDE.md`
- `codemagic.yaml`, `docs/DEPLOYMENT.md`
- ملفات عربية في الجذر: `ارفع_التطبيق_منصة_ابل.md`, `دليل_رفع_أبل_خطوة_بخطوة.md`, `رفع_إلى_GitHub.bat`, `رفع_المشروع_على_GitHub.md`, `رفع_من_PowerShell.txt`, `متبقي_عليك.md`
- `privacy/README.md`, `privacy/privacy_policy.html`, `privacy_policy.html`
- `scripts/create_android_keystore.ps1`, `scripts/key.properties.example`, `scripts/setup_deployment.md`

**مجلدات جديدة (Untracked):**
- `docs/android/`
- `docs/ios/` — يحتوي `APPLE_STORE_READY.md`, `CODEMAGIC_SIGNING_SETUP.md`
- `docs/shared/` — يحتوي `DEPLOYMENT.md`, `SECURITY.md`, وهذا الملف

### الهدف
ترتيب التعديلات في commits منطقية ورفعها إلى `origin/main`.

---

## البرومبت الجاهز لكلود كود

> انسخ هذا البرومبت بالضبط والصقه في Claude Code وهو فاتح على مجلد `C:\Users\khale\ruqyah-altatil`.

```text
You are working in the Flutter project at C:\Users\khale\ruqyah-altatil. Read docs/shared/CLAUDE_HANDOFF.md first for full context, then execute the following plan:

1) Verify the current state:
   - Run `git status` and confirm we are on `main`.
   - Run `git log --oneline -5` to see latest commits.

2) Pre-commit verification:
   - Run `flutter analyze` and report any errors. Stop and ask me before continuing if there are errors.
   - Run `flutter test` and report results. Stop and ask me before continuing if any test fails.

3) Stage and commit in logical chunks (use these exact commit messages, in this order):

   a) Documentation reorganization:
      git add docs/ "APPLE_IOS_GUIDE.md" "APPLE_STORE_READY.md" "CHANGELOG.md" "CODEMAGIC_SIGNING_SETUP.md" "DEPLOYMENT_GUIDE.md" "GOOGLE_PLAY_GUIDE.md" "SECURITY.md" "UPLOAD_GUIDE.md" "codemagic.yaml" "privacy/" "privacy_policy.html" "scripts/" "ارفع_التطبيق_منصة_ابل.md" "دليل_رفع_أبل_خطوة_بخطوة.md" "رفع_إلى_GitHub.bat" "رفع_المشروع_على_GitHub.md" "رفع_من_PowerShell.txt" "متبقي_عليك.md" README.md
      git commit -m "docs: reorganize platform guides into docs/{android,ios,shared} and remove legacy root-level docs"

   b) Lib changes (Credit Card module + UI pages):
      git add lib/ test/ pubspec.lock analysis_options.yaml
      git commit -m "feat(credit-card): update card logic, repositories, and UI pages"

   c) Platform configuration:
      git add android/ ios/ windows/ web/
      git commit -m "chore(platform): sync iOS/Android/Windows/Web configuration"

   d) CI and tooling:
      git add .github/ .gitignore .metadata .cursor/
      git commit -m "ci: update workflows and project tooling"

   If any `git add` fails because a path doesn't exist (e.g. file already removed), skip that path and continue.

4) After all commits, run `git status` to confirm working tree is clean.

5) Push to origin:
   git push origin main

6) Final verification:
   - Run `git log --oneline -10` and show me the result.
   - Confirm `git status` shows working tree clean and branch up to date with origin.

Report back with: (a) any errors encountered, (b) the final commit list, (c) confirmation that push succeeded.

Do NOT force-push. Do NOT modify any source code. Only stage, commit, and push.
```

---

## بعد الرفع

عند نجاح الـ push، تأكد من:
- زيارة `https://github.com/ispada88-op/ruqyah-altatil` للتحقق
- تشغيل CI workflows من تبويب Actions
- مراجعة `docs/shared/SECURITY.md` و `docs/ios/APPLE_STORE_READY.md` كنقاط مرجعية للنشر
