import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageEditorService {
  /// Recortar imagen con opción específica
  static Future<String?> cropImage(String imagePath, String cropType) async {
    try {
      print('📄 Iniciando recorte tipo $cropType: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe');
      }

      String? newPath;
      switch (cropType) {
        case 'square':
          newPath = await _cropToSquare(file);
          break;
        case 'portrait':
          newPath = await _cropToPortrait(file);
          break;
        case 'landscape':
          newPath = await _cropToLandscape(file);
          break;
        case 'custom':
          newPath = await _cropCustom(file);
          break;
      }

      return newPath;
    } catch (e) {
      print('❌ Error en cropImage: $e');
      return null;
    }
  }

  /// Recortar a cuadrado (centrado)
  static Future<String?> _cropToSquare(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final size = math.min(image.width, image.height);
      final x = (image.width - size) ~/ 2;
      final y = (image.height - size) ~/ 2;

      final croppedImage = img.copyCrop(
          image,
          x: x,
          y: y,
          width: size,
          height: size
      );

      return _saveCroppedImage(croppedImage, 'square');
    } catch (e) {
      print('❌ Error en _cropToSquare: $e');
      return null;
    }
  }

  /// Recortar a formato retrato (9:16)
  static Future<String?> _cropToPortrait(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final targetRatio = 9.0 / 16.0;
      int width, height, x, y;

      if (image.width / image.height > targetRatio) {
        height = image.height;
        width = (height * targetRatio).round();
        x = (image.width - width) ~/ 2;
        y = 0;
      } else {
        width = image.width;
        height = (width / targetRatio).round();
        x = 0;
        y = (image.height - height) ~/ 2;
      }

      final croppedImage = img.copyCrop(image, x: x, y: y, width: width, height: height);
      return _saveCroppedImage(croppedImage, 'portrait');
    } catch (e) {
      print('❌ Error en _cropToPortrait: $e');
      return null;
    }
  }

  /// Recortar a formato paisaje (16:9)
  static Future<String?> _cropToLandscape(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final targetRatio = 16.0 / 9.0;
      int width, height, x, y;

      if (image.width / image.height > targetRatio) {
        height = image.height;
        width = (height * targetRatio).round();
        x = (image.width - width) ~/ 2;
        y = 0;
      } else {
        width = image.width;
        height = (width / targetRatio).round();
        x = 0;
        y = (image.height - height) ~/ 2;
      }

      final croppedImage = img.copyCrop(image, x: x, y: y, width: width, height: height);
      return _saveCroppedImage(croppedImage, 'landscape');
    } catch (e) {
      print('❌ Error en _cropToLandscape: $e');
      return null;
    }
  }

  /// Recorte personalizado (recorta un 20% de cada borde)
  static Future<String?> _cropCustom(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final marginX = (image.width * 0.2).round();
      final marginY = (image.height * 0.2).round();

      final width = image.width - (2 * marginX);
      final height = image.height - (2 * marginY);

      final croppedImage = img.copyCrop(
          image,
          x: marginX,
          y: marginY,
          width: width,
          height: height
      );

      return _saveCroppedImage(croppedImage, 'custom');
    } catch (e) {
      print('❌ Error en _cropCustom: $e');
      return null;
    }
  }

  /// Guardar imagen recortada
  static Future<String> _saveCroppedImage(img.Image croppedImage, String type) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String filename = 'IMG_${timestamp}_${type}.jpg';
    final String newPath = '${appDir.path}/$filename';

    await File(newPath).writeAsBytes(img.encodeJpg(croppedImage, quality: 90));
    print('✅ Imagen recortada guardada: $newPath');

    return newPath;
  }

  /// Rotar imagen
  static Future<String?> rotateImage(String imagePath, int degrees) async {
    try {
      print('🔄 Rotando imagen $degrees grados: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe');
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final rotatedImage = img.copyRotate(image, angle: degrees);

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = 'IMG_${timestamp}_rotated.jpg';
      final String newPath = '${appDir.path}/$filename';

      await File(newPath).writeAsBytes(img.encodeJpg(rotatedImage, quality: 90));
      print('✅ Imagen rotada guardada: $newPath');

      return newPath;
    } catch (e) {
      print('❌ Error en rotateImage: $e');
      return null;
    }
  }
}