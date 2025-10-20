// lib/services/haptic_feedback_service.dart
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Servicio para feedback háptico y sonoro
class HapticFeedbackService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Vibración ligera (para botones)
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silenciar errores en dispositivos sin vibración
    }
  }

  /// Vibración media (para acciones importantes)
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Vibración fuerte (para acciones críticas)
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Vibración de selección (para cambios en UI)
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Vibración de éxito
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Vibración de error
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Sonido de captura de cámara
  static Future<void> playCameraShutter() async {
    try {
      // Generar sonido de cámara con frecuencia
      await _playBeep(800, 50);
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Sonido de click
  static Future<void> playClick() async {
    try {
      await _playBeep(1000, 30);
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Sonido de éxito
  static Future<void> playSuccess() async {
    try {
      await _playBeep(800, 50);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playBeep(1000, 50);
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Sonido de error
  static Future<void> playError() async {
    try {
      await _playBeep(400, 100);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playBeep(300, 100);
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Sonido de beep simple (helper)
  static Future<void> _playBeep(int frequency, int duration) async {
    // Nota: Para sonidos más realistas, necesitarías archivos de audio
    // Por ahora, usamos vibración como alternativa
    await HapticFeedback.selectionClick();
  }

  /// Feedback completo al tomar foto (vibración + sonido)
  static Future<void> photoCaptureFeedback() async {
    try {
      // Vibración característica de cámara
      await HapticFeedback.mediumImpact();
      await playCameraShutter();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Feedback completo de botón
  static Future<void> buttonFeedback() async {
    try {
      await HapticFeedback.lightImpact();
      await playClick();
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Feedback de inicio de grabación
  static Future<void> recordStartFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
      await _playBeep(600, 100);
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Feedback de detención de grabación
  static Future<void> recordStopFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
      await _playBeep(500, 80);
    } catch (e) {
      // Silenciar errores
    }
  }

  /// Dispose del audio player
  static void dispose() {
    _audioPlayer.dispose();
  }
}