import 'package:flutter/services.dart';

class CameraXService {
  static const MethodChannel _channel = MethodChannel('com.practica3/camerax');

  /// Inicializar CameraX
  static Future<void> initializeCameraX() async {
    try {
      await _channel.invokeMethod('initializeCameraX');
    } catch (e) {
      throw Exception('Error al inicializar CameraX: $e');
    }
  }

  /// Tomar foto con CameraX
  static Future<String?> takePicture() async {
    try {
      final String? imagePath = await _channel.invokeMethod('takePicture');
      return imagePath;
    } catch (e) {
      throw Exception('Error al tomar foto: $e');
    }
  }

  /// Cambiar flash
  static Future<void> setFlashMode(String mode) async {
    try {
      await _channel.invokeMethod('setFlashMode', {'mode': mode});
    } catch (e) {
      throw Exception('Error al cambiar flash: $e');
    }
  }

  /// Cambiar cámara
  static Future<void> switchCamera() async {
    try {
      await _channel.invokeMethod('switchCamera');
    } catch (e) {
      throw Exception('Error al cambiar cámara: $e');
    }
  }

  /// Obtener ID de la vista nativa
  static Future<int> getCameraViewId() async {
    try {
      final int viewId = await _channel.invokeMethod('getCameraViewId');
      return viewId;
    } catch (e) {
      throw Exception('Error al obtener vista: $e');
    }
  }
}