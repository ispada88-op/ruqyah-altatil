# Keep audio_service and just_audio_background classes from R8 stripping
-keep class com.ryanheise.** { *; }
-keep interface com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# Keep just_audio classes
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep Flutter and Dart classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Google Fonts (prevents R8 from stripping reflection-based loading)
-keep class com.google.fonts.** { *; }

# General: keep annotations and enums
-keepattributes *Annotation*
-keepattributes Signature
-keepclassmembers enum * { *; }

# flutter_local_notifications يحفظ الإشعارات المجدولة بـ Gson (لإعادة جدولتها
# بعد إعادة تشغيل الجهاز). بدون القواعد التالية يحذف R8 معلومات النوع العام
# فيفشل zonedSchedule في نسخة الإصدار بـ «Missing type parameter» ويضيع التخزين.
# المصدر: github.com/google/gson/blob/master/examples/android-proguard-example/proguard.cfg
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
# نماذج الإضافة المخزَّنة: أسماء حقولها ثابتة بين الإصدارات فتُقرأ بعد التحديث.
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
