import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import 'dart:io';
import '../services/share_service.dart';
import 'media_detail_screen.dart'; // ✅ AGREGAR ESTA IMPORTACIÓN

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listener para actualizar FAB cuando cambie de tab
    _tabController.addListener(() {
      setState(() {}); // Reconstruir para mostrar/ocultar FAB
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().loadMedia();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📁 Galería', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.image), text: 'Fotos'),
            Tab(icon: Icon(Icons.audiotrack), text: 'Audios'),
            Tab(icon: Icon(Icons.folder), text: 'Álbumes'),
          ],
        ),
        actions: [
          Consumer<GalleryProvider>(
            builder: (context, provider, _) {
              if (provider.hasSelection) {
                return Row(
                  children: [
                    // BOTÓN COMPARTIR SELECCIÓN
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Compartir selección',
                      onPressed: () => _shareSelected(context, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      tooltip: 'Mover a álbum',
                      onPressed: () => _showMoveToAlbumDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                      onPressed: () => _confirmDelete(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancelar',
                      onPressed: () => provider.clearSelection(),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar',
                onPressed: () => provider.loadMedia(),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotosTab(),
          _buildAudiosTab(),
          _buildAlbumsTab(),
        ],
      ),
      // FAB visible solo en tab de Álbumes (índice 2)
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
        onPressed: () => _showCreateAlbumDialog(context),
        icon: const Icon(Icons.create_new_folder),
        label: const Text('Crear Álbum'),
        tooltip: 'Crear nuevo álbum',
      )
          : null,
    );
  }

  /// TAB: Fotos
  Widget _buildPhotosTab() {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        final photos = provider.photos;

        if (photos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay fotos', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            final isSelected = provider.selectedIndices.contains(index);

            return GestureDetector(
              onTap: () => provider.hasSelection
                  ? provider.toggleSelection(index)
                  : _showPhotoDetail(context, photo),
              onLongPress: () => provider.toggleSelection(index),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(photo['path']),
                    fit: BoxFit.cover,
                  ),
                  if (isSelected)
                    Container(
                      color: Colors.blue.withOpacity(0.5),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// TAB: Audios
  Widget _buildAudiosTab() {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        final audios = provider.audios;

        if (audios.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headset_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay audios', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: audios.length,
          itemBuilder: (context, index) {
            final audio = audios[index];
            final duration = audio['duration'] ?? 0;
            final size = (audio['size'] / 1024).toStringAsFixed(2);

            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.audiotrack),
              ),
              title: Text(audio['name']),
              subtitle: Text('$duration seg • $size KB'),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => _showAudioDetail(context, audio),
            );
          },
        );
      },
    );
  }

  /// TAB: Álbumes
  Widget _buildAlbumsTab() {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        if (provider.albums.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay álbumes', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: provider.albums.length,
          itemBuilder: (context, index) {
            final albumName = provider.albums[index];

            return InkWell(
              onTap: () {
                provider.setCurrentAlbum(albumName);
                _tabController.animateTo(0); // Ir a tab de fotos
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<int>(
                  future: provider.getAlbumCount(albumName),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder,
                          size: 64,
                          color: _getAlbumColor(albumName),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          albumName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count archivos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Obtener color para cada álbum
  Color _getAlbumColor(String albumName) {
    switch (albumName) {
      case 'General':
        return Colors.blue;
      case 'Favoritos':
        return Colors.red;
      case 'Trabajo':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  /// Mostrar diálogo para crear álbum
  void _showCreateAlbumDialog(BuildContext context) {
    _albumController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Álbum'),
        content: TextField(
          controller: _albumController,
          decoration: const InputDecoration(
            hintText: 'Nombre del álbum',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final albumName = _albumController.text.trim();
              if (albumName.isNotEmpty) {
                final success = await context.read<GalleryProvider>().createAlbum(albumName);
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Álbum "$albumName" creado')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Error: El álbum ya existe')),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  /// Compartir archivos seleccionados
  void _shareSelected(BuildContext context, GalleryProvider provider) async {
    try {
      final selectedPaths = provider.selectedIndices
          .where((index) => index < provider.mediaFiles.length)
          .map((index) => provider.mediaFiles[index]['path'] as String)
          .toList();

      if (selectedPaths.isNotEmpty) {
        await ShareService.shareMultipleFiles(selectedPaths);
        provider.clearSelection();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${selectedPaths.length} archivos compartidos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al compartir: $e')),
      );
    }
  }

  /// Mostrar diálogo para mover a álbum
  void _showMoveToAlbumDialog(BuildContext context) {
    final provider = context.read<GalleryProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mover a Álbum'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.albums.length,
            itemBuilder: (context, index) {
              final album = provider.albums[index];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(album),
                onTap: () {
                  provider.moveToAlbum(album);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Movido a "$album"')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Confirmar eliminación
  void _confirmDelete(BuildContext context) {
    final provider = context.read<GalleryProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivos'),
        content: Text('¿Eliminar ${provider.selectedIndices.length} archivos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteSelected();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Archivos eliminados')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar detalle de foto
  void _showPhotoDetail(BuildContext context, Map<String, dynamic> photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaDetailScreen(media: photo), // ✅ AHORA ESTÁ DEFINIDO
      ),
    );
  }

  /// Mostrar detalle de audio
  void _showAudioDetail(BuildContext context, Map<String, dynamic> audio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaDetailScreen(media: audio), // ✅ AHORA ESTÁ DEFINIDO
      ),
    );
  }
}