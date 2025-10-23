# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Keep location services
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Google Play Core classes removed due to SDK 34 incompatibility
# -keep class com.google.android.play.core.** { *; }
# -keep interface com.google.android.play.core.** { *; }

# Flutter deferred components (disabled for SDK 34 compatibility)
# -keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
# -keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Google Play Core tasks (disabled for SDK 34 compatibility)
# -keep class com.google.android.play.core.tasks.** { *; }
# -keep interface com.google.android.play.core.tasks.** { *; }

# Split install classes (disabled for SDK 34 compatibility)
# -keep class com.google.android.play.core.splitinstall.** { *; }
# -keep class com.google.android.play.core.splitcompat.** { *; }
