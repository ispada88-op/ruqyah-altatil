# أصول المتجر — رقية التعطيل

تصميم أصلي (مصحف مفتوح + نور متصاعد) بهوية التطبيق: أخضر مزرقّ (teal) + ذهبي.

| الملف | المقاس | الاستخدام |
|---|---|---|
| `app_icon_1024.png` | 1024×1024 | أيقونة **Apple App Store** (App Store Connect)، ومصدر لباقي المقاسات. بدون شفافية (متطلّب آبل). |
| `app_icon_512.png` | 512×512 | أيقونة **Google Play** (Play Console → Store listing → App icon). |
| `feature_graphic_1024x500.png` | 1024×500 | **Feature graphic** لـ Google Play (إلزامي). |

## ملاحظات
- لقطات الشاشة للمتجر: استخدم لقطات الاختبار (الرئيسية، الرقية الصوتية، الرقية المكتوبة، الوضع الليلي).
- لتعيين هذه الأيقونة كأيقونة التطبيق (launcher) أيضاً: تُحدّث `pubspec.yaml` (`flutter_launcher_icons.image_path`) ثم `dart run flutter_launcher_icons`. ملاحظة: هذا يولّد أيقونات iOS أيضاً؛ طُبّق فقط عند الرغبة بتحديث تطبيق آبل.
- النصوص العربية في الـ feature graphic بخط Sakkal Majalla؛ ملفات الخطوط غير مرفوعة للريبو (حقوق).
