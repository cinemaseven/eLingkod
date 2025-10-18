# -------------------------------
# Keep all ML Kit Text Recognition classes
# -------------------------------
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep ML Kit common model classes (for dynamic model downloads)
-keep class com.google.mlkit.common.model.** { *; }

# Keep all ML Kit interfaces (prevents stripping internal callbacks)
-keep interface com.google.mlkit.** { *; }

# Suppress warnings about missing optional ML Kit classes
-dontwarn com.google.mlkit.**
