# رفع مشروع الرقية على GitHub (مرة واحدة)

## 1. إنشاء حساب ومستودع على GitHub

1. ادخل **https://github.com** — إذا ما عندك حساب، سجّل (Sign up).
2. بعد تسجيل الدخول اضغط **"+"** أعلى اليمين ثم **"New repository"**.
3. **Repository name:** اكتب مثلاً `ruqyah-altatil`
4. اختر **Private** إذا ما تبي أحد يشوف الكود، أو **Public**.
5. **لا** تضف README أو .gitignore (المشروع عنده .gitignore بالفعل).
6. اضغط **"Create repository"**.

---

## 2. رفع المشروع من جهازك

**الطريقة الأسهل:** شغّل الملف **رفع_إلى_GitHub.bat** من داخل مجلد المشروع. سيطلب منك اسم المستخدم في GitHub، وعند طلب كلمة المرور أدخل الـ **Token** (انظر أسفل).

**أو يدوياً (PowerShell):**

افتح **PowerShell** ونسخ والصق الأوامر التالية **واحدة واحدة** (غيّر `YOUR_USERNAME` باسمك في GitHub):

```powershell
cd "C:\Users\khale\OneDrive\سطح المكتب\Ruqyah_Project"
git init
git add .
git status
git commit -m "رقية التعطيل - جاهز للنشر"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ruqyah-altatil.git
git push -u origin main
```

- عند `git push` يطلب منك **اسم المستخدم** و **كلمة المرور**.
  - اسم المستخدم = إيميلك أو اسم المستخدم في GitHub.
  - كلمة المرور = **لا تستخدم كلمة مرور الحساب** — استخدم **Personal Access Token**:
    - GitHub → Settings → Developer settings → Personal access tokens → Generate new token
    - اختر صلاحية **repo**
    - انسخ الـ Token واستخدمه مكان كلمة المرور عند الطلب.

بعد ما يخلص `git push` يصير المشروع على GitHub.

---

## 3. الرابط اللي تحتاجه في Codemagic

بعد الرفع، رابط المستودع يكون مثل:
**https://github.com/YOUR_USERNAME/ruqyah-altatil**

هذا الرابط (المستودع) هو اللي تربطه في Codemagic في الخطوة التالية.
