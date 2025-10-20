import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/gallery_provider.dart';
import 'media_detail_screen.dart';

/// Pantalla de búsqueda y filtrado avanzado
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Fecha';
  String _filterType = 'Todos';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAllMedia();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllMedia() async {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    await provider.loadMedia();
    setState(() {
      _searchResults = List.from(provider.mediaFiles);
      _applyFilters();
    });
  }

  void _performSearch(String query) {
    final provider = Provider.of<GalleryProvider>(context, listen: false);

    setState(() {
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _searchResults = List.from(provider.mediaFiles);
      } else {
        _searchResults = provider.mediaFiles.where((media) {
          final name = media['name'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery);
        }).toList();
      }

      _applyFilters();
    });
  }

  void _applyFilters() {
    // Filtrar por tipo
    if (_filterType != 'Todos') {
      final type = _filterType == 'Imágenes' ? 'image' : 'audio';
      _searchResults = _searchResults.where((m) => m['type'] == type).toList();
    }

    // Ordenar
    switch (_sortBy) {
      case 'Fecha':
        _searchResults.sort((a, b) =>
            (b['created_at'] as String).compareTo(a['created_at'] as String)
        );
        break;
      case 'Nombre':
        _searchResults.sort((a, b) =>
            (a['name'] as String).compareTo(b['name'] as String)
        );
        break;
      case 'Tamaño':
        _searchResults.sort((a, b) =>
            (b['size'] as int).compareTo(a['size'] as int)
        );
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Búsqueda'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de filtros y ordenamiento
          _buildFilterBar(),

          // Resultados
          Expanded(
            child: _searchResults.isEmpty
                ? _buildEmptyState()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filtro por tipo
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['Todos', 'Imágenes', 'Audios'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filterType = value!;
                  _applyFilters();
                });
              },
            ),
          ),

          const SizedBox(width: 12),

          // Ordenar por
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: const InputDecoration(
                labelText: 'Ordenar',
                prefixIcon: Icon(Icons.sort),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['Fecha', 'Nombre', 'Tamaño'].map((sort) {
                return DropdownMenuItem(value: sort, child: Text(sort));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearching ? Icons.search_off : Icons.image_not_supported,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching ? 'No se encontraron resultados' : 'No hay archivos',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        // Contador de resultados
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[200],
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_searchResults.length} archivo(s) encontrado(s)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Lista de resultados
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final media = _searchResults[index];
              final isImage = media['type'] == 'image';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: isImage
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(media['path']),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.audiotrack),
                  ),
                  title: Text(
                    media['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${_formatSize(media['size'])} • ${_formatDate(media['created_at'])}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    isImage ? Icons.image : Icons.audiotrack,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MediaDetailScreen(media: media),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}