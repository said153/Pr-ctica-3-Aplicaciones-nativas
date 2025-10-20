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

# 📦 Dependencias Principales
```
| Categoría                     | Paquete / Versión             | Descripción                                          |
|-------------------------------|-------------------------------|------------------------------------------------------|
| **Flutter SDK**               | `flutter`                     | Framework principal                                  |
| **Gestión de estado**         | `provider: ^6.1.2`            | Manejo de estados reactivos                          |
| **Cámara y medios**           | `camera: ^0.10.5+9`           | Acceso a cámara y previsualización                   |
|                               | `image_picker: ^1.0.7`        | Selección de imágenes desde galería o cámara         |
|                               | `gal: ^2.3.2`                 | Gestión de galería                                   |
|                               | `photo_manager: ^3.0.0`       | Administración de fotos y permisos                   |
| **Audio - grabación**         | `record: 5.1.2`               | Grabación de audio (versión fija por compatibilidad) |
| **Audio - reproducción**      | `audioplayers: ^6.1.0`        | Reproducción de archivos de audio                    |
| **Procesamiento de imágenes** | `image: ^4.1.7`               | Manipulación de imágenes                             |
|                               | `exif: ^3.3.0`                | Lectura de metadatos EXIF                            |
| **Base de datos local**       | `sqflite: ^2.3.2`             | Base de datos SQLite                                 |
|                               | `path_provider: ^2.1.2`       | Rutas locales para almacenamiento                    |
|                               | `path: ^1.9.0`                | Manejo de rutas de archivos                          |
| **Permisos**                  | `permission_handler: ^11.4.0` | Solicitud de permisos en tiempo de ejecución         |
| **UI y utilidades**           | `intl: ^0.19.0`               | Internacionalización y formato de fechas             |
|                               | `shared_preferences: ^2.2.2`  | Almacenamiento local ligero                          |
| **Compartir archivos**        | `share_plus: ^7.2.2`          | Compartir archivos y contenido                       |
| **Iconos**                    | `cupertino_icons: ^1.0.6`     | Iconos estilo iOS                                    |
```


## 🛠 Dev Dependencies
```
| Paquete                     | Descripción                          |
|-----------------------------|--------------------------------------|
| `flutter_test`              | Framework para pruebas unitarias     |
| `flutter_lints: ^3.0.1`     | Reglas de linting y buenas prácticas |

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
## 📸 Funcionalidades de Cámara
# Características Implementadas
```
| Función            | Descripción                             |
|--------------------|-----------------------------------------|
| Previsualización   | Vista en tiempo real de la cámara       |
| Captura            | Tomar foto con calidad máxima           |
| Flash              | Auto / On / Off                         |
| Temporizador       | 3 / 5 / 10 segundos                     |
| Cambio cámara      | Frontal ↔ Trasera                       |
| Filtros            | Escala de grises, Sepia, Brillo         |
```
### Esquema de Base de Datos
```
┌─────────────────────────────────────┐
│            photos                   │
├─────────────────────────────────────┤
│ id (PK)          LONG               │
│ uri              STRING             │
│ fileName         STRING             │
│ dateTaken        LONG               │
│ location         STRING (nullable)  │
│ tags             STRING (nullable)  │
│ filterApplied    STRING (nullable)  │
│ cameraLens       STRING             │
│ flashMode        STRING             │
│ album            STRING (nullable)  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│         audio_records               │
├─────────────────────────────────────┤
│ id (PK)          LONG               │
│ uri              STRING             │
│ fileName         STRING             │
│ dateRecorded     LONG               │
│ duration         LONG               │
│ quality          STRING             │
│ tags             STRING (nullable)  │
│ album            STRING (nullable)  │
└─────────────────────────────────────┘
```
# 🎨 Interfaz de Usuario

## Sistema de Temas
La aplicación implementa dos temas personalizados (**Guinda** y **Azul**) con soporte completo para modo claro y oscuro.

---

### Tema Guinda

#### themes.xml - Tema Guinda Claro
```xml
<style name="Theme.CameraApp.Guinda" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
    <item name="colorPrimary">@color/guinda_primary</item>
    <item name="colorPrimaryVariant">@color/guinda_dark</item>
    <item name="colorOnPrimary">@color/white</item>
    <item name="colorSecondary">@color/guinda_accent</item>
    <item name="colorSecondaryVariant">@color/guinda_accent_dark</item>
    <item name="colorOnSecondary">@color/white</item>
    <item name="android:statusBarColor">?attr/colorPrimaryVariant</item>
