// lib/services/export_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

/// Servicio para exportación masiva de archivos
class ExportService {
  /// Exportar múltiples archivos mediante compartir
  static Future<bool> exportFiles(List<String> filePaths) async {
    try {
      if (filePaths.isEmpty) {
        debugPrint('⚠️ No hay archivos para exportar');
        return false;
      }

      // Verificar que los archivos existan
      final validFiles = <XFile>[];
      for (final path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          validFiles.add(XFile(path));
        }
      }

      if (validFiles.isEmpty) {
        debugPrint('⚠️ No se encontraron archivos válidos');
        return false;
      }

      // Compartir archivos
      await Share.shareXFiles(
        validFiles,
        subject: 'Exportación de Practica3',
        text: 'Compartiendo ${validFiles.length} archivo(s)',
      );

      debugPrint('✅ Exportados ${validFiles.length} archivos');
      return true;
    } catch (e) {
      debugPrint('❌ Error al exportar: $e');
      return false;
    }
  }

  /// Crear archivo ZIP (requeriría dependencia adicional)
  /// Por ahora, compartimos directamente los archivos
  static Future<String?> createBackup(List<String> filePaths) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory('${directory.path}/Practica3_Backup_$timestamp');
      await backupDir.create(recursive: true);

      int copiedCount = 0;
      for (final path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          final filename = path.split('/').last;
          final newPath = '${backupDir.path}/$filename';
          await file.copy(newPath);
          copiedCount++;
        }
      }

      debugPrint('✅ Backup creado: ${backupDir.path} ($copiedCount archivos)');
      return backupDir.path;
    } catch (e) {
      debugPrint('❌ Error al crear backup: $e');
      return null;
    }
  }

  /// Obtener estadísticas de archivos
  static Future<Map<String, dynamic>> getStorageStats(
      List<Map<String, dynamic>> mediaFiles,
      ) async {
    int totalSize = 0;
    int imageCount = 0;
    int audioCount = 0;
    int imageSize = 0;
    int audioSize = 0;

    for (final media in mediaFiles) {
      final size = media['size'] as int? ?? 0;
      totalSize += size;

      if (media['type'] == 'image') {
        imageCount++;
        imageSize += size;
      } else if (media['type'] == 'audio') {
        audioCount++;
        audioSize += size;
      }
    }

    return {
      'totalFiles': mediaFiles.length,
      'totalSize': totalSize,
      'imageCount': imageCount,
      'audioCount': audioCount,
      'imageSize': imageSize,
      'audioSize': audioSize,
    };
  }

  /// Formatear tamaño en bytes
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}