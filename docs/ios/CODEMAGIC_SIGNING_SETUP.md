# إعداد التوقيع التلقائي لـ iOS في Codemagic

بعد تعديل `codemagic.yaml` لاستخدام **fetch-signing-files --create**، يجب إضافة متغير بيئة واحد في Codemagic حتى ينجح البناء.

## الخطوة الوحيدة الإضافية: إضافة CERTIFICATE_PRIVATE_KEY

### 1. إنشاء مفتاح RSA (مرة واحدة)

على **Mac** أو **Git Bash** على Windows نفّذ:

```bash
ssh-keygen -t rsa -b 2048 -m PEM -f ios_distribution_key -q -N ""
```

سيُنشأ ملفان: `ios_distribution_key` (المفتاح الخاص) و `ios_distribution_key.pub`. نحتاج **المفتاح الخاص** فقط.

### 2. نسخ محتوى المفتاح الخاص

- افتح الملف `ios_distribution_key` بمحرر نصوص.
- انسخ **كامل** المحتوى بما فيه السطرين:
  - `-----BEGIN RSA PRIVATE KEY-----`
  - `-----END RSA PRIVATE KEY-----`

### 3. إضافة المتغير في Codemagic

1. ادخل إلى **codemagic.io** → تطبيق رقية التعطيل.
2. من **Settings** أو **Environment variables** أنشئ **مجموعة متغيرات (Variable group)** باسم **`appstore_signing`**.
3. أضف متغيراً:
   - **Name:** `CERTIFICATE_PRIVATE_KEY`
   - **Value:** الصق المحتوى الذي نسخته من الملف (كامل النص مع BEGIN/END).
   - **Secret:** فعّل الخيار (مهم لأمان المفتاح).
4. احفظ المجموعة واربطها بالـ workflow إن لم تكن مربوطة تلقائياً (في `codemagic.yaml` المجموعة `appstore_signing` مُشار إليها بالفعل).

### 4. التأكد من تكامل App Store Connect

- في **Team settings** → **Integrations** يجب وجود تكامل **App Store Connect** باسم **`codemagic`** مع:
  - Issuer ID
  - Key ID
  - ملف .p8 مرفوع

بعد ذلك شغّل البناء من جديد؛ الأمر `app-store-connect fetch-signing-files --create` سينشئ (أو يجلب) الشهادة وملف التوفيع تلقائياً لـ `com.ruqyah.altatil`.
