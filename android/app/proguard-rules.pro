# Keep OkHttp and Conscrypt classes
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-keep class org.conscrypt.** { *; }
-keep class org.openjsse.** { *; }

# OkHttp Platform used Platform.get() to get itself which is not found when proguarding
-dontnote okhttp3.internal.Platform
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Conscrypt
-keep class org.conscrypt.Conscrypt { *; }
-keep class org.conscrypt.Conscrypt$Version { *; }
-keep class org.conscrypt.ConscryptHostnameVerifier { *; }

# OpenJSSE
-keep class org.openjsse.javax.net.ssl.** { *; }
-keep class org.openjsse.net.ssl.** { *; }
