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

# Shorebird & OTA Engine
-keep class dev.shorebird.** { *; }
-dontwarn dev.shorebird.**

# Audio Engines
-dontwarn com.ryanheise.just_audio.**
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn xyz.luan.audioplayers.**
-keep class xyz.luan.audioplayers.** { *; }

# Bluetooth Low Energy & Thermal Printing
-dontwarn com.boskokg.flutter_blue_plus.**
-keep class com.boskokg.flutter_blue_plus.** { *; }
-dontwarn net.nfet.flutter.printing.**
-keep class net.nfet.flutter.printing.** { *; }

# AndroidX & Coroutines
-dontwarn kotlinx.coroutines.**
-keep class kotlinx.coroutines.** { *; }
