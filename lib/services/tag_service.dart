import '../database/database_helper.dart';

class TagService {
  /// Agregar etiqueta a un medio
  static Future<bool> addTagToMedia(int mediaId, String tag) async {
    try {
      final currentTags = await DatabaseHelper.instance.getMediaTags(mediaId);

      // Evitar duplicados
      if (!currentTags.contains(tag.trim())) {
        currentTags.add(tag.trim());
        await DatabaseHelper.instance.updateMediaTags(mediaId, currentTags);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al agregar etiqueta: $e');
    }
  }

  /// Remover etiqueta de un medio
  static Future<bool> removeTagFromMedia(int mediaId, String tag) async {
    try {
      final currentTags = await DatabaseHelper.instance.getMediaTags(mediaId);
      currentTags.remove(tag);
      await DatabaseHelper.instance.updateMediaTags(mediaId, currentTags);
      return true;
    } catch (e) {
      throw Exception('Error al remover etiqueta: $e');
    }
  }

  /// Obtener todas las etiquetas de la base de datos
  static Future<List<String>> getAllTags() async {
    return await DatabaseHelper.instance.getAllUniqueTags();
  }

  /// Buscar medios por etiqueta
  static Future<List<Map<String, dynamic>>> searchByTag(String tag) async {
    return await DatabaseHelper.instance.searchMediaByTag(tag);
  }
}