</style>
```
#### colors.xml - Colores Guinda
```xml
<resources>
    <color name="guinda_primary">#8B0000</color>
    <color name="guinda_dark">#5D0000</color>
    <color name="guinda_light">#B71C1C</color>
    <color name="guinda_accent">#C62828</color>
    <color name="guinda_accent_dark">#8E0000</color>
</resources>
```

#### Tema Azul.
```xml
themes.xml - Tema Azul Claro
<style name="Theme.CameraApp.Azul" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
    <item name="colorPrimary">@color/azul_primary</item>
    <item name="colorPrimaryVariant">@color/azul_dark</item>
    <item name="colorOnPrimary">@color/white</item>
    <item name="colorSecondary">@color/azul_accent</item>
    <item name="colorSecondaryVariant">@color/azul_accent_dark</item>
    <item name="colorOnSecondary">@color/white</item>
</style>
```

#### colors.xml - Colores Azul
```xml
<resources>
    <color name="azul_primary">#1565C0</color>
    <color name="azul_dark">#0D47A1</color>
    <color name="azul_light">#1976D2</color>
    <color name="azul_accent">#2196F3</color>
    <color name="azul_accent_dark">#1565C0</color>
</resources>
```

### Flujo de Captura de Foto
```
Usuario abre app
      ↓
Solicita permisos (CAMERA, STORAGE)
      ↓
Inicializa CameraX con previsualización
      ↓
Usuario configura:
  • Flash (Auto/On/Off)
  • Temporizador (0/3/5/10s)
  • Cámara (Frontal/Trasera)
  • Filtro (Ninguno/Escala de grises/Sepia/Brillo)
      ↓
Usuario presiona botón captura
      ↓
¿Temporizador activo?
  Sí → Cuenta regresiva + feedback visual/sonoro
  No → Captura inmediata
      ↓
Aplica filtro seleccionado
      ↓
Guarda en almacenamiento local
      ↓
Registra en MediaStore API
      ↓
Guarda metadatos en Room DB:
  • URI, fecha, ubicación, etiquetas
  • Configuración usada (flash, filtro, lente)
      ↓
Muestra miniatura 
      ↓
Usuario puede:
  • Ver en galería
  • Compartir
  • Editar
  • Eliminar
```

### Flujo de Grabación de Audio
```
Usuario selecciona pestaña Audio
      ↓
Solicita permiso RECORD_AUDIO
      ↓
Usuario configura:
  • Calidad (Alta/Media/Baja)
  • Temporizador límite
      ↓
Usuario presiona GRABAR
      ↓
Inicializa MediaRecorder
      ↓
Comienza grabación
      ↓
Actualiza visualización de nivel en tiempo real
  (cada 100ms consulta getMaxAmplitude())
      ↓
Usuario puede:
  • Pausar → MediaRecorder.pause()
  • Reanudar → MediaRecorder.resume()
  • Detener → MediaRecorder.stop()
      ↓
Al detener:
  Guarda archivo .m4a
      ↓
  Registra en MediaStore
      ↓
  Guarda metadatos en  DB:
    • URI, duración, calidad, fecha
      ↓
  Muestra en lista de grabaciones
      ↓
Usuario puede:
  • Reproducir
  • Compartir
  • Renombrar
  • Eliminar
```

## 📖 Guía de Usuario

### Primeros Pasos

1. **Instalación**
   - Descarga el APK desde el repositorio
   - Habilita "Fuentes desconocidas" en ajustes
   - Instala el APK
   - Abre la aplicación

2. **Concesión de Permisos**
   - Al abrir por primera vez, concede los permisos:
     - ✅ Cámara: Para tomar fotos
     - ✅ Micrófono: Para grabar audio
     - ✅ Almacenamiento: Para guardar archivos

3. **Interfaz Principal**
   - **Pestaña Cámara**: Captura de fotos
   - **Pestaña Audio**: Grabación de audio
   - **Pestaña Galería**: Visualización de archivos

### Capturar Fotos
```
┌─────────────────────────────────────┐
│  [⚙️]            [🔄]        [⚡]  │ Configuración
│                                     │
│                                     │
│          📷 PREVISUALIZACIÓN       │
│                                     │
│                                     │
│  [🎨]  [⏱️]  [📸]  [🖼️]           │ Controles
└─────────────────────────────────────┘

Controles:
🎨 Filtros    - Aplicar efectos
⏱️ Temporizador - 3, 5 o 10 segundos
📸 Captura    - Tomar foto
🖼️ Galería   - Ver fotos guardadas
⚡ Flash      - Auto/On/Off
🔄 Cambiar    - Frontal/Trasera
```

**Pasos**:
1. Ajusta el flash (⚡) según iluminación
2. Selecciona filtro si deseas (🎨)
3. Configura temporizador opcional (⏱️)
4. Presiona el botón de captura (📸)
5. La foto se guarda automáticamente

### Grabar Audio
```
┌─────────────────────────────────────┐
│         🎙️ GRABADORA                │
│                                     │
│  ████████████░░░░░░░░  75%          │ Nivel
│                                     │
│      00:02:34 / 10:00               │ Tiempo
│                                     │
│  [🎵]  [⏸️]  [⏹️]  [📁]           │ Controles
└─────────────────────────────────────┘

Controles:
🎵 Calidad    - Alta/Media/Baja
⏸️ Pausar     - Pausar grabación
⏹️ Detener    - Finalizar y guardar
📁 Archivos   - Ver grabaciones
```

**Pasos**:
1. Selecciona calidad de audio (🎵)
2. Presiona grabar (🔴)
3. Habla cerca del micrófono
4. Pausa si necesitas (⏸️)
5. Detén para guardar (⏹️)

### Gestionar Archivos

**Galería de Fotos**:
- 📱 Toca una foto para verla en pantalla completa
- 🔍 Pellizca para hacer zoom
- ✏️ Toca el ícono de edición para recortar/rotar
- 🗑️ Mantén presionado para eliminar
- 📤 Usa el botón compartir para enviar

**Lista de Audios**:
- ▶️ Toca para reproducir
- ⏸️ Pausa durante reproducción
- 🔊 Arrastra la barra para cambiar posición
- ✏️ Toca el nombre para renombrar
- 📤 Comparte mediante apps

### Organización

**Crear Álbumes**:
1. En galería, presiona ⋮ (menú)
2. Selecciona "Crear álbum"
3. Asigna nombre
4. Selecciona fotos/audios para agregar

**Agregar Etiquetas**:
1. Abre foto/audio
2. Toca ⓘ (información)
3. Presiona "Agregar etiqueta"
4. Escribe etiquetas separadas por coma

**Búsqueda**:
- 🔍 Usa el buscador en galería
- Busca por: nombre, fecha, etiqueta, álbum

---

## 🔒 Seguridad y Privacidad

### Prácticas Implementadas

1. **Permisos en Runtime**
   - Solicitud explicada al usuario
   - Solo se solicitan cuando son necesarios
   - Funcionalidad degradada si se niegan

# Funcionalidades Iniciales:
- ✅ Captura de fotos con CameraX
- ✅ Filtros fotográficos básicos
- ✅ Grabación de audio con calidad configurable
- ✅ Galería integrada con visor y reproductor
- ✅ Base de datos Room para metadatos
- ✅ Dos temas: Guinda y Azul
- ✅ Modo claro/oscuro adaptativo
- ✅ Sistema de álbumes y etiquetas
- ✅ Edición básica de fotos
- ✅ Compartir archivos multimedia
- ✅ Feedback háptico y visual

# 🔧 Configuración Android

## Permisos en AndroidManifest.xml
Para que la aplicación funcione correctamente con **cámara, audio y almacenamiento**, se agregan los siguientes permisos:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.INTERNET" />
```

## main.dart - Configuración Principal

El archivo main.dart inicializa la base de datos, solicita permisos y arranca la app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await _requestPermissions();
  runApp(const Practica3App());
}

Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.photos,
  ].request();
}

```

## Estructura de Providers

Se utiliza MultiProvider para manejar el estado global de la aplicación:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => CameraProvider()),
    ChangeNotifierProvider(create: (_) => AudioProvider()),
    ChangeNotifierProvider(create: (_) => GalleryProvider()),
  ],
)
```
- ThemeProvider: Controla el tema de la app (Guinda/Azul).

- CameraProvider: Maneja la cámara y captura de imágenes.

- AudioProvider: Gestiona grabación y reproducción de audio.

- GalleryProvider: Maneja la galería de fotos y medios.


# Video y captura de su implementacion

