import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/audio_provider.dart';
import 'audio_player_screen.dart';
import 'audio_player_screen_complete.dart';


/// Pantalla de grabación de audio completa
class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Grabación de Audio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.library_music),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: Provider.of<AudioProvider>(context, listen: false),
                    child: const AudioPlayerFullScreen(),
                  ),
                ),
              );
            },
            tooltip: 'Ver grabaciones',
          ),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Visualizador de nivel de audio
                  _buildAudioLevelVisualizer(context, audioProvider),

                  const SizedBox(height: 48),

                  // Temporizador con límite configurable
                  _buildTimer(audioProvider),

                  const SizedBox(height: 48),

                  // Controles de grabación
                  _buildRecordingControls(context, audioProvider),

                  const SizedBox(height: 24),

                  // Información de configuración
                  _buildConfigInfo(audioProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construir visualizador de nivel de audio
  Widget _buildAudioLevelVisualizer(BuildContext context, AudioProvider audioProvider) {
    return SizedBox(
      height: 200,
      child: Center(
        child: audioProvider.isRecording
            ? CustomPaint(
          size: const Size(300, 200),
          painter: AudioWaveformRecordingPainter(
            audioLevel: audioProvider.amplitude,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
            : Icon(
          Icons.mic,
          size: 120,
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Construir temporizador con límite
  Widget _buildTimer(AudioProvider audioProvider) {
    final seconds = audioProvider.recordDuration;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    final limit = audioProvider.recordTimerLimit;
    final hasLimit = limit > 0;
    final limitMinutes = limit ~/ 60;
    final limitSecs = limit % 60;

    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),

        // Mostrar límite si está configurado
        if (hasLimit) ...[
          Text(
            'Límite: ${limitMinutes.toString().padLeft(2, '0')}:${limitSecs.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Barra de progreso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: LinearProgressIndicator(
              value: seconds / limit,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                seconds / limit > 0.9 ? Colors.red : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        Text(
          audioProvider.isRecording
              ? (audioProvider.isPaused ? 'PAUSADO' : 'GRABANDO...')
              : 'Presiona para grabar',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Construir controles de grabación
  Widget _buildRecordingControls(BuildContext context, AudioProvider audioProvider) {
    if (!audioProvider.isRecording) {
      // Botón de iniciar grabación
      return FloatingActionButton.large(
        onPressed: () => audioProvider.startRecording(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.fiber_manual_record, size: 48),
      );
    }

    // Controles durante grabación
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pausar/Reanudar
        FloatingActionButton(
          onPressed: () {
            if (audioProvider.isPaused) {
              audioProvider.resumeRecording();
            } else {
              audioProvider.pauseRecording();
            }
          },
          backgroundColor: Colors.orange,
          child: Icon(
            audioProvider.isPaused ? Icons.play_arrow : Icons.pause,
          ),
        ),

        // Detener y guardar automáticamente
        FloatingActionButton.large(
          onPressed: () async {
            await audioProvider.stopRecording();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Audio guardado automáticamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.stop, size: 48),
        ),
      ],
    );
  }

  /// Construir información de configuración
  Widget _buildConfigInfo(AudioProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoChip(
            icon: Icons.high_quality,
            label: audioProvider.audioQuality.toUpperCase(),
          ),
          _buildInfoChip(
            icon: Icons.audiotrack,
            label: audioProvider.audioFormat.toUpperCase(),
          ),
          if (audioProvider.recordTimerLimit > 0)
            _buildInfoChip(
              icon: Icons.timer,
              label: '${audioProvider.recordTimerLimit}s',
            ),
        ],
      ),
    );
  }

  /// Construir chip de información
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Mostrar diálogo de configuración
  void _showSettingsDialog(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Audio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calidad de audio
              const Text(
                'Calidad de Audio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildQualityOption(context, audioProvider, 'baja', 'Baja (64 kbps)'),
              _buildQualityOption(context, audioProvider, 'media', 'Media (128 kbps)'),
              _buildQualityOption(context, audioProvider, 'alta', 'Alta (192 kbps)'),

              const Divider(height: 32),

              // Temporizador de límite
              const Text(
                'Límite de Grabación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildTimerLimitOption(context, audioProvider, 0, 'Sin límite'),
              _buildTimerLimitOption(context, audioProvider, 30, '30 segundos'),
              _buildTimerLimitOption(context, audioProvider, 60, '1 minuto'),
              _buildTimerLimitOption(context, audioProvider, 180, '3 minutos'),
              _buildTimerLimitOption(context, audioProvider, 300, '5 minutos'),
              _buildTimerLimitOption(context, audioProvider, 600, '10 minutos'),

              const Divider(height: 32),

              // NUEVO: Formato de audio
              const Text(
                'Formato de Audio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildFormatOption(context, audioProvider, 'm4a', 'M4A (Recomendado)'),
              _buildFormatOption(context, audioProvider, 'aac', 'AAC'),
              _buildFormatOption(context, audioProvider, 'mp3', 'MP3'),
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

  /// Construir opción de calidad
  Widget _buildQualityOption(
      BuildContext context,
      AudioProvider audioProvider,
      String value,
      String label,
      ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: audioProvider.audioQuality,
      onChanged: audioProvider.isRecording
          ? null
          : (newValue) {
        if (newValue != null) {
          audioProvider.setAudioQuality(newValue);
        }
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Construir opción de límite de tiempo
  Widget _buildTimerLimitOption(
      BuildContext context,
      AudioProvider audioProvider,
      int seconds,
      String label,
      ) {
    return RadioListTile<int>(
      title: Text(label),
      value: seconds,
      groupValue: audioProvider.recordTimerLimit,
      onChanged: audioProvider.isRecording
          ? null
          : (newValue) {
        if (newValue != null) {
          audioProvider.setRecordTimerLimit(newValue);
        }
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
  /// Construir opción de formato de audio
  Widget _buildFormatOption(
      BuildContext context,
      AudioProvider audioProvider,
      String value,
      String label,
      ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: audioProvider.audioFormat,
      onChanged: audioProvider.isRecording
          ? null
          : (newValue) {
        if (newValue != null) {
          audioProvider.setAudioFormat(newValue);
        }
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Painter personalizado para visualizar forma de onda de audio durante grabación
class AudioWaveformRecordingPainter extends CustomPainter {
  final double audioLevel;
  final Color color;

  AudioWaveformRecordingPainter({
    required this.audioLevel,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = size.height / 2;
    final barWidth = 6.0;
    final spacing = 10.0;
    final barCount = (size.width / (barWidth + spacing)).floor();

    // Normalizar nivel de audio (0-1)
    final normalizedLevel = audioLevel.clamp(0.0, 1.0);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);

      // Altura variable basada en nivel de audio y posición
      final heightFactor = normalizedLevel *
          (0.5 + 0.5 * math.sin(i * 0.5 + DateTime.now().millisecond * 0.01));
      final barHeight = size.height * heightFactor * 0.8;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, center),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(3),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioWaveformRecordingPainter oldDelegate) {
    return oldDelegate.audioLevel != audioLevel;
  }
}