# ─── Aura Coach AI — ProGuard / R8 keep rules ────────────────────────
# Applied on top of getDefaultProguardFile("proguard-android-optimize.txt").
# Add a rule here only when a release-build crash points to a class /
# method that R8 stripped — don't pre-emptively keep things "just in
# case", that defeats the size win.
# Test the rules with `flutter build apk --release` then install on a
# real device; emulators sometimes mask reflection failures.

# ── Flutter framework ────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Firebase (auth, firestore, core, crashlytics) ────────────────────
# Firestore uses reflection-driven (de)serialization for Pigeon DTOs.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName *;
}
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── google_sign_in / google-auth ─────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# ── RevenueCat (purchases_flutter v10) ───────────────────────────────
-keep class com.revenuecat.** { *; }
-dontwarn com.revenuecat.**
# Google Play Billing is loaded reflectively by the Hybrid SDK.
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# ── flutter_local_notifications + AndroidX work ──────────────────────
-keep class com.dexterous.** { *; }
-keep class androidx.work.** { *; }
-keep class androidx.lifecycle.** { *; }
-dontwarn com.dexterous.**

# ── flutter_tts ──────────────────────────────────────────────────────
-keep class com.tundralabs.fluttertts.** { *; }

# ── permission_handler ───────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }

# ── Gson reflection (used by several Firebase + RC payload paths) ────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── Kotlin coroutines / serialization ────────────────────────────────
-dontwarn kotlinx.coroutines.**
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# ── Generic safe-defaults — debugging support ────────────────────────
# Keep file/line numbers in stack traces (useful for Crashlytics later).
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep all enum values + native methods (R8 default keeps these but
# being explicit avoids surprises if rules upstream change).
-keepclassmembers enum * { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}
