# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Google ML Kit optional language recognizers (Chinese, Devanagari, Japanese, Korean)
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }

# Google ML Kit Object Detection
-dontwarn com.google.mlkit.vision.objects.**
-keep class com.google.mlkit.vision.objects.** { *; }
-dontwarn com.google.mlkit.vision.common.**
-keep class com.google.mlkit.vision.common.** { *; }

# Rive native & other plugins
-dontwarn app.rive.runtime.kotlin.**
-keep class app.rive.runtime.kotlin.** { *; }
