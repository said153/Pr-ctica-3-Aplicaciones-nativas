import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Helper para gestionar la base de datos SQLite local
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtener instancia de base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('practica3.db');
    return _database!;
  }

  /// Inicializar base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementado para migración
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Crear tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    // CORREGIDO: Tabla de medios con campo 'album'
    await db.execute('''
      CREATE TABLE media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        size INTEGER,
        duration INTEGER,
        filter TEXT,
        quality TEXT,
        album TEXT DEFAULT 'General',
        latitude REAL,
        longitude REAL,
        tags TEXT
      )
    ''');

    debugPrint('✅ Base de datos creada con tabla media (incluye campo album)');
  }

  /// Actualizar base de datos (migración)
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columna 'album' si no existe
      try {
        await db.execute('ALTER TABLE media ADD COLUMN album TEXT DEFAULT "General"');
        debugPrint('✅ Columna album agregada a la tabla media');
      } catch (e) {
        debugPrint('⚠️ Columna album ya existe o error: $e');
      }
    }
  }

  // ========== OPERACIONES DE MEDIOS ==========

  /// CORREGIDO: Insertar nuevo medio con validación
  Future<int> insertMedia(Map<String, dynamic> media) async {
    try {
      final db = await database;

      // Asegurar que tenga álbum por defecto
      if (!media.containsKey('album') || media['album'] == null) {
        media['album'] = 'General';
      }

      final id = await db.insert('media', media);
      debugPrint('✅ Media insertado con ID: $id');
      debugPrint('   Tipo: ${media['type']}, Nombre: ${media['name']}, Álbum: ${media['album']}');
      return id;
    } catch (e) {
      debugPrint('❌ Error al insertar media: $e');
      rethrow;
    }
  }

  /// Obtener todos los medios
  Future<List<Map<String, dynamic>>> getAllMedia() async {
    try {
      final db = await database;
      final results = await db.query('media', orderBy: 'created_at DESC');
      debugPrint('✅ ${results.length} medios cargados de la base de datos');
      return results;
    } catch (e) {
      debugPrint('❌ Error al obtener medios: $e');
      return [];
    }
  }

  /// Obtener medio por ID
  Future<Map<String, dynamic>?> getMedia(int id) async {
    final db = await database;
    final results = await db.query(
      'media',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// CORREGIDO: Actualizar medio con validación
  Future<int> updateMedia(int id, Map<String, dynamic> media) async {
    try {
      final db = await database;
      final count = await db.update(
        'media',
        media,
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Media $id actualizado: $media');
      return count;
    } catch (e) {
      debugPrint('❌ Error al actualizar media: $e');
      return 0;
    }
  }

  /// Actualizar nombre de medio
  Future<int> updateMediaName(int id, String name) async {
    final db = await database;
    return await db.update(
      'media',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// CORREGIDO: Actualizar etiquetas (agregar nueva etiqueta)
  Future<int> addTag(int id, String newTag) async {
    try {
      final db = await database;

      // Obtener tags actuales
      final media = await getMedia(id);
      if (media == null) return 0;

      final currentTags = media['tags'] as String?;
      final tagsList = currentTags?.split(',').where((t) => t.isNotEmpty).toList() ?? [];

      // Agregar nueva etiqueta si no existe
      if (!tagsList.contains(newTag.trim())) {
        tagsList.add(newTag.trim());
      }

      final updatedTags = tagsList.join(',');

      final count = await db.update(
        'media',
        {'tags': updatedTags},
        where: 'id = ?',
        whereArgs: [id],
      );

      debugPrint('✅ Etiqueta "$newTag" agregada al media $id');
      return count;
    } catch (e) {
      debugPrint('❌ Error al agregar etiqueta: $e');
      return 0;
    }
  }

  /// Actualizar todas las etiquetas de medio
  Future<int> updateMediaTags(int id, List<String> tags) async {
    final db = await database;
    return await db.update(
      'media',
      {'tags': tags.join(',')},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Eliminar medio
  Future<int> deleteMedia(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'media',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('✅ Media $id eliminado');
      return count;
    } catch (e) {
      debugPrint('❌ Error al eliminar media: $e');
      return 0;
    }
  }

  /// Buscar medios por nombre o etiquetas
  Future<List<Map<String, dynamic>>> searchMedia(String query) async {
    final db = await database;
    return await db.query(
      'media',
      where: 'name LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
  }

  /// CORREGIDO: Obtener todos los álbumes únicos
  Future<List<String>> getAllAlbums() async {
    try {
      final db = await database;
      final results = await db.rawQuery('''
        SELECT DISTINCT album 
        FROM media 
        WHERE album IS NOT NULL AND album != ""
        ORDER BY album ASC
      ''');

      final albums = results.map((row) => row['album'] as String).toList();

      // Asegurar que 'General' siempre esté presente
      if (!albums.contains('General')) {
        albums.insert(0, 'General');
      }

      debugPrint('✅ Álbumes encontrados: $albums');
      return albums;
    } catch (e) {
      debugPrint('❌ Error al obtener álbumes: $e');
      return ['General'];
    }
  }

  /// CORREGIDO: Obtener medios de un álbum específico
  Future<List<Map<String, dynamic>>> getMediaByAlbum(String albumName) async {
    try {
      final db = await database;
      final results = await db.query(
        'media',
        where: 'album = ?',
        whereArgs: [albumName],
        orderBy: 'created_at DESC',
      );
      debugPrint('✅ ${results.length} medios en álbum "$albumName"');
      return results;
    } catch (e) {
      debugPrint('❌ Error al obtener medios del álbum: $e');
      return [];
    }
  }

  /// CORREGIDO: Contar medios por álbum
  Future<int> countMediaInAlbum(String albumName) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM media 
        WHERE album = ?
      ''', [albumName]);

      final count = Sqflite.firstIntValue(result) ?? 0;
      return count;
    } catch (e) {
      debugPrint('❌ Error al contar medios: $e');
      return 0;
    }
  }

  /// Obtener todas las etiquetas únicas
  Future<List<String>> getAllTags() async {
    final db = await database;
    final results = await db.query(
      'media',
      columns: ['tags'],
      where: 'tags IS NOT NULL AND tags != ""',
    );

    final tagsSet = <String>{};
    for (final row in results) {
      final tags = (row['tags'] as String).split(',');
      tagsSet.addAll(tags.where((t) => t.isNotEmpty));
    }

    return tagsSet.toList()..sort();
  }

  /// CORREGIDO: Verificar si existe un álbum
  Future<bool> albumExists(String albumName) async {
    try {
      final albums = await getAllAlbums();
      return albums.contains(albumName);
    } catch (e) {
      debugPrint('❌ Error al verificar álbum: $e');
      return false;
    }
  }

  /// NUEVO: Renombrar medio
  Future<int> renameMedia(int id, String newName) async {
    return await updateMediaName(id, newName);
  }

  /// Cerrar base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// NUEVO: Limpiar base de datos (para pruebas)
  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete('media');
      debugPrint('✅ Base de datos limpiada');
    } catch (e) {
      debugPrint('❌ Error al limpiar base de datos: $e');
    }
  }

  /// NUEVO: Debug - Mostrar contenido de la base de datos
  Future<void> debugPrintDatabase() async {
    try {
      final db = await database;
      final results = await db.query('media');
      debugPrint('═══════════════════════════════════════');
      debugPrint('📊 CONTENIDO DE LA BASE DE DATOS');
      debugPrint('═══════════════════════════════════════');
      debugPrint('Total de registros: ${results.length}');
      for (var media in results) {
        debugPrint('---');
        debugPrint('ID: ${media['id']}');
        debugPrint('Nombre: ${media['name']}');
        debugPrint('Tipo: ${media['type']}');
        debugPrint('Álbum: ${media['album']}');
        debugPrint('Fecha: ${media['created_at']}');
      }
      debugPrint('═══════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ Error al mostrar base de datos: $e');
    }
  }

  /// Obtener todas las etiquetas únicas de un medio
  Future<List<String>> getMediaTags(int mediaId) async {
    final db = await database;
    final media = await getMedia(mediaId);
    if (media == null || media['tags'] == null) return [];

    final tagsString = media['tags'] as String;
    return tagsString.split(',').where((tag) => tag.isNotEmpty).toList();
  }

  /// Buscar medios por etiqueta
  Future<List<Map<String, dynamic>>> searchMediaByTag(String tag) async {
    final db = await database;
    return await db.query(
      'media',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'created_at DESC',
    );
  }

  /// Obtener todas las etiquetas únicas en la base de datos
  Future<List<String>> getAllUniqueTags() async {
    final db = await database;
    final results = await db.query(
      'media',
      columns: ['tags'],
      where: 'tags IS NOT NULL AND tags != ""',
    );

    final tagsSet = <String>{};
    for (final row in results) {
      final tags = (row['tags'] as String).split(',');
      tagsSet.addAll(tags.where((t) => t.isNotEmpty));
    }

    return tagsSet.toList()..sort();
  }
}