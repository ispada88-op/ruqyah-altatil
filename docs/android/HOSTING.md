# استضافة سياسة الخصوصية (رابط عام لـ Google Play)

Google Play يطلب **رابط عام** لسياسة الخصوصية. أسهل طريقة مجانية: GitHub Pages (الريبو أصلاً على GitHub).

## الطريقة الأسرع — GitHub Pages من مجلد docs

1. انسخ ملف السياسة لمكان يخدمه Pages باسم واضح:
   - مثال: انسخ `docs/shared/privacy_policy.html` إلى `docs/index.html` أو `docs/privacy/index.html`.
2. على GitHub: **Settings → Pages**.
3. **Source:** `Deploy from a branch` → Branch: `main` → Folder: `/docs` → Save.
4. بعد دقيقة، الرابط يصير:
   `https://ispada88-op.github.io/ruqyah-altatil/privacy/`
   (أو `/privacy_policy.html` حسب مكان الملف)
5. افتح الرابط للتأكد، ثم ضعه في حقل **Privacy policy** داخل Play Console.

> بديل: الريبو فيه `static.yml` (GitHub Actions). لو مفعّل، يكفي رفع الملف ضمن المسار المنشور.

## بديل سريع بدون GitHub
- ارفع `privacy_policy.html` على أي استضافة ثابتة مجانية (Netlify drop / Cloudflare Pages / Firebase Hosting) واحصل على الرابط.

## تنبيه
- تأكد أن الرابط يفتح **مباشرة** صفحة السياسة (HTTP 200، بدون تسجيل دخول).
- الرابط نفسه يُستخدم لـ Apple App Store أيضاً (السياسة ثنائية المنصّة).
