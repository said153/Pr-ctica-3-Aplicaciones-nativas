import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ShareService {
  /// Compartir archivo de imagen
  static Future<void> shareImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(imagePath)], text: 'Foto desde Practica3');
      }
    } catch (e) {
      throw Exception('Error al compartir imagen: $e');
    }
  }

  /// Compartir archivo de audio
  static Future<void> shareAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(audioPath)], text: 'Audio desde Practica3');
      }
    } catch (e) {
      throw Exception('Error al compartir audio: $e');
    }
  }

  /// Compartir múltiples archivos
  static Future<void> shareMultipleFiles(List<String> filePaths) async {
    try {
      final xFiles = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(xFiles, text: 'Archivos desde Practica3');
    } catch (e) {
      throw Exception('Error al compartir archivos: $e');
    }
  }
}