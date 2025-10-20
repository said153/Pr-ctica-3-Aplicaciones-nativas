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
```
practica3_new/
lib/
├── 📁 providers/              
│   ├── audio_provider.dart    # Gestión de audio
│   ├── camera_provider.dart   # Gestión de cámara
│   ├── gallery_provider.dart  # Gestión de galería
│   └── theme_provider.dart    # Gestión de temas
│
├── 📁 screens/                # Pantallas/UI
│   ├── audio_player_screen.dart
│   ├── audio_player_screen_complete.dart
│   ├── audio_screen.dart
│   ├── camera_screen.dart
│   ├── camera_xscreen.dart
│   ├── gallery_screen.dart
│   ├── home_screen.dart
│   ├── image_editor_screen.dart
│   ├── media_detail_screen.dart
│   ├── search_screen.dart
│   ├── settings_screen.dart
│   └── tag_management_screen.dart
│
├── 📁 services/               
│   ├── camerax_service.dart   # Servicio de cámara avanzada
│   ├── exif_service.dart      # Manejo de metadatos EXIF
│   ├── export_service.dart    # Exportación de archivos
│   ├── haptic_feedback_service.dart # Retroalimentación táctil
│   ├── image_editor_service.dart # Edición de imágenes
│   ├── share_service.dart     # Compartir contenido
│   └── tag_service.dart       # Gestión de etiquetas
│
├── 📁 models/                 # Modelos de datos
│   ├── album.dart             # Modelo de álbum
│   └── media_item.dart        # Modelo de elemento multimedia
│
├── 📁 database/               # Persistencia de datos
│   └── database_helper.dart   # Helper de base de datos
│
└── 📁 assets/                 # Recursos estáticos
```

### Diagrama de Arquitectura
```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                     │
├─────────────────────────────────────────────────────────────┤
│  SCREENS (Widgets UI)                                       │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │ home_screen     │ │ camera_screen   │ │ gallery_screen  ││
│  │                 │ │                 │ │                 ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│
│  │ audio_screen    │ │ image_editor    │ │ media_detail    ││
│  │                 │ │ _screen         │ │ _screen         ││
│  └─────────────────┘ └─────────────────┘ └─────────────────┘│
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE ESTADO                           │
├─────────────────────────────────────────────────────────────┤
│  PROVIDERS (State Management)                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ audio       │ │ camera      │ │ gallery     │            │
│  │ _provider   │ │ _provider   │ │ _provider   │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
│  ┌─────────────┐                                            │
│  │ theme       │                                            │
│  │ _provider   │                                            │
│  └─────────────┘                                            │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE SERVICIOS                        │
├─────────────────────────────────────────────────────────────┤
│  SERVICES (Lógica de Negocio)                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ camerax     │ │ image_editor│ │ exif        │            │
│  │ _service    │ │ _service    │ │ _service    │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ export      │ │ haptic      │ │ tag         │            │
│  │ _service    │ │ _service    │ │ _service    │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE DATOS                            │
├─────────────────────────────────────────────────────────────┤
│  MODELS & DATABASE                                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ media_item  │ │ album       │ │ database    │            │
│  │             │ │             │ │ _helper     │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

 ### Diagrama de Flujo de Datos
 ```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   PANTALLA  │    │  PROVIDER   │    │  SERVICIO   │    │   DATOS     │
│   (UI)      │    │  (Estado)   │    │ (Lógica)    │    │ (Modelos)   │
├─────────────┤    ├─────────────┤    ├─────────────┤    ├─────────────┤
│ home_screen │───▶│ gallery     │───▶│ tag_service │───▶│ media_item  │
│             │    │ _provider   │    │             │    │             │
│ camera_     │───▶│ camera      │───▶│ camerax     │───▶│ album       │
│ screen      │    │ _provider   │    │ _service    │    │             │
│             │    │             │    │             │    │ database    │
│ audio_      │───▶│ audio       │───▶│ export      │───▶│ _helper     │
│ screen      │    │ _provider   │    │ _service    │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │                  │
       │                  │                  │                  │
       └──────────────────┴──────────────────┴──────────────────┘
                            Flujo de Respuesta
```

### 🎯 Diagrama de Navegación
```
┌─────────────────┐
│   home_screen   │ ──── Punto de entrada
└─────────────────┘
         │
         ├─────────────────┐
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│  camera_screen  │ │  gallery_screen │
└─────────────────┘ └─────────────────┘
         │                 │
         ▼                 ├─────────────────┐
┌─────────────────┐        ▼                 ▼
│ camera_xscreen  │ ┌─────────────────┐ ┌─────────────────┐
└─────────────────┘ │ media_detail    │ │ search_screen   │
                    │ _screen         │ └─────────────────┘
                    └─────────────────┘         │
         │                 │                    ▼
         ▼                 ▼            ┌─────────────────┐
┌─────────────────┐ ┌─────────────────┐ │ tag_management  │
│  audio_screen   │ │ image_editor    │ │ _screen         │
└─────────────────┘ │ _screen         │ └─────────────────┘
         │           └─────────────────┘
         ▼                    │
┌─────────────────┐          ▼
│ audio_player    │ ┌─────────────────┐
│ _screen         │ │ settings_screen │
└─────────────────┘ └─────────────────┘
```

