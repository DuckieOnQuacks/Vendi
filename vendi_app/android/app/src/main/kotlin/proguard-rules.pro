# Keep TensorFlow Lite GPU delegate classes
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-keep class org.tensorflow.lite.gpu.** { *; }

# General TensorFlow Lite keep rules
-keep class org.tensorflow.lite.** { *; } 