# 📷🎙️ Práctica 3 - Aplicaciones Nativas  
## Aplicación de Cámara y Micrófono para Android  

## 📋 Descripción General  
Aplicación nativa de Android que integra funcionalidades avanzadas de **captura fotográfica**, **grabación de audio** y **gestión multimedia**.  
Diseñada con una interfaz moderna que soporta **dos temas (Guinda y Azul)** con adaptación automática a **modo claro/oscuro**.

## ✨ Características Principales  

- **Captura de Fotos:** CameraX API con previsualización en tiempo real, filtros y controles avanzados  
- **Grabación de Audio:** MediaRecorder API con visualización de niveles y controles completos  
- **Galería Integrada:** Visualizador de imágenes con edición básica y reproductor de audio  
- **Gestión de Archivos:** Almacenamiento organizado con MediaStore y base de datos Room  
- **Temas Personalizables:** Soporte para modo claro/oscuro en colores Guinda y Azul  

## 🔧 Requisitos del Sistema  

### Versiones Mínimas  
- **Android Studio:** Arctic Fox 2020.3.1 o superior  
- **Gradle:** 7.0+  
- **Android Gradle Plugin:** 7.0.0+  
- **API Mínima:** Android 7.0 (API 24)  
- **API Target:** Android 13 (API 33) o superior  
- **Kotlin:** 1.8.0+  

## 📦 Dependencias Principales  

```gradle
// Room Database
implementation "androidx.room:room-runtime:2.5.2"
kapt "androidx.room:room-compiler:2.5.2"

// Lifecycle & ViewModel
implementation "androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.2"
implementation "androidx.lifecycle:lifecycle-livedata-ktx:2.6.2"
```

# 📥 Instrucciones de Instalación
### Habilitar instalación de fuentes desconocidas:

- Ir a: Configuración > Seguridad > Fuentes desconocidas ✅
- Instalar el APK:
- Abrir el archivo descargado
- Pulsar “Instalar”
- Esperar confirmación
- Conceder permisos al iniciar (ver sección de permisos dentro de la app).

# 💻 Compilación desde Código Fuente
## Clonar el repositorio
- git clone https://github.com/said153/Pr-ctica-3-Aplicaciones-nativas.git

## Abrir en Android Studio
### File > Open > Seleccionar carpeta del proyecto
- Sincronizar Gradle
- Build > Sync Project with Gradle Files
### Compilar APK
- Build > Build Bundle(s) / APK(s) > Build APK(s)

## 🔐 Permisos Requeridos  

| Permiso | Justificación |
|----------|----------------|
| `CAMERA` | Captura de fotos con cámara frontal/trasera |
| `RECORD_AUDIO` | Grabación de audio con micrófono |
| `WRITE_EXTERNAL_STORAGE` | Guardar fotos/audio|
| `READ_EXTERNAL_STORAGE` | Leer galería multimedia |
| `READ_MEDIA_IMAGES` | Acceso a imágenes |
| `READ_MEDIA_AUDIO` | Acceso a archivos de audio  |
| `VIBRATE` | Feedback háptico en captura |
| `WAKE_LOCK` | Mantener pantalla activa durante grabación |

## 🔐 Permisos en Tiempo de Ejecución  

```Dart
// Solicitud de permisos en tiempo de ejecución
private fun requestPermissions() {
    val permissions = mutableListOf<String>().apply {
        add(Manifest.permission.CAMERA)
        add(Manifest.permission.RECORD_AUDIO)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            add(Manifest.permission.READ_MEDIA_IMAGES)
            add(Manifest.permission.READ_MEDIA_AUDIO)
        } else {
            add(Manifest.permission.READ_EXTERNAL_STORAGE)
            add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }
    }
    
    ActivityCompat.requestPermissions(this, permissions.toTypedArray(), REQUEST_CODE)
}
```
## 🏗️ Arquitectura Técnica
### Patrón MVVM (Model-View-ViewModel)

📁 app/src/main/java/com/tuapp/
├── 📁 data/
│   ├── 📁 local/
│   │   ├── AppDatabase.kt          # Configuración Room
│   │   ├── dao/
│   │   │   ├── PhotoDao.kt         # DAO para fotos
│   │   │   └── AudioDao.kt         # DAO para audios
│   │   └── entities/
│   │       ├── PhotoEntity.kt      # Entidad de foto
│   │       └── AudioEntity.kt      # Entidad de audio
│   └── 📁 repository/
│       ├── CameraRepository.kt     # Repositorio cámara
│       └── AudioRepository.kt      # Repositorio audio
│
├── 📁 domain/
│   ├── 📁 models/
│   │   ├── Photo.kt                # Modelo de foto
│   │   └── AudioRecord.kt          # Modelo de audio
│   └── 📁 usecases/
│       ├── CapturePhotoUseCase.kt
│       └── RecordAudioUseCase.kt
│
├── 📁 ui/
│   ├── 📁 camera/
│   │   ├── CameraFragment.kt
│   │   └── CameraViewModel.kt
│   ├── 📁 audio/
│   │   ├── AudioRecorderFragment.kt
│   │   └── AudioViewModel.kt
│   └── 📁 gallery/
│       ├── GalleryFragment.kt
│       └── GalleryViewModel.kt
│
└── 📁 utils/
    ├── CameraXHelper.kt            # Utilidades CameraX
    ├── MediaStoreHelper.kt         # Gestión MediaStore
    └── PermissionHelper.kt         # Gestión de permisos

## 🧩 Diagrama de Arquitectura

┌─────────────────────────────────────────────────┐
│                    UI Layer                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────┐ │
│  │   Camera    │  │    Audio     │  │Gallery │ │
│  │  Fragment   │  │   Recorder   │  │Fragment│ │
│  └──────┬──────┘  └──────┬───────┘  └───┬────┘ │
└─────────┼─────────────────┼──────────────┼──────┘
          │                 │              │
          ▼                 ▼              ▼
┌─────────────────────────────────────────────────┐
│                ViewModel Layer                  │
│  ┌─────────────┐  ┌──────────────┐  ┌────────┐ │
│  │   Camera    │  │    Audio     │  │Gallery │ │
│  │  ViewModel  │  │   ViewModel  │  │ViewModel│ │
│  └──────┬──────┘  └──────┬───────┘  └───┬────┘ │
└─────────┼─────────────────┼──────────────┼──────┘
          │                 │              │
          ▼                 ▼              ▼
┌─────────────────────────────────────────────────┐
│              Repository Layer                   │
│  ┌─────────────┐  ┌──────────────┐             │
│  │   Camera    │  │    Audio     │             │
│  │ Repository  │  │  Repository  │             │
│  └──────┬──────┘  └──────┬───────┘             │
└─────────┼─────────────────┼─────────────────────┘
          │                 │
          ▼                 ▼
┌─────────────────────────────────────────────────┐
│               Data Layer                        │
│  ┌─────────────┐  ┌──────────────┐  ┌────────┐ │
│  │    Room     │  │ MediaStore   │  │  File  │ │
│  │  Database   │  │     API      │  │ System │ │
│  └─────────────┘  └──────────────┘  └────────┘ │
└─────────────────────────────────────────────────┘
