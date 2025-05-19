import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Read version from constants.dart during configuration phase
val constantsFile = File("${project.rootDir}/../lib/constants.dart")
var appLabel = "Crypto Price Tracker" // Default value
if (constantsFile.exists()) {
    val content = constantsFile.readText()
    val versionPattern = """static const String appVersion = "(.*?)";""".toRegex()
    val namePattern = """static const String appName = "(.*?)";""".toRegex()
    
    val versionMatch = versionPattern.find(content)
    val nameMatch = namePattern.find(content)
    
    if (versionMatch != null && nameMatch != null) {
        val appVersion = versionMatch.groupValues[1]
        val appName = nameMatch.groupValues[1]
        appLabel = "$appName $appVersion"
        println("Using app label: $appLabel")
    }
}

android {
    namespace = "com.example.flutter_crypto_app_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_crypto_app_new"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Set the app label from our constants
        manifestPlaceholders["appLabel"] = appLabel
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
