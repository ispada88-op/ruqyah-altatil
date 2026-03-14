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