![Imagen de WhatsApp 2025-10-20 a las 10 16 18_377ade93](https://github.com/user-attachments/assets/bd789db0-9506-4daa-8490-c5443f269ba4) 
![Imagen de WhatsApp 2025-10-20 a las 10 16 18_48a47876](https://github.com/user-attachments/assets/89dbbaba-72b5-488f-a88d-fd32cee91407) 
![Imagen de WhatsApp 2025-10-20 a las 10 16 18_f5010985](https://github.com/user-attachments/assets/28ca9a1d-fa9c-4e19-aff2-b32c70f057ec) 
![Imagen de WhatsApp 2025-10-20 a las 10 16 18_d862ae9b](https://github.com/user-attachments/assets/06f0495a-c919-4193-85f8-97b479b1d94b) 
![Imagen de WhatsApp 2025-10-20 a las 10 16 18_69a4f26c](https://github.com/user-attachments/assets/aa0ac2de-282a-49cc-b2ad-148a700fc01f)
![Imagen de WhatsApp 2025-10-20 a las 10 16 25_d7734d84](https://github.com/user-attachments/assets/4fdfacb2-e3b2-4804-b83c-42d1bfa50952)
![Imagen de WhatsApp 2025-10-20 a las 10 16 26_41096f17](https://github.com/user-attachments/assets/f38f5d10-6d29-4418-8d6f-121efd9aeb25)
![Imagen de WhatsApp 2025-10-20 a las 10 16 27_80170a7f](https://github.com/user-attachments/assets/331304e7-473c-40c1-9deb-5b86bda6588a)
![Imagen de WhatsApp 2025-10-20 a las 10 16 27_fd3e8a3f](https://github.com/user-attachments/assets/5e487b6c-5636-4eb7-945b-9fa59521d54b)
![Imagen de WhatsApp 2025-10-20 a las 10 16 28_ab493c5d](https://github.com/user-attachments/assets/3e56d131-7911-4898-8229-5a92921267e3)
![Imagen de WhatsApp 2025-10-20 a las 10 16 29_202c7cae](https://github.com/user-attachments/assets/f5a544c8-52e9-427f-9817-b8c01be421c8)
![Imagen de WhatsApp 2025-10-20 a las 10 16 29_30f5826f](https://github.com/user-attachments/assets/a602a4f3-13e3-49c2-93e1-76d0b21bf894)
![Imagen de WhatsApp 2025-10-20 a las 10 16 29_37d2ad05](https://github.com/user-attachments/assets/32fd0105-a493-4b13-b7ca-c4478d4a5fe6)
![Imagen de WhatsApp 2025-10-20 a las 10 16 29_d3d9a97f](https://github.com/user-attachments/assets/4a579407-f07f-4b19-a6c2-74aa93e8bfce)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_4d1f2e12](https://github.com/user-attachments/assets/24d6df0d-a8b0-4d0e-b531-7a6ea68e0f95)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_1807dd24](https://github.com/user-attachments/assets/cdc0a05b-d9a0-4c3d-96b4-f0e8834fea0f)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_a234caa9](https://github.com/user-attachments/assets/79e54e98-9050-47ae-8966-ee5df236c60e)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_3535e39e](https://github.com/user-attachments/assets/0b63d124-c4f8-4903-88cb-193d542a21ba)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_c6ac9ebd](https://github.com/user-attachments/assets/4b5b075f-4769-40e1-99a3-f030ac09e114)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_61857160](https://github.com/user-attachments/assets/e23f47ac-51bf-4a46-8548-18ea98bd3d07)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_96eb7ace](https://github.com/user-attachments/assets/91cfd518-6023-4e22-856a-73c5401d506c)
![Imagen de WhatsApp 2025-10-20 a las 10 16 30_8ec34f21](https://github.com/user-attachments/assets/98232058-eb90-4bcc-b537-d6a91eff19a6)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_317a9647](https://github.com/user-attachments/assets/de179f81-9d6c-4ab5-9c30-b92033945407)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_d5a30cdd](https://github.com/user-attachments/assets/b88a0217-2ad1-4b38-8268-61476d684dac)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_b07b2de1](https://github.com/user-attachments/assets/80df3ee5-2335-47ae-b906-58fa840826d7)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_0112c262](https://github.com/user-attachments/assets/4f85457c-d96d-4bbd-9b0b-544fbdd1cc70)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_cd062841](https://github.com/user-attachments/assets/4d283441-8d1c-4c42-ba9c-420082aa669d)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_7d211532](https://github.com/user-attachments/assets/03c3732c-7f64-4958-b639-88a8738d5df1)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_991b3156](https://github.com/user-attachments/assets/8b8b6683-fe32-484b-b1a3-32db0a2ffb47)
![Imagen de WhatsApp 2025-10-20 a las 10 16 31_73f0e715](https://github.com/user-attachments/assets/a681be94-2d63-4f78-b883-db3eb63e62a3)
![Imagen de WhatsApp 2025-10-20 a las 10 16 32_5f8b1bff](https://github.com/user-attachments/assets/e196e963-aab7-421e-9d35-48d252f32e99)
![Imagen de WhatsApp 2025-10-20 a las 10 16 32_752f455d](https://github.com/user-attachments/assets/2636da4d-fdc1-4c10-a9a1-e5b89476b200)





https://github.com/user-attachments/assets/702e0fbb-66ec-4cdc-999d-b79b421d48c5



























