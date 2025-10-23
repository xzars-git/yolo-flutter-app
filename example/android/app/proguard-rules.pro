# Keep SnakeYAML classes
-keep class org.yaml.snakeyaml.** { *; }
-dontwarn org.yaml.snakeyaml.**

# Keep java.beans classes for SnakeYAML
-keep class java.beans.** { *; }
-dontwarn java.beans.**

# Keep property utilities
-keep class org.yaml.snakeyaml.introspector.** { *; }
-keep class org.yaml.snakeyaml.constructor.** { *; }
-keep class org.yaml.snakeyaml.representer.** { *; }

# Keep TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-keep interface org.tensorflow.** { *; }

# Keep Google ML Kit Text Recognition classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep ML Kit Vision classes
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}