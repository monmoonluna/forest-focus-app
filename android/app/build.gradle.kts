plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth") // Thêm cho Authentication
    implementation("com.google.firebase:firebase-firestore") // Thêm cho Firestore
    implementation("com.google.android.gms:play-services-base:18.5.0") // Thêm để giao tiếp với Google Play Services
}

android {
    namespace = "com.example.focus_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion // Sử dụng NDK version của Flutter để tránh xung đột

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.focus_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}