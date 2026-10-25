plugins { id("com.android.application"); id("org.jetbrains.kotlin.android") }
android { namespace = "org.minsithu.yaypar"; compileSdk = 35
 defaultConfig { applicationId = "org.minsithu.yaypar"; minSdk = 26; targetSdk = 35; versionCode = 15; versionName = "0.15.0" }
 compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
 kotlinOptions { jvmTarget = "17" }
}
