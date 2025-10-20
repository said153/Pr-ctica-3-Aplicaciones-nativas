# 📷🎙️ Práctica 3 - Aplicaciones Nativas  
## Aplicación de Cámara y Micrófono para Android  

---

## 📋 Descripción General  
Aplicación nativa de Android que integra funcionalidades avanzadas de **captura fotográfica**, **grabación de audio** y **gestión multimedia**.  
Diseñada con una interfaz moderna que soporta **dos temas (Guinda y Azul)** con adaptación automática a **modo claro/oscuro**.

---

## ✨ Características Principales  

- **Captura de Fotos:** CameraX API con previsualización en tiempo real, filtros y controles avanzados  
- **Grabación de Audio:** MediaRecorder API con visualización de niveles y controles completos  
- **Galería Integrada:** Visualizador de imágenes con edición básica y reproductor de audio  
- **Gestión de Archivos:** Almacenamiento organizado con MediaStore y base de datos Room  
- **Temas Personalizables:** Soporte para modo claro/oscuro en colores Guinda y Azul  

---

## 🔧 Requisitos del Sistema  

### Versiones Mínimas  
- **Android Studio:** Arctic Fox 2020.3.1 o superior  
- **Gradle:** 7.0+  
- **Android Gradle Plugin:** 7.0.0+  
- **API Mínima:** Android 7.0 (API 24)  
- **API Target:** Android 13 (API 33) o superior  
- **Kotlin:** 1.8.0+  

---

## 📦 Dependencias Principales  

```gradle
// CameraX
implementation "androidx.camera:camera-camera2:1.3.0"
implementation "androidx.camera:camera-lifecycle:1.3.0"
implementation "androidx.camera:camera-view:1.3.0"

// Room Database
implementation "androidx.room:room-runtime:2.5.2"
kapt "androidx.room:room-compiler:2.5.2"

// Lifecycle & ViewModel
implementation "androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.2"
implementation "androidx.lifecycle:lifecycle-livedata-ktx:2.6.2"
