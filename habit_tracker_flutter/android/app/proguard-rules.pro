# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Sqflite & SQLite rules
-keep class com.tekartik.sqflite.** { *; }

# Google Fonts
-dontwarn com.google.common.**
-dontwarn javax.annotation.**

# Play Core / Flutter deferred components
-dontwarn com.google.android.play.core.**
