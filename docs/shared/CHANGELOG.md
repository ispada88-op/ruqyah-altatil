# Changelog — Ruqyah Altatil (رقية التعطيل)
## Version 1.0.2+4 (2026-06-12)

### 🛠️ Fixes
- MainActivity يمتد AudioServiceActivity — إصلاح فشل تحميل الصوت + تشغيل خلفية موثوق
- flutter_localizations + delegates — إصلاح انهيار MaterialLocalizations مع الـ locale العربي
- نص الرقية المكتوبة بالرسم العثماني الموثّق (Tanzil) + اختبارات سلامة النص القرآني
- خط Noto Naskh Arabic للآيات + تبسيط اختياري للقراءة

### ✨ New
- أيقونة جديدة: مصحف نحاسي ذهبي على قماش أخضر بإطار ذهبي (Android adaptive + legacy)
- بطاقة إخلاء مسؤولية في الرئيسية (الرقية منقولة عن الشيخ فهد القرني — خيري بالكامل)
- زر تكرار/loop للتشغيل أثناء النوم
- أصول المتجر: أيقونة 1024 + feature graphic 1024×500

### 🔐 Release hygiene
- إزالة أذونات exact alarm غير المستخدمة (الجدولة inexact) — سلامة مراجعة Google Play
- إضافة NSPrivacyAccessedAPITypes إلى PrivacyInfo.xcprivacy (متطلب Apple)
- استعادة codemagic.yaml إلى جذر المستودع + تفعيل بوابات الجودة في CI
- حذف ملفات ميتة: MainActivity قديم + custom action غير مستخدم

---

## Version 1.0.0+2 (2026-04-08)

### 🎉 Initial Release
- **الرقية الصوتية**: استمع لرقية التعطيل بصوت الشيخ ماهر المعيقلي والشيخ سعد الغامدي
- **الرقية المكتوبة**: اقرأ آيات الرقية بخط عثماني واضح مطابق لمصحف المدينة المنورة
- **الأذكار**: عداد تسبيح ذكي مع أدعية الرقية المأثورة
- **الوضع الليلي**: دعم كامل للوضع الداكن
- **شاشة ترحيب**: تعريف بالمميزات عند أول استخدام

### 🔧 Technical
- just_audio for audio playback
- wakelock_plus to keep screen awake during playback
- audio_session for proper audio focus management
- Provider for theme management
- GoRouter for navigation
- Drift for local database

### 📱 Supported Platforms
- Android 6.0+ (API 23+)
- iOS 12.0+

---

## Version 1.0.0+1 (Pre-release)
- Internal testing build
