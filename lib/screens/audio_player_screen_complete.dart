import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../services/share_service.dart';
import '../database/database_helper.dart';
import 'dart:io';

/// Pantalla de reproducción de audio completa
class AudioPlayerFullScreen extends StatefulWidget {
  const AudioPlayerFullScreen({super.key});

  @override
  State<AudioPlayerFullScreen> createState() => _AudioPlayerFullScreenState();
}

class _AudioPlayerFullScreenState extends State<AudioPlayerFullScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.loadPlaylist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Reproductor de Audio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AudioProvider>(context, listen: false).loadPlaylist();
            },
            tooltip: 'Recargar playlist',
          ),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          if (audioProvider.playlist.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headset_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay audios grabados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Reproductor actual (si hay audio reproduciendo)
              if (audioProvider.currentTrack != null)
                _buildCurrentPlayer(context, audioProvider),

              // Lista de audios
              Expanded(
                child: _buildPlaylist(context, audioProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Reproductor actual con controles completos
  Widget _buildCurrentPlayer(BuildContext context, AudioProvider audioProvider) {
    final track = audioProvider.currentTrack!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Visualización de forma de onda
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: AudioWaveformPainter(
                progress: audioProvider.totalDuration > 0
                    ? audioProvider.playDuration / audioProvider.totalDuration
                    : 0.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          const SizedBox(height: 16),

          // Nombre del audio
          Text(
            track['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Información adicional
          Text(
            '${audioProvider.formatDuration(track['duration'] ?? 0)} • ${_formatSize(track['size'] ?? 0)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          // Barra de progreso
          Column(
            children: [
              Slider(
                value: audioProvider.playDuration.toDouble().clamp(0.0, audioProvider.totalDuration.toDouble()),
                min: 0,
                max: audioProvider.totalDuration > 0 ? audioProvider.totalDuration.toDouble() : 100.0,
                onChanged: (value) {
                  audioProvider.seekAudio(value.toInt());
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(audioProvider.formatDuration(audioProvider.playDuration)),
                    Text(
                      audioProvider.totalDuration > 0
                          ? audioProvider.formatDuration(audioProvider.totalDuration)
                          : '--:--',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Controles de reproducción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Anterior
              IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.skip_previous,
                  color: audioProvider.hasPrevious ? null : Colors.grey,
                ),
                onPressed: audioProvider.hasPrevious
                    ? () => audioProvider.playPrevious()
                    : null,
              ),

              const SizedBox(width: 16),

              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 48,
                  icon: Icon(
                    audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (audioProvider.isPlaying) {
                      audioProvider.pausePlayback();
                    } else {
                      audioProvider.resumePlayback();
                    }
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Siguiente
              IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.skip_next,
                  color: audioProvider.hasNext ? null : Colors.grey,
                ),
                onPressed: audioProvider.hasNext
                    ? () => audioProvider.playNext()
                    : null,
              ),

              const SizedBox(width: 16),

              // Stop
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.stop),
                onPressed: () => audioProvider.stopPlayback(),
                tooltip: 'Detener',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lista de playlist con acciones
  Widget _buildPlaylist(BuildContext context, AudioProvider audioProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: audioProvider.playlist.length,
      itemBuilder: (context, index) {
        final audio = audioProvider.playlist[index];
        final isPlaying = audioProvider.currentTrackIndex == index;

        return Card(
          elevation: isPlaying ? 4 : 1,
          color: isPlaying ? Theme.of(context).colorScheme.primaryContainer : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPlaying
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              child: Icon(
                isPlaying ? Icons.equalizer : Icons.audiotrack,
                color: Colors.white,
              ),
            ),
            title: Text(
              audio['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${audioProvider.formatDuration(audio['duration'] ?? 0)} • ${_formatSize(audio['size'] ?? 0)}',
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'play', child: Text('▶️ Reproducir')),
                const PopupMenuItem(value: 'rename', child: Text('✏️ Renombrar')),
                const PopupMenuItem(value: 'share', child: Text('📤 Compartir')),
                const PopupMenuItem(value: 'tag', child: Text('🏷️ Etiquetas')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ Eliminar')),
              ],
              onSelected: (value) => _handleAudioAction(context, value, audio, audioProvider),
            ),
            onTap: () => audioProvider.playAtIndex(index),
          ),
        );
      },
    );
  }

  void _handleAudioAction(
      BuildContext context,
      String action,
      Map<String, dynamic> audio,
      AudioProvider audioProvider,
      ) async {
    switch (action) {
      case 'play':
        final index = audioProvider.playlist.indexOf(audio);
        audioProvider.playAtIndex(index);
        break;

      case 'rename':
        _showRenameDialog(context, audio);
        break;

      case 'share':
        try {
          await ShareService.shareAudio(audio['path']);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Audio compartido')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Error: $e')),
            );
          }
        }
        break;

      case 'tag':
        _showTagDialog(context, audio);
        break;

      case 'delete':
        _confirmDelete(context, audio, audioProvider);
        break;
    }
  }

  void _showRenameDialog(BuildContext context, Map<String, dynamic> audio) {
    final controller = TextEditingController(text: audio['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar audio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await DatabaseHelper.instance.renameMedia(audio['id'], newName);
                final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                await audioProvider.loadPlaylist();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Renombrado a "$newName"')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTagDialog(BuildContext context, Map<String, dynamic> audio) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar etiqueta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Etiqueta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: DatabaseHelper.instance.getMediaTags(audio['id']),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Wrap(
                    spacing: 8,
                    children: snapshot.data!.map((tag) => Chip(label: Text(tag))).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final tag = controller.text.trim();
              if (tag.isNotEmpty) {
                await DatabaseHelper.instance.addTag(audio['id'], tag);
                controller.clear();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Etiqueta "$tag" agregada')),
                  );
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> audio, AudioProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar audio'),
        content: Text('¿Eliminar "${audio['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final file = File(audio['path']);
                if (await file.exists()) {
                  await file.delete();
                }

                await DatabaseHelper.instance.deleteMedia(audio['id']);
                await audioProvider.loadPlaylist();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Audio eliminado')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Painter para visualización de forma de onda
class AudioWaveformPainter extends CustomPainter {
  final double progress;
  final Color color;

  AudioWaveformPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = 4.0;
    final spacing = 2.0;
    final barCount = (size.width / (barWidth + spacing)).floor();

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final normalizedPos = i / barCount;

      // Altura variable simulando forma de onda
      final heightFactor = 0.3 + 0.7 * (0.5 + 0.5 * (i % 7 - 3.5).abs() / 3.5);
      final barHeight = size.height * heightFactor;

      // Color según progreso
      paint.color = normalizedPos <= progress
          ? color
          : color.withOpacity(0.3);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, size.height / 2),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}