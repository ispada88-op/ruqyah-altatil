# برومبت Gemini لتصميم أيقونة التطبيق

## المطلوب

تصميم أيقونة تطبيق إسلامي اسمه "رقية التعطيل" - تطبيق يساعد المسلم على
الاستماع/قراءة الرقية الشرعية والأذكار اليومية.

## الملفات المطلوبة (3 صور)

| الملف | الأبعاد | الوصف |
|---|---|---|
| `app_icon.png` | 1024×1024 | الأيقونة الكاملة (للـ iOS + التوليد لباقي الأحجام) |
| `app_icon_foreground.png` | 432×432 | الـ foreground فقط، شفاف، يقع داخل دائرة 264px |
| `app_icon_monochrome.png` | 432×432 | نسخة أحادية اللون (silhouette) للـ Themed Icons في Android 13+ |

---

## برومبت Gemini (الصق هذا في gemini.google.com)

```
Design a premium app icon for "رقية التعطيل" — an Islamic spiritual healing app
that plays Quranic recitation and daily dhikr.

Style:
- Modern, minimalist, professional (think Apple/Google design language)
- Flat 2D vector aesthetic with subtle gradient and gentle inner glow
- Highly recognizable at 24px and beautiful at 1024px
- NO text, NO Arabic letters, NO names — symbol only

Concept (use ONE of these — pick the strongest):
1. A stylized geometric pattern derived from Islamic art (8-pointed star, 
   geometric mandala) with a subtle crescent integrated
2. An open mihrab/arch silhouette with soft light radiating from inside
3. Glowing tasbih/misbaha (prayer beads) loop forming a perfect circle

Color palette (MUST USE):
- Primary: deep teal #006B6B
- Accent: warm gold #D4AF37
- Background: solid teal (NOT transparent for the main icon)

Composition rules:
- Padding: 12% on all sides (the symbol fills the central 76%)
- Centered, perfectly symmetric where possible
- Strong silhouette readable in monochrome
- Avoid drop shadows or 3D effects (Apple HIG)
- No gradient banding or harsh edges

Output: Generate as a 1024×1024 square PNG with the teal background filled.
The design should feel calm, sacred, and trustworthy — not commercial.

Inspirations to consider but NOT copy:
- Sehir Hatlari (turkish prayer apps) clean look
- Apple Health icon's minimalism
- Google Maps' geometric clarity
- Aramco's logo simplicity
```

---

## بعد توليد الأيقونة من Gemini

### 1. حفظ الصور

في Gemini راح يطلع 4 خيارات. اختار الأفضل، ثم:
- **حفظ النسخة الكاملة** كـ `app_icon.png` (1024×1024)
- استخدم Photoshop/GIMP/Figma لإنشاء:
  - `app_icon_foreground.png` — نفس التصميم بدون خلفية (شفاف)، 432×432، الـ symbol في وسط 264×264
  - `app_icon_monochrome.png` — نفس الـ foreground بس بالأبيض فقط على شفاف

### 2. أداة سريعة لتوليد الـ foreground و monochrome (بدون Photoshop)

افتح:
- https://easyappicon.com — يولد adaptive icon من PNG واحد
- https://icon.kitchen — أداة أبسط لـ foreground + monochrome

### 3. ضع الملفات في المسار

```
assets/icons/
├── app_icon.png              # 1024×1024 (الأصل)
├── app_icon_foreground.png   # 432×432 شفاف
├── app_icon_monochrome.png   # 432×432 شفاف أحادي اللون
└── splash_icon.png           # 480×480 (يمكن نفس app_icon scaled down)
```

### 4. توليد كل الأحجام تلقائياً

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

كل الأشكال (mipmap-mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi, ios sizes) تتولد تلقائياً.

---

## نصائح من سينيور Apple/Google

1. **Apple HIG**: لا تستخدم drop shadow أو 3D effect - iOS يطبقه تلقائياً.
2. **Google Material**: الـ adaptive icon لازم يبقى واضح حتى لو تم crop لـ circle/square/squircle.
3. **اختبر على الأجهزة قبل النشر** - الأيقونات تطلع مختلفة على Pixel vs Samsung vs iPhone.
4. **الـ monochrome icon**: لو ما طلعت، Android يستخدم الـ adaptive كـ fallback.
5. **حفظ الـ SVG الأصلي** من Gemini لو أعجبك (لأي تعديل لاحق).

---

## بديل أسرع (لو ما تبي تسوي بنفسك)

استخدم خدمة **Looka** أو **Brandmark** بـ ~$30:
- يولد لك logo + أيقونات بكل الأحجام
- جاهزة للتطبيق مباشرة

أو على Fiverr بـ ~$15-25 - في كثير من المصممين العرب يعملون أيقونات إسلامية.
