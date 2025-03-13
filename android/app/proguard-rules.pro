# ==============================
# 🔹 OBFUSCATION DICTIONARY
# ==============================
-obfuscationdictionary dictionary.txt
-classobfuscationdictionary dictionary.txt
-packageobfuscationdictionary dictionary.txt

# ==============================
# 🔹 KEEP FLUTTER CODE
# ==============================
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hindari optimalisasi kelas yang digunakan oleh Flutter
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ==============================
# 🔹 KEEP ACTIVITIES, SERVICES, & BROADCAST RECEIVERS
# ==============================
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver

# Keep semua class dengan anotasi @Keep
-keep @androidx.annotation.Keep class *
-keep @androidx.annotation.Keep interface *
-keep @androidx.annotation.Keep enum *

# ==============================
# 🔹 KEEP MODEL DATA (GSON & JACKSON)
# ==============================
-keep class com.xd.blizzard.model.** { *; }
-keepattributes Signature

# ==============================
# 🔹 KEEP RETROFIT & OKHTTP
# ==============================
-keep class com.xd.blizzard.network.** { *; }
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}
-dontwarn okhttp3.**
-dontwarn retrofit2.**

# ==============================
# 🔹 KEEP NATIVE LIBRARY CODE
# ==============================
-keep class com.xd.blizzard.native.** { *; }

# ==============================
# 🔹 KEEP WEBVIEW CODE
# ==============================
-keep class * extends android.webkit.WebView
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ==============================
# 🔹 KEEP PLAY CORE LIBRARY (DEFERRED COMPONENTS)
# ==============================
-keep class com.google.android.play.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn com.google.android.play.**

# ==============================
# 🔹 AVOID STRIPPING SERIALIZABLE CLASSES
# ==============================
-keepnames class * implements java.io.Serializable

# ==============================
# 🔹 KEEP CUSTOM VIEWS & ATTRIBUTES
# ==============================
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ==============================
# 🔹 KEEP R8 MINIFICATION SAFE
# ==============================
-dontshrink
-dontoptimize
-dontpreverify
-keepattributes *Annotation*

# ==============================
# 🔹 LOGGING (JIKA INGIN MENGHAPUS LOG)
# ==============================
# Uncomment baris di bawah jika ingin menghapus log sebelum rilis
# -assumenosideeffects class android.util.Log { *; }