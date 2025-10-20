import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/gallery_provider.dart';
import '../database/database_helper.dart';
import '../providers/audio_provider.dart';
import '../services/exif_service.dart';
import '../services/image_editor_service.dart';
import '../services/share_service.dart';
import 'tag_management_screen.dart';
import 'image_editor_screen.dart'; // ← AGREGAR ESTA LÍNEA

/// Pantalla de detalle de medio (imagen o audio)
class MediaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> media;
  const MediaDetailScreen({super.key, required this.media});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final TransformationController _transformationController = TransformationController();

  bool get isImage => widget.media['type'] == 'image';
  bool get isAudio => widget.media['type'] == 'audio';

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          widget.media['name'],
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (isImage) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openImageEditor(context),
              tooltip: 'Editar imagen',
            ),
          ],

          // BOTÓN COMPARTIR
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareMedia(context),
            tooltip: 'Compartir',
          ),

          // BOTÓN INFORMACIÓN
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'Información',
          ),

          // BOTÓN ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMedia(),
            tooltip: 'Eliminar',
          ),

          IconButton(
            icon: const Icon(Icons.local_offer),
            onPressed: () => _manageTags(context),
            tooltip: 'Gestionar etiquetas',
          ),

        ],
      ),
      body: isImage ? _buildImageViewer() : _buildAudioButton(),
    );
  }

  /// Visor de imagen con zoom
  Widget _buildImageViewer() {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(widget.media['path']),
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('Error al cargar imagen', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Botón para abrir subpantalla de audio
  Widget _buildAudioButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.audiotrack, size: 32),
        label: const Text("Reproducir audio"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: Provider.of<AudioProvider>(context, listen: false),
                child: AudioPlayerScreen(
                  path: widget.media['path'],
                  name: widget.media['name'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _manageTags(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TagManagementScreen(
          mediaId: widget.media['id'],
          mediaName: widget.media['name'],
        ),
      ),
    );
  }

  /// Diálogo de información CON METADATOS EXIF
  void _showInfoDialog() async {
    // Leer metadatos EXIF si es imagen
    Map<String, String> exifData = {};
    if (isImage) {
      exifData = await ExifService.readExifData(widget.media['path']);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del archivo'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Nombre', widget.media['name']),
              _buildInfoRow('Tipo', isImage ? 'Imagen' : 'Audio'),
              _buildInfoRow('Tamaño', _formatSize(widget.media['size'] ?? 0)),
              _buildInfoRow('Fecha', _formatDate(widget.media['created_at'])),

              // METADATOS EXIF PARA IMÁGENES
              if (isImage && exifData.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Metadatos EXIF',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                ...exifData.entries.map((entry) =>
                    _buildInfoRow(entry.key, entry.value)
                ).toList(),
              ],

              // DURACIÓN PARA AUDIOS
              if (widget.media['duration'] != null)
                _buildInfoRow('Duración', _formatDuration(widget.media['duration'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Compartir medio
  void _shareMedia(BuildContext context) async {
    try {
      final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);

      if (galleryProvider.hasSelection) {
        // Compartir múltiples archivos seleccionados
        final selectedPaths = galleryProvider.selectedIndices
            .where((index) => index < galleryProvider.mediaFiles.length)
            .map((index) => galleryProvider.mediaFiles[index]['path'] as String)
            .toList();

        await ShareService.shareMultipleFiles(selectedPaths);
      } else {
        // Compartir archivo individual
        if (isImage) {
          await ShareService.shareImage(widget.media['path']);
        } else {
          await ShareService.shareAudio(widget.media['path']);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Archivo compartido')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al compartir: $e')),
        );
      }
    }
  }

  /// Eliminar medio
  void _deleteMedia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: const Text('¿Estás seguro de eliminar este archivo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final id = widget.media['id'];
              if (id != null) {
                final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
                await DatabaseHelper.instance.deleteMedia(id);
                try {
                  final file = File(widget.media['path']);
                  if (await file.exists()) await file.delete();
                } catch (e) {
                  debugPrint('Error al eliminar archivo: $e');
                }
                await galleryProvider.loadMedia();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Archivo eliminado')),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  void _openImageEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(media: widget.media),
      ),
    );
  }
}

/// -------------------------------------------------------------
/// Subpantalla para reproducir audio - CORREGIDA
/// -------------------------------------------------------------
class AudioPlayerScreen extends StatefulWidget {
  final String path;
  final String name;

  const AudioPlayerScreen({super.key, required this.path, required this.name});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar audio cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.playAudio(widget.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                await ShareService.shareAudio(widget.path);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Audio compartido')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error al compartir: $e')),
                );
              }
            },
            tooltip: 'Compartir audio',
          ),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          // Calcular valores seguros para el slider
          final currentValue = audioProvider.playDuration.toDouble();
          final maxValue = audioProvider.totalDuration > 0
              ? audioProvider.totalDuration.toDouble()
              : 100.0; // Valor por defecto seguro

          final safeValue = currentValue.clamp(0.0, maxValue);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    Icons.audiotrack,
                    size: 100,
                    color: audioProvider.isPlaying ? Colors.green : Colors.grey
                ),

                const SizedBox(height: 24),

                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Controles de reproducción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {},
                    ),

                    IconButton(
                      iconSize: 64,
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        if (audioProvider.isPlaying) {
                          audioProvider.pausePlayback();
                        } else {
                          audioProvider.resumePlayback();
                        }
                      },
                    ),

                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {},
                    ),
                  ],
                ),

                // Barra de progreso - CORREGIDA
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Slider(
                        value: safeValue,
                        min: 0,
                        max: maxValue,
                        onChanged: (value) {
                          audioProvider.seekAudio(value.toInt());
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(audioProvider.formatDuration(audioProvider.playDuration)),
                          Text(
                              audioProvider.totalDuration > 0
                                  ? audioProvider.formatDuration(audioProvider.totalDuration)
                                  : '--:--'
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Estado actual
                const SizedBox(height: 16),
                Text(
                  audioProvider.isPlaying ? '▶️ Reproduciendo...' : '⏸️ Pausado',
                  style: TextStyle(
                    color: audioProvider.isPlaying ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}