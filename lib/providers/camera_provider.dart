// lib/providers/camera_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import '../database/database_helper.dart';
import '../services/haptic_feedback_service.dart';

class CameraProvider with ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  int _currentCameraIndex = 0;
  FlashMode _currentFlashMode = FlashMode.off;
  String _currentFilter = 'Ninguno';
  int _timerSeconds = 0;
  bool _isTakingPicture = false;
  bool _isDisposed = false;

  // NUEVO: Control de ráfaga
  bool _burstMode = false;
  int _burstCount = 3; // Número de fotos en ráfaga

  // NUEVO: Cuenta regresiva del temporizador
  int _countdownValue = 0;

  // NUEVO: Formato de imagen (jpeg o png)
  String _imageFormat = 'jpeg'; // 'jpeg' o 'png'

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  int get currentCameraIndex => _currentCameraIndex;
  FlashMode get currentFlashMode => _currentFlashMode;
  String get currentFilter => _currentFilter;
  int get timerSeconds => _timerSeconds;
  bool get isTakingPicture => _isTakingPicture;
  bool get burstMode => _burstMode;
  int get burstCount => _burstCount;
  int get countdownValue => _countdownValue;
  String get imageFormat => _imageFormat;  // ← AGREGAR ESTA LÍNEA

  /// Inicializar la cámara con configuración optimizada
  Future<void> initCamera() async {
    try {
      _isDisposed = false;
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('❌ No hay cámaras disponibles');
        return;
      }

      // Seleccionar cámara trasera por defecto
      _currentCameraIndex = _cameras!.indexWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back
      );
      if (_currentCameraIndex == -1) _currentCameraIndex = 0;

      _controller = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      // Pequeña espera para estabilizar la cámara
      await Future.delayed(const Duration(milliseconds: 300));

      // Configurar flash OFF por defecto
      _currentFlashMode = FlashMode.off;
      await _setFlashMode(FlashMode.off);

      _isInitialized = true;
      notifyListeners();

      debugPrint('✅ Cámara inicializada correctamente');
      debugPrint('   Resolución: ${_controller!.value.previewSize}');
      debugPrint('   Lente: ${_cameras![_currentCameraIndex].lensDirection}');

    } catch (e) {
      debugPrint('❌ Error al inicializar cámara: $e');
      _isInitialized = false;
    }
  }

  /// Método privado para configurar flash con validación
  Future<void> _setFlashMode(FlashMode mode) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Verificar si la cámara actual soporta flash
      final hasFlash = _cameras![_currentCameraIndex].lensDirection == CameraLensDirection.back;

      if (!hasFlash && mode != FlashMode.off) {
        debugPrint('⚠️ Cámara frontal no tiene flash, configurando a OFF');
        mode = FlashMode.off;
      }

      await _controller!.setFlashMode(mode);
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint('📸 Flash configurado: ${_getFlashModeName(mode)}');
    } catch (e) {
      debugPrint('⚠️ Error al configurar flash: $e');
    }
  }

  /// Toggle flash: OFF → AUTO → ALWAYS → OFF
  Future<void> toggleFlashMode() async {
    if (_controller == null || !_isInitialized) return;

    // Verificar si la cámara tiene flash
    final hasFlash = _cameras![_currentCameraIndex].lensDirection == CameraLensDirection.back;

    if (!hasFlash) {
      debugPrint('⚠️ Esta cámara no tiene flash');
      return;
    }

    try {
      switch (_currentFlashMode) {
        case FlashMode.off:
          _currentFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _currentFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _currentFlashMode = FlashMode.off;
          break;
        default:
          _currentFlashMode = FlashMode.off;
      }

      await _setFlashMode(_currentFlashMode);
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Error al cambiar flash: $e');
    }
  }

  /// Cambiar entre cámara frontal y trasera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      debugPrint('⚠️ No hay múltiples cámaras disponibles');
      return;
    }

    try {
      // Apagar flash antes de cambiar
      await _setFlashMode(FlashMode.off);

      // Cambiar índice de cámara
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;

      // Disponer del controlador anterior
      await _controller?.dispose();

      // Crear nuevo controlador
      _controller = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      // Restaurar flash OFF
      _currentFlashMode = FlashMode.off;
      await _setFlashMode(FlashMode.off);

      _isInitialized = true;
      notifyListeners();

      final lensType = _cameras![_currentCameraIndex].lensDirection == CameraLensDirection.front
          ? 'Frontal'
          : 'Trasera';
      debugPrint('✅ Cámara cambiada a: $lensType');

    } catch (e) {
      debugPrint('❌ Error al cambiar cámara: $e');
    }
  }

  /// Establecer filtro
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
    debugPrint('🎨 Filtro seleccionado: $filter');
  }

  /// Establecer temporizador
  void setTimer(int seconds) {
    _timerSeconds = seconds;
    notifyListeners();
    debugPrint('⏱️ Temporizador: $seconds segundos');
  }

  /// NUEVO: Activar/desactivar modo ráfaga
  void toggleBurstMode() {
    _burstMode = !_burstMode;
    notifyListeners();
    debugPrint('📸 Modo ráfaga: ${_burstMode ? "ACTIVADO" : "DESACTIVADO"}');
  }

  /// NUEVO: Establecer cantidad de fotos en ráfaga
  void setBurstCount(int count) {
    _burstCount = count.clamp(2, 10);
    notifyListeners();
  }

  /// NUEVO: Establecer formato de imagen
  void setImageFormat(String format) {
    if (format == 'jpeg' || format == 'png') {
      _imageFormat = format;
      notifyListeners();
      debugPrint('📷 Formato de imagen: ${format.toUpperCase()}');
    }
  }

  /// Aplicar filtro a imagen
  Future<Uint8List> _applyFilter(Uint8List imageBytes, String filterName) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      switch (filterName) {
        case 'Escala de Grises':
          image = img.grayscale(image);
          break;
        case 'Sepia':
          image = img.sepia(image);
          break;
        case 'Brillo +':
          image = img.adjustColor(image, brightness: 1.3);
          break;
        case 'Brillo -':
          image = img.adjustColor(image, brightness: 0.7);
          break;
        case 'Contraste +':
          image = img.adjustColor(image, contrast: 1.3);
          break;
        case 'Contraste -':
          image = img.adjustColor(image, contrast: 0.7);
          break;
        case 'Invertir':
          image = img.invert(image);
          break;
        case 'Desenfoque':
          image = img.gaussianBlur(image, radius: 5);
          break;
        default:
          break;
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: 90));
    } catch (e) {
      debugPrint('❌ Error aplicando filtro: $e');
      return imageBytes;
    }
  }

  /// Capturar foto(s) con todas las mejoras
  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    _isTakingPicture = true;
    notifyListeners();

    try {
      // TEMPORIZADOR CON CUENTA REGRESIVA VISUAL
      if (_timerSeconds > 0) {
        for (int i = _timerSeconds; i > 0; i--) {
          _countdownValue = i;
          notifyListeners();
          await Future.delayed(const Duration(seconds: 1));
        }
        _countdownValue = 0;
        notifyListeners();
      }

      // MODO RÁFAGA
      if (_burstMode) {
        await _takeBurstPhotos();
      } else {
        // CAPTURA ÚNICA
        await _takeSinglePhoto();
      }

      debugPrint('✅ Captura completada exitosamente');

    } catch (e) {
      debugPrint('❌ Error en captura: $e');
      await _setFlashMode(FlashMode.off);
    } finally {
      _isTakingPicture = false;
      _countdownValue = 0;
      notifyListeners();
    }
  }

  /// Capturar una sola foto
  Future<void> _takeSinglePhoto() async {
    // Configurar flash para la captura
    final FlashMode captureFlashMode = _currentFlashMode;
    if (captureFlashMode != FlashMode.off) {
      await _setFlashMode(captureFlashMode);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Capturar foto
    XFile photo = await _controller!.takePicture();

    // NUEVO: Feedback háptico y sonoro
    await HapticFeedbackService.photoCaptureFeedback();

    // Apagar flash inmediatamente
    await _setFlashMode(FlashMode.off);

    // Procesar y guardar
    await _processAndSavePhoto(photo);
  }

  /// NUEVO: Capturar ráfaga de fotos
  Future<void> _takeBurstPhotos() async {
    debugPrint('📸 Iniciando ráfaga de $_burstCount fotos');

    for (int i = 0; i < _burstCount; i++) {
      try {
        // Capturar foto
        XFile photo = await _controller!.takePicture();

        // Procesar en paralelo para mayor velocidad
        _processAndSavePhoto(photo, burstIndex: i + 1);

        // Pequeña pausa entre fotos
        if (i < _burstCount - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }

      } catch (e) {
        debugPrint('❌ Error en foto ${i + 1} de ráfaga: $e');
      }
    }

    debugPrint('✅ Ráfaga completada: $_burstCount fotos');
  }

  /// Procesar y guardar foto
  Future<void> _processAndSavePhoto(XFile photo, {int? burstIndex}) async {
    try {
      // Leer bytes
      Uint8List imageBytes = await photo.readAsBytes();

      // Aplicar filtro si está seleccionado
      if (_currentFilter != 'Ninguno') {
        imageBytes = await _applyFilter(imageBytes, _currentFilter);
      }

      // Generar nombre de archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final burstSuffix = burstIndex != null ? '_burst$burstIndex' : '';
      final extension = _imageFormat == 'png' ? 'png' : 'jpg';
      final filename = 'IMG_$timestamp$burstSuffix.$extension';

      // Guardar en almacenamiento local
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/$filename';
      await File(imagePath).writeAsBytes(imageBytes);
      // Codificar según formato seleccionado
      final Uint8List encodedBytes = _imageFormat == 'png'
          ? Uint8List.fromList(img.encodePng(img.decodeImage(imageBytes)!))
          : imageBytes;

      await File(imagePath).writeAsBytes(encodedBytes);

      // Guardar en galería del sistema con GAL
      await Gal.putImageBytes(imageBytes, album: 'Practica3');

      // Guardar en base de datos
      await DatabaseHelper.instance.insertMedia({
        'path': imagePath,
        'type': 'image',
        'name': filename,
        'created_at': DateTime.now().toIso8601String(),
        'size': imageBytes.length,
        'filter': _currentFilter,
        'album': 'General',
      });

      debugPrint('✅ Foto guardada: $filename (${(imageBytes.length / 1024).toStringAsFixed(2)} KB)');

    } catch (e) {
      debugPrint('❌ Error al procesar foto: $e');
    }
  }

  /// Pausar cámara (cuando se cambia de pantalla)
  Future<void> pauseCamera() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _setFlashMode(FlashMode.off);
        debugPrint('⏸️ Cámara pausada y flash apagado');
      } catch (e) {
        debugPrint('⚠️ Error al pausar cámara: $e');
      }
    }
  }

  /// Reanudar cámara
  Future<void> resumeCamera() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _setFlashMode(FlashMode.off);
        debugPrint('▶️ Cámara reanudada - Flash OFF');
      } catch (e) {
        debugPrint('⚠️ Error al reanudar cámara: $e');
      }
    }
  }

  /// Obtener nombre legible del modo flash
  String _getFlashModeName(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return 'OFF';
      case FlashMode.auto:
        return 'AUTO';
      case FlashMode.always:
        return 'ON';
      default:
        return 'OFF';
    }
  }

  /// Obtener icono del flash
  String getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return '🚫';
      case FlashMode.auto:
        return '⚡';
      case FlashMode.always:
        return '🔆';
      default:
        return '🚫';
    }
  }

  /// Verificar si la cámara actual tiene flash
  bool get hasFlash {
    if (_cameras == null || _cameras!.isEmpty) return false;
    return _cameras![_currentCameraIndex].lensDirection == CameraLensDirection.back;
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Asegurar que el flash esté apagado antes de liberar
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        _controller!.setFlashMode(FlashMode.off);
      } catch (e) {
        debugPrint('⚠️ Error al apagar flash en dispose: $e');
      }
    }

    _controller?.dispose();
    debugPrint('🔴 CameraProvider disposed - Recursos liberados');
    super.dispose();
  }
}