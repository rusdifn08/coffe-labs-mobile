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
    namespace = "com.example.coffee_hub_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.coffee_hub_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

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
}

flutter {
    source = "../.."
}
