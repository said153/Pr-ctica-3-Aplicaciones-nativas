import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/camerax_service.dart';

class CameraXScreen extends StatefulWidget {
  const CameraXScreen({super.key});

  @override
  State<CameraXScreen> createState() => _CameraXScreenState();
}

class _CameraXScreenState extends State<CameraXScreen> {
  bool _isInitialized = false;
  String _flashMode = 'off';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await CameraXService.initializeCameraX();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error al inicializar CameraX: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final imagePath = await CameraXService.takePicture();
      if (imagePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Foto guardada: $imagePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    try {
      final newMode = _flashMode == 'off' ? 'on' : 'off';
      await CameraXService.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      debugPrint('Error al cambiar flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await CameraXService.switchCamera();
    } catch (e) {
      debugPrint('Error al cambiar cámara: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CameraX'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_flashMode == 'off' ? Icons.flash_off : Icons.flash_on),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: _isInitialized
          ? Stack(
        children: [
          // Vista nativa de CameraX
          const AndroidView(
            viewType: 'com.practica3/camerax_preview',
            creationParamsCodec: StandardMessageCodec(),
          ),

          // Botón de captura
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.blue,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}