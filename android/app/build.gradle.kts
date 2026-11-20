import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.supernovalabs.coffeelabs"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.supernovalabs.coffeelabs"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ==========================================================================
    // DISTRIBUTION FLAVORS — pemisahan WAJIB untuk lulus Google Play Protect
    // ==========================================================================
    // Kenapa harus dipisah, bukan sekadar di-flag di runtime:
    // Class `LivinMerchantNotificationListener` adalah turunan
    // NotificationListenerService yang menyaring paket BANK (id.bmri.livinmerchant),
    // mengekstrak nominal Rupiah, lalu mengirimnya ke server. Pola itu identik
    // dengan signature banking-trojan yang dipakai classifier Play Protect.
    // Selama class + string paket bank itu ada di dalam dex, APK akan dinilai
    // berisiko tinggi — tidak peduli niatnya legitimate atau tidak.
    //
    //   store    : DISTRIBUSI PUBLIK (Play Store + APK GitHub).
    //              Tanpa notification-listener bank, tanpa device-admin,
    //              tanpa APK installer. → lulus Play Protect.
    //   merchant : INTERNAL ONLY (HP merchant/admin milik toko sendiri).
    //              Semua kapabilitas kiosk + QRIS bridge utuh.
    //
    // Build:  flutter build apk --flavor store    --release
    //         flutter build apk --flavor merchant --release
    // ==========================================================================
    flavorDimensions += "distribution"

    productFlavors {
        create("store") {
            dimension = "distribution"
            // Package ID publik — TIDAK diubah, agar upgrade tetap mulus.
            resValue("string", "app_flavor_label", "Coffee Labs")
        }
        create("merchant") {
            dimension = "distribution"
            // Package berbeda supaya bisa hidup berdampingan dengan build store
            // di satu perangkat (admin pakai dua-duanya).
            applicationIdSuffix = ".merchant"
            versionNameSuffix = "-merchant"
            resValue("string", "app_flavor_label", "Coffee Labs Merchant")
        }
    }

    // Source set lokasi class sudah otomatis: AGP membaca `src/<flavor>/kotlin`
    // dan `src/<flavor>/res` tanpa deklarasi tambahan (konvensi default).
    // Karena itu `LivinMerchantNotificationListener` cukup dipindah ke
    // src/merchant/kotlin/... dan otomatis TIDAK ikut ter-compile di flavor store.

    signingConfigs {
        create("release") {
            val keyPropStoreFile = keystoreProperties.getProperty("storeFile")
            if (keystorePropertiesFile.exists() && keyPropStoreFile != null) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keyPropStoreFile)
                storePassword = keystoreProperties.getProperty("storePassword")
            } else {
                val debugConfig = signingConfigs.getByName("debug")
                val defaultDebug = file("${System.getProperty("user.home")}/.android/debug.keystore")
                val configDebug = file("${System.getProperty("user.home")}/.config/.android/debug.keystore")
                when {
                    defaultDebug.exists() -> {
                        keyAlias = debugConfig.keyAlias
                        keyPassword = debugConfig.keyPassword
                        storeFile = defaultDebug
                        storePassword = debugConfig.storePassword
                    }
                    configDebug.exists() -> {
                        keyAlias = debugConfig.keyAlias
                        keyPassword = debugConfig.keyPassword
                        storeFile = configDebug
                        storePassword = debugConfig.storePassword
                    }
                    else -> {
                        keyAlias = debugConfig.keyAlias
                        keyPassword = debugConfig.keyPassword
                        storeFile = debugConfig.storeFile
                        storePassword = debugConfig.storePassword
                    }
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.core:core-ktx:1.12.0")
}

configurations.all {
    exclude(group = "com.google.firebase", module = "firebase-iid")
}

flutter {
    source = "../.."
}
