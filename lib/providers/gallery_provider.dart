// lib/providers/gallery_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class GalleryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _mediaFiles = [];
  List<String> _albums = ['General'];
  String _currentAlbum = 'Todos';
  String _sortBy = 'Fecha';
  List<int> _selectedIndices = [];

  List<Map<String, dynamic>> get mediaFiles => _mediaFiles;
  List<String> get albums => _albums;
  String get currentAlbum => _currentAlbum;
  String get sortBy => _sortBy;
  List<int> get selectedIndices => _selectedIndices;
  bool get hasSelection => _selectedIndices.isNotEmpty;

  GalleryProvider() {
    _loadAlbumsFromPrefs();
  }

  Future<void> loadMedia() async {
    try {
      final results = await DatabaseHelper.instance.getAllMedia();

      // Crear copias mutables para evitar problemas con listas inmutables
      _mediaFiles = results.map((map) => Map<String, dynamic>.from(map)).toList();

      await _loadAlbums();
      _applySorting();
      notifyListeners();
      debugPrint('✅ ${_mediaFiles.length} archivos cargados');
    } catch (e) {
      debugPrint('❌ Error al cargar media: $e');
      _mediaFiles = [];
    }
  }

  Future<void> _loadAlbums() async {
    try {
      await _loadAlbumsFromPrefs();

      final dbAlbums = await DatabaseHelper.instance.getAllAlbums();

      for (var album in dbAlbums) {
        if (!_albums.contains(album)) {
          _albums.add(album);
        }
      }

      _albums.sort();
      await _saveAlbumsToPrefs();

      debugPrint('✅ Álbumes: $_albums');
    } catch (e) {
      debugPrint('❌ Error álbumes: $e');
      _albums = ['General'];
    }
  }

  Future<bool> createAlbum(String albumName) async {
    try {
      final name = albumName.trim();

      if (name.isEmpty) {
        debugPrint('❌ Nombre vacío');
        return false;
      }

      if (_albums.contains(name)) {
        debugPrint('❌ Álbum "$name" ya existe');
        return false;
      }

      _albums.add(name);
      _albums.sort();

      await _saveAlbumsToPrefs();

      notifyListeners();
      debugPrint('✅ Álbum "$name" creado y guardado');
      return true;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }

  Future<void> _saveAlbumsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('albums', _albums);
      debugPrint('💾 Álbumes guardados: $_albums');
    } catch (e) {
      debugPrint('❌ Error al guardar álbumes: $e');
    }
  }

  Future<void> _loadAlbumsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAlbums = prefs.getStringList('albums');

      if (savedAlbums != null && savedAlbums.isNotEmpty) {
        _albums = savedAlbums;
        debugPrint('📂 Álbumes cargados desde preferencias: $_albums');
      } else {
        _albums = ['General'];
        await _saveAlbumsToPrefs();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al cargar álbumes: $e');
      _albums = ['General'];
    }
  }

  Future<void> moveToAlbum(String albumName) async {
    try {
      if (_selectedIndices.isEmpty) return;

      for (int index in _selectedIndices) {
        if (index < _mediaFiles.length) {
          final media = _mediaFiles[index];
          final id = media['id'];

          await DatabaseHelper.instance.updateMedia(id, {
            'album': albumName,
          });
        }
      }

      clearSelection();
      await loadMedia();
      debugPrint('✅ Archivos movidos a "$albumName"');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  void setCurrentAlbum(String album) {
    _currentAlbum = album;
    _filterByAlbum();
    notifyListeners();
  }

  void _filterByAlbum() async {
    if (_currentAlbum == 'Todos') {
      await loadMedia();
    } else {
      try {
        final results = await DatabaseHelper.instance.getMediaByAlbum(_currentAlbum);
        _mediaFiles = results.map((map) => Map<String, dynamic>.from(map)).toList();
        _applySorting();
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error: $e');
      }
    }
  }

  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    _applySorting();
    notifyListeners();
  }

  void _applySorting() {
    switch (_sortBy) {
      case 'Fecha':
        _mediaFiles.sort((a, b) =>
            (b['created_at'] as String).compareTo(a['created_at'] as String)
        );
        break;
      case 'Nombre':
        _mediaFiles.sort((a, b) =>
            (a['name'] as String).compareTo(b['name'] as String)
        );
        break;
      case 'Tamaño':
        _mediaFiles.sort((a, b) =>
            (b['size'] as int).compareTo(a['size'] as int)
        );
        break;
      case 'Tipo':
        _mediaFiles.sort((a, b) =>
            (a['type'] as String).compareTo(b['type'] as String)
        );
        break;
    }
  }

  void searchMedia(String query) {
    if (query.isEmpty) {
      loadMedia();
      return;
    }

    _mediaFiles = _mediaFiles.where((media) {
      final name = (media['name'] as String).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    notifyListeners();
  }

  void toggleSelection(int index) {
    if (_selectedIndices.contains(index)) {
      _selectedIndices.remove(index);
    } else {
      _selectedIndices.add(index);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIndices = List.generate(_mediaFiles.length, (index) => index);
    notifyListeners();
  }

  void clearSelection() {
    _selectedIndices.clear();
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    try {
      for (int index in _selectedIndices.reversed) {
        if (index < _mediaFiles.length) {
          final media = _mediaFiles[index];
          final id = media['id'];
          final path = media['path'];

          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }

          await DatabaseHelper.instance.deleteMedia(id);
        }
      }

      clearSelection();
      await loadMedia();
      debugPrint('✅ Archivos eliminados');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  List<Map<String, dynamic>> get photos {
    return _mediaFiles.where((m) => m['type'] == 'image').toList();
  }

  List<Map<String, dynamic>> get audios {
    return _mediaFiles.where((m) => m['type'] == 'audio').toList();
  }

  Future<int> getAlbumCount(String album) async {
    if (album == 'Todos') {
      return _mediaFiles.length;
    }
    return await DatabaseHelper.instance.countMediaInAlbum(album);
  }

  Future<void> renameMedia(int id, String newName) async {
    try {
      await DatabaseHelper.instance.renameMedia(id, newName);
      await loadMedia();
      debugPrint('✅ Renombrado a "$newName"');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> addTagToMedia(int mediaId, String tag) async {
    try {
      await DatabaseHelper.instance.addTag(mediaId, tag);
      await loadMedia();
      debugPrint('✅ Etiqueta "$tag" agregada al medio $mediaId');
    } catch (e) {
      debugPrint('❌ Error al agregar etiqueta: $e');
      rethrow;
    }
  }

  /// Obtener etiquetas de un medio
  Future<List<String>> getMediaTags(int mediaId) async {
    return await DatabaseHelper.instance.getMediaTags(mediaId);
  }

  /// Buscar por etiqueta
  Future<List<Map<String, dynamic>>> searchByTag(String tag) async {
    return await DatabaseHelper.instance.searchMediaByTag(tag);
  }

  /// Obtener todas las etiquetas únicas
  Future<List<String>> getAllTags() async {
    return await DatabaseHelper.instance.getAllUniqueTags();
  }
}
