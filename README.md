# رقية التعطيل — Ruqyah Altatil

> تطبيق الرقية الشرعية بصوت الشيخ ماهر المعيقلي والشيخ سعد الغامدي

## 📱 المميزات
- 🎙️ رقية مسموعة بأصوات مشايخ
- 📖 رقية مكتوبة (مطابقة لمصحف المدينة المنورة)
- 🤲 عداد تسبيح وأذكار
- 🌙 وضع ليلي / نهاري

## 📂 هيكل المشروع
```
ruqyah-altatil/
├── android/              ← كود الأندرويد
├── ios/                  ← كود الآيفون
├── lib/                  ← كود Dart المشترك
│   ├── pages/            ← الصفحات
│   ├── services/         ← الخدمات
│   ├── widgets/          ← الويدجتس
│   ├── custom_actions/   ← الإجراءات
│   ├── data/             ← البيانات
│   ├── audio/            ← ملفات الصوت
│   └── utils/            ← أدوات مساعدة
├── assets/               ← الملفات الصوتية والأيقونات
├── docs/                 ← التوثيق
│   ├── android/          ← دليل أندرويد + keystore
│   ├── ios/              ← دليل آيفون + codemagic.yaml
│   └── shared/           ← سياسة الخصوصية + سجل التغييرات
└── test/                 ← الاختبارات
```

## 🚀 التشغيل
```bash
flutter pub get
flutter run
```

## 📦 البناء
```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS
```

## 📋 المنصات
- **Android**: API 23+ (Android 6.0+)
- **iOS**: 12.0+

## 📄 الترخيص
حقوق النشر © 2026 — kajoker88
