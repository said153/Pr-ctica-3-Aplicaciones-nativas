import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import '../providers/gallery_provider.dart';
import '../services/haptic_feedback_service.dart';

/// Pantalla de cámara con previsualización y controles mejorados
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CameraProvider>(context, listen: false).initCamera();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<CameraProvider>(context, listen: false).pauseCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);

    switch (state) {
      case AppLifecycleState.paused:
        cameraProvider.pauseCamera();
        debugPrint('📱 App pausada - Flash apagado');
        break;
      case AppLifecycleState.resumed:
        cameraProvider.resumeCamera();
        debugPrint('📱 App reanudada');
        break;
      case AppLifecycleState.inactive:
        cameraProvider.pauseCamera();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, _) {
          if (!cameraProvider.isInitialized ||
              cameraProvider.controller == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Previsualización de cámara
              Center(
                child: CameraPreview(cameraProvider.controller!),
              ),

              // NUEVO: Overlay de cuenta regresiva del temporizador
              if (cameraProvider.countdownValue > 0)
                _buildCountdownOverlay(cameraProvider.countdownValue),

              // Controles superiores
              _buildTopControls(context, cameraProvider),

              // Controles inferiores
              _buildBottomControls(context, cameraProvider),

              // NUEVO: Indicador de modo ráfaga
              if (cameraProvider.burstMode)
                _buildBurstModeIndicator(cameraProvider),
            ],
          );
        },
      ),
    );
  }

  /// NUEVO: Overlay de cuenta regresiva grande
  Widget _buildCountdownOverlay(int countdown) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.0 + (0.5 * value),
              child: Opacity(
                opacity: 1.0 - (value * 0.3),
                child: Text(
                  '$countdown',
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// NUEVO: Indicador de modo ráfaga
  Widget _buildBurstModeIndicator(CameraProvider provider) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.burst_mode, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'RÁFAGA x${provider.burstCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir controles superiores
  Widget _buildTopControls(BuildContext context,
      CameraProvider cameraProvider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Control de flash
                _buildControlButton(
                  icon: _getFlashIcon(cameraProvider.currentFlashMode),
                  label: _getFlashLabel(cameraProvider.currentFlashMode),
                  onPressed: cameraProvider.hasFlash
                      ? () => cameraProvider.toggleFlashMode()
                      : null,
                  enabled: cameraProvider.hasFlash,
                ),

                // Temporizador
                _buildControlButton(
                  icon: Icons.timer,
                  label: cameraProvider.timerSeconds > 0
                      ? '${cameraProvider.timerSeconds}s'
                      : null,
                  onPressed: () => _showTimerDialog(context, cameraProvider),
                ),

                // Cambiar cámara
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  onPressed: () => cameraProvider.switchCamera(),
                ),

                // NUEVO: Modo ráfaga
                _buildControlButton(
                  icon: Icons.burst_mode,
                  label: cameraProvider.burstMode ? 'ON' : null,
                  onPressed: () => _showBurstDialog(context, cameraProvider),
                  highlighted: cameraProvider.burstMode,
                ),

                // NUEVO: Formato de imagen
                _buildControlButton(
                  icon: Icons.image,
                  label: cameraProvider.imageFormat.toUpperCase(),
                  onPressed: () => _showFormatDialog(context, cameraProvider),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Fila de filtros mejorada
            _buildFiltersRow(context, cameraProvider),
          ],
        ),
      ),
    );
  }

  /// Construir fila de filtros con scroll horizontal
  Widget _buildFiltersRow(BuildContext context, CameraProvider cameraProvider) {
    final filters = [
      {'name': 'Ninguno', 'value': 'Ninguno', 'icon': Icons.filter_none},
      {
        'name': 'Grises',
        'value': 'Escala de Grises',
        'icon': Icons.filter_b_and_w
      },
      {'name': 'Sepia', 'value': 'Sepia', 'icon': Icons.filter_vintage},
      {'name': 'Brillo +', 'value': 'Brillo +', 'icon': Icons.brightness_high},
      {'name': 'Brillo -', 'value': 'Brillo -', 'icon': Icons.brightness_low},
      {'name': 'Contraste +', 'value': 'Contraste +', 'icon': Icons.contrast},
      {'name': 'Contraste -', 'value': 'Contraste -', 'icon': Icons.contrast},
      {'name': 'Invertir', 'value': 'Invertir', 'icon': Icons.invert_colors},
      {'name': 'Desenfoque', 'value': 'Desenfoque', 'icon': Icons.blur_on},
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = cameraProvider.currentFilter == filter['value'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              avatar: Icon(
                filter['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              label: Text(filter['name'] as String),
              selected: isSelected,
              onSelected: (_) =>
                  cameraProvider.setFilter(filter['value'] as String),
              backgroundColor: Colors.black45,
              selectedColor: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construir controles inferiores
  Widget _buildBottomControls(BuildContext context,
      CameraProvider cameraProvider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: GestureDetector(
              onTap: cameraProvider.isTakingPicture
                  ? null
                  : () => _takePicture(context, cameraProvider),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: cameraProvider.burstMode
                        ? Colors.orange
                        : Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: cameraProvider.isTakingPicture
                    ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
                    : cameraProvider.burstMode
                    ? const Icon(
                  Icons.burst_mode,
                  size: 40,
                  color: Colors.orange,
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construir botón de control mejorado
  Widget _buildControlButton({
    required IconData icon,
    String? label,
    required VoidCallback? onPressed,
    bool enabled = true,
    bool highlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? Colors.orange : Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: highlighted
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () async {
            await HapticFeedbackService.lightImpact();
            onPressed?.call();
          }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: enabled ? Colors.white : Colors.white38,
                  size: 24,
                ),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white38,
                      fontSize: 10,
                      fontWeight: highlighted ? FontWeight.bold : FontWeight
                          .normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Obtener ícono de flash según modo
  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.auto:
        return Icons.flash_auto;
      default:
        return Icons.flash_auto;
    }
  }

  /// Obtener etiqueta de flash
  String _getFlashLabel(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return 'OFF';
      case FlashMode.always:
        return 'ON';
      case FlashMode.auto:
        return 'AUTO';
      default:
        return 'AUTO';
    }
  }

  /// Mostrar diálogo de temporizador
  void _showTimerDialog(BuildContext context, CameraProvider cameraProvider) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('⏱️ Temporizador'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTimerOption(
                    context, cameraProvider, 0, 'Sin temporizador'),
                _buildTimerOption(context, cameraProvider, 3, '3 segundos'),
                _buildTimerOption(context, cameraProvider, 5, '5 segundos'),
                _buildTimerOption(context, cameraProvider, 10, '10 segundos'),
              ],
            ),
          ),
    );
  }

  Widget _buildTimerOption(BuildContext context,
      CameraProvider provider,
      int seconds,
      String label,) {
    return ListTile(
      leading: Icon(
        seconds > 0 ? Icons.timer : Icons.timer_off,
        color: provider.timerSeconds == seconds
            ? Theme
            .of(context)
            .colorScheme
            .primary
            : null,
      ),
      title: Text(label),
      selected: provider.timerSeconds == seconds,
      onTap: () {
        provider.setTimer(seconds);
        Navigator.pop(context);
      },
    );
  }

  /// NUEVO: Mostrar diálogo de modo ráfaga
  void _showBurstDialog(BuildContext context, CameraProvider cameraProvider) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('📸 Modo Ráfaga'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Activar modo ráfaga'),
                  subtitle: const Text('Captura múltiples fotos seguidas'),
                  value: cameraProvider.burstMode,
                  onChanged: (value) {
                    cameraProvider.toggleBurstMode();
                    Navigator.pop(context);
                  },
                ),
                if (cameraProvider.burstMode) ...[
                  const Divider(),
                  const Text(
                    'Número de fotos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: cameraProvider.burstCount.toDouble(),
                    min: 2,
                    max: 10,
                    divisions: 8,
                    label: '${cameraProvider.burstCount} fotos',
                    onChanged: (value) {
                      cameraProvider.setBurstCount(value.toInt());
                    },
                  ),
                  Text(
                    '${cameraProvider.burstCount} fotos',
                    style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
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

  /// Capturar foto con actualización automática de galería
  Future<void> _takePicture(BuildContext context,
      CameraProvider cameraProvider) async {
    try {
      await cameraProvider.takePicture();

      if (mounted) {
        // Refrescar la galería automáticamente
        final galleryProvider = Provider.of<GalleryProvider>(
            context, listen: false);
        await galleryProvider.loadMedia();

        final message = cameraProvider.burstMode
            ? '✅ ${cameraProvider.burstCount} fotos guardadas en ráfaga'
            : '✅ Foto guardada en la galería';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// NUEVO: Mostrar diálogo de formato de imagen
  void _showFormatDialog(BuildContext context, CameraProvider cameraProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📷 Formato de Imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormatOption(
              context,
              cameraProvider,
              'jpeg',
              'JPEG',
              'Tamaño menor, ideal para fotos normales',
            ),
            _buildFormatOption(
              context,
              cameraProvider,
              'png',
              'PNG',
              'Mayor calidad, soporta transparencia',
            ),
          ],
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

  Widget _buildFormatOption(
      BuildContext context,
      CameraProvider provider,
      String format,
      String label,
      String description,
      ) {
    return RadioListTile<String>(
      title: Text(label),
      subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      value: format,
      groupValue: provider.imageFormat,
      onChanged: (value) {
        if (value != null) {
          provider.setImageFormat(value);
          Navigator.pop(context);
        }
      },
    );
  }
}