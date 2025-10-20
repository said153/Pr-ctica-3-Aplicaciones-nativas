import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/gallery_provider.dart';

/// Pantalla de edición de imágenes mejorada
class ImageEditorScreen extends StatefulWidget {
  final Map<String, dynamic> media;

  const ImageEditorScreen({super.key, required this.media});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  img.Image? _currentImage;
  img.Image? _originalImage;
  bool _isProcessing = false;

  // Controles de ajuste
  double _brightness = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  int _rotationAngle = 0;

  String _currentFilter = 'Ninguno';

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isProcessing = true);

    final file = File(widget.media['path']);
    final bytes = await file.readAsBytes();
    _originalImage = img.decodeImage(bytes);
    _currentImage = img.copyResize(_originalImage!, width: 1024); // Optimizar para preview

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Editar Imagen'),
        actions: [
          if (!_isProcessing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveImage,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: _isProcessing || _currentImage == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Vista previa de la imagen
          Expanded(
            flex: 3,
            child: _buildImagePreview(),
          ),

          // Panel de herramientas
          Expanded(
            flex: 2,
            child: _buildToolsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      color: Colors.black,
      child: Center(
        child: _currentImage != null
            ? Transform.rotate(
          angle: _rotationAngle * 3.14159 / 180,
          child: Image.memory(
            Uint8List.fromList(img.encodeJpg(_applyAdjustments())),
            fit: BoxFit.contain,
          ),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildToolsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.tune), text: 'Ajustes'),
                Tab(icon: Icon(Icons.filter), text: 'Filtros'),
                Tab(icon: Icon(Icons.crop_rotate), text: 'Rotar'),
                Tab(icon: Icon(Icons.crop), text: 'Recortar'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAdjustmentsTab(),
                  _buildFiltersTab(),
                  _buildRotateTab(),
                  _buildCropTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Ajustes
  Widget _buildAdjustmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSlider(
            'Brillo',
            Icons.brightness_6,
            _brightness,
            0.5,
            2.0,
                (value) => setState(() => _brightness = value),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Contraste',
            Icons.contrast,
            _contrast,
            0.5,
            2.0,
                (value) => setState(() => _contrast = value),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Saturación',
            Icons.palette,
            _saturation,
            0.0,
            2.0,
                (value) => setState(() => _saturation = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _resetAdjustments,
            icon: const Icon(Icons.refresh),
            label: const Text('Restablecer Ajustes'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
      String label,
      IconData icon,
      double value,
      double min,
      double max,
      Function(double) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 30,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // TAB 2: Filtros
  Widget _buildFiltersTab() {
    final filters = [
      {'name': 'Ninguno', 'icon': Icons.filter_none},
      {'name': 'Grises', 'icon': Icons.filter_b_and_w},
      {'name': 'Sepia', 'icon': Icons.filter_vintage},
      {'name': 'Invertir', 'icon': Icons.invert_colors},
      {'name': 'Desenfoque', 'icon': Icons.blur_on},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final filter = filters[index];
        final isSelected = _currentFilter == filter['name'];

        return InkWell(
          onTap: () => setState(() => _currentFilter = filter['name'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  filter['icon'] as IconData,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  filter['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 3: Rotar
  Widget _buildRotateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRotateButton('90°', Icons.rotate_left, () {
                setState(() => _rotationAngle = (_rotationAngle - 90) % 360);
              }),
              _buildRotateButton('180°', Icons.sync, () {
                setState(() => _rotationAngle = (_rotationAngle + 180) % 360);
              }),
              _buildRotateButton('270°', Icons.rotate_right, () {
                setState(() => _rotationAngle = (_rotationAngle + 90) % 360);
              }),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rotación actual: $_rotationAngle°',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() => _rotationAngle = 0),
            icon: const Icon(Icons.refresh),
            label: const Text('Restablecer'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotateButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  // TAB 4: Recortar
  Widget _buildCropTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCropButton('Cuadrado 1:1', Icons.crop_square, 'square'),
          const SizedBox(height: 10),
          _buildCropButton('Retrato 9:16', Icons.crop_portrait, 'portrait'),
          const SizedBox(height: 10),
          _buildCropButton('Paisaje 16:9', Icons.crop_landscape, 'landscape'),
          const SizedBox(height: 10),
          _buildCropButton('Personalizado', Icons.crop_free, 'custom'),
        ],
      ),
    );
  }

  Widget _buildCropButton(String label, IconData icon, String cropType) {
    return ElevatedButton.icon(
      onPressed: () => _applyCrop(cropType),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  // Aplicar ajustes a la imagen
  img.Image _applyAdjustments() {
    if (_currentImage == null) return _originalImage!;

    img.Image result = img.copyResize(_currentImage!, width: _currentImage!.width);

    // Aplicar brillo, contraste y saturación
    if (_brightness != 1.0 || _contrast != 1.0 || _saturation != 1.0) {
      result = img.adjustColor(
        result,
        brightness: _brightness,
        contrast: _contrast,
        saturation: _saturation,
      );
    }

    // Aplicar filtro
    result = _applyFilter(result, _currentFilter);

    return result;
  }

  img.Image _applyFilter(img.Image image, String filterName) {
    switch (filterName) {
      case 'Grises':
        return img.grayscale(image);
      case 'Sepia':
        return img.sepia(image);
      case 'Invertir':
        return img.invert(image);
      case 'Desenfoque':
        return img.gaussianBlur(image, radius: 5);
      default:
        return image;
    }
  }

  void _resetAdjustments() {
    setState(() {
      _brightness = 1.0;
      _contrast = 1.0;
      _saturation = 1.0;
    });
  }

  Future<void> _applyCrop(String cropType) async {
    if (_originalImage == null) return;

    setState(() => _isProcessing = true);

    try {
      img.Image cropped;

      switch (cropType) {
        case 'square':
          final size = _originalImage!.width < _originalImage!.height
              ? _originalImage!.width
              : _originalImage!.height;
          final x = (_originalImage!.width - size) ~/ 2;
          final y = (_originalImage!.height - size) ~/ 2;
          cropped = img.copyCrop(_originalImage!, x: x, y: y, width: size, height: size);
          break;

        case 'portrait':
          final targetRatio = 9.0 / 16.0;
          int width, height, x, y;
          if (_originalImage!.width / _originalImage!.height > targetRatio) {
            height = _originalImage!.height;
            width = (height * targetRatio).round();
            x = (_originalImage!.width - width) ~/ 2;
            y = 0;
          } else {
            width = _originalImage!.width;
            height = (width / targetRatio).round();
            x = 0;
            y = (_originalImage!.height - height) ~/ 2;
          }
          cropped = img.copyCrop(_originalImage!, x: x, y: y, width: width, height: height);
          break;

        case 'landscape':
          final targetRatio = 16.0 / 9.0;
          int width, height, x, y;
          if (_originalImage!.width / _originalImage!.height > targetRatio) {
            height = _originalImage!.height;
            width = (height * targetRatio).round();
            x = (_originalImage!.width - width) ~/ 2;
            y = 0;
          } else {
            width = _originalImage!.width;
            height = (width / targetRatio).round();
            x = 0;
            y = (_originalImage!.height - height) ~/ 2;
          }
          cropped = img.copyCrop(_originalImage!, x: x, y: y, width: width, height: height);
          break;

        case 'custom':
          final marginX = (_originalImage!.width * 0.1).round();
          final marginY = (_originalImage!.height * 0.1).round();
          cropped = img.copyCrop(
            _originalImage!,
            x: marginX,
            y: marginY,
            width: _originalImage!.width - (2 * marginX),
            height: _originalImage!.height - (2 * marginY),
          );
          break;

        default:
          cropped = _originalImage!;
      }

      _originalImage = cropped;
      _currentImage = img.copyResize(cropped, width: 1024);

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Imagen recortada')),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  Future<void> _saveImage() async {
    setState(() => _isProcessing = true);

    try {
      // Aplicar todas las transformaciones a la imagen original
      img.Image finalImage = _originalImage!;

      // Aplicar rotación
      if (_rotationAngle != 0) {
        finalImage = img.copyRotate(finalImage, angle: _rotationAngle);
      }

      // Aplicar ajustes
      if (_brightness != 1.0 || _contrast != 1.0 || _saturation != 1.0) {
        finalImage = img.adjustColor(
          finalImage,
          brightness: _brightness,
          contrast: _contrast,
          saturation: _saturation,
        );
      }

      // Aplicar filtro
      finalImage = _applyFilter(finalImage, _currentFilter);

      // Guardar
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = 'IMG_EDITED_$timestamp.jpg';
      final String newPath = '${appDir.path}/$filename';

      final bytes = img.encodeJpg(finalImage, quality: 95);
      await File(newPath).writeAsBytes(bytes);

      // Guardar en base de datos
      await DatabaseHelper.instance.insertMedia({
        'path': newPath,
        'type': 'image',
        'name': filename,
        'created_at': DateTime.now().toIso8601String(),
        'size': bytes.length,
        'filter': _currentFilter,
        'album': 'General',
      });

      // Actualizar galería
      if (mounted) {
        final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
        await galleryProvider.loadMedia();

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Imagen guardada exitosamente')),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al guardar: $e')),
        );
      }
    }
  }
}