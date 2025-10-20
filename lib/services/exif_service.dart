import 'package:exif/exif.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class ExifService {
  /// Leer metadatos EXIF de una imagen
  static Future<Map<String, String>> readExifData(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      final data = await readExifFromBytes(bytes);

      final exifInfo = <String, String>{};

      // Información básica de la cámara
      if (data.containsKey('Image Make')) {
        exifInfo['Marca'] = data['Image Make']!.toString();
      }
      if (data.containsKey('Image Model')) {
        exifInfo['Modelo'] = data['Image Model']!.toString();
      }

      // Configuración de la cámara
      if (data.containsKey('EXIF FNumber')) {
        exifInfo['Apertura'] = _parseAperture(data['EXIF FNumber']!.toString());
      }
      if (data.containsKey('EXIF ExposureTime')) {
        exifInfo['Velocidad'] = _parseExposure(data['EXIF ExposureTime']!.toString());
      }
      if (data.containsKey('EXIF ISOSpeedRatings')) {
        exifInfo['ISO'] = data['EXIF ISOSpeedRatings']!.toString();
      }
      if (data.containsKey('EXIF FocalLength')) {
        exifInfo['Distancia Focal'] = '${data['EXIF FocalLength']!.toString()}mm';
      }

      // Fecha y hora
      if (data.containsKey('EXIF DateTimeOriginal')) {
        exifInfo['Fecha'] = _formatExifDate(data['EXIF DateTimeOriginal']!.toString());
      }

      // Dimensión de la imagen
      final image = img.decodeImage(bytes);
      if (image != null) {
        exifInfo['Dimensiones'] = '${image.width} × ${image.height}';
        exifInfo['Tamaño'] = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
      }

      return exifInfo;
    } catch (e) {
      return {'Error': 'No se pudieron leer los metadatos EXIF'};
    }
  }

  static String _parseAperture(String aperture) {
    try {
      final parts = aperture.split('/');
      if (parts.length == 2) {
        final value = int.parse(parts[0]) / int.parse(parts[1]);
        return 'f/${value.toStringAsFixed(1)}';
      }
      return aperture;
    } catch (e) {
      return aperture;
    }
  }

  static String _parseExposure(String exposure) {
    try {
      final parts = exposure.split('/');
      if (parts.length == 2) {
        final value = int.parse(parts[0]) / int.parse(parts[1]);
        return value >= 1 ? '${value.toStringAsFixed(0)}s' : '1/${(1/value).toStringAsFixed(0)}s';
      }
      return exposure;
    } catch (e) {
      return exposure;
    }
  }

  static String _formatExifDate(String date) {
    try {
      // Formato: "2024:01:15 14:30:25"
      final formatted = date.replaceAll(':', '-').replaceFirst(' ', ' ');
      return formatted;
    } catch (e) {
      return date;
    }
  }
}