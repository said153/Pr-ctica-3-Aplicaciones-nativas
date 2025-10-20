plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'kotlin-kapt'
    id 'androidx.navigation.safeargs.kotlin'
}

android {
    namespace 'com.tuuniversidad.camapp'
    compileSdk 34

    defaultConfig {
        applicationId "com.tuuniversidad.camapp"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
                targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    buildFeatures {
        viewBinding true
        dataBinding true
    }
}

dependencies {
    // Core Android
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'

    // Lifecycle
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-livedata-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'

    // Navigation
    implementation 'androidx.navigation:navigation-fragment-ktx:2.7.6'
    implementation 'androidx.navigation:navigation-ui-ktx:2.7.6'

    // CameraX
    def camerax_version = "1.3.1"
    implementation "androidx.camera:camera-core:${camerax_version}"
    implementation "androidx.camera:camera-camera2:${camerax_version}"
    implementation "androidx.camera:camera-lifecycle:${camerax_version}"
    implementation "androidx.camera:camera-video:${camerax_version}"
    implementation "androidx.camera:camera-view:${camerax_version}"
    implementation "androidx.camera:camera-extensions:${camerax_version}"

    // Room Database
    def room_version = "2.6.1"
    implementation "androidx.room:room-runtime:$room_version"
    implementation "androidx.room:room-ktx:$room_version"
    kapt "androidx.room:room-compiler:$room_version"

    // Coroutines
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3'

    // Glide para carga de imágenes
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    kapt 'com.github.bumptech.glide:compiler:4.16.0'

    // ExoPlayer para reproducción de audio (opcional, más robusto)
    implementation 'com.google.android.exoplayer:exoplayer:2.19.1'

    // Permisos en runtime
    implementation 'com.guolindev.permissionx:permissionx:1.7.1'

    // WorkManager para tareas en background
    implementation 'androidx.work:work-runtime-ktx:2.9.0'

    // Preferencias
    implementation 'androidx.preference:preference-ktx:1.2.1'

    // RecyclerView
    implementation 'androidx.recyclerview:recyclerview:1.3.2'

    // CardView
    implementation 'androidx.cardview:cardview:1.0.0'

    // SwipeRefreshLayout
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'

    // Location Services (para geolocalización de fotos)
    implementation 'com.google.android.gms:play-services-location:21.1.0'

    // Testing
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}