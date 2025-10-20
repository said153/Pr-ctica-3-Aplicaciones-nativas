import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../database/database_helper.dart';

class TagManagementScreen extends StatefulWidget {
  final int mediaId;
  final String mediaName;

  const TagManagementScreen({
    super.key,
    required this.mediaId,
    required this.mediaName,
  });

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  final TextEditingController _tagController = TextEditingController();
  List<String> _currentTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    _currentTags = await provider.getMediaTags(widget.mediaId);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addTag() async {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) return;

    try {
      final provider = Provider.of<GalleryProvider>(context, listen: false);
      await provider.addTagToMedia(widget.mediaId, tag);
      _tagController.clear();
      await _loadTags();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Etiqueta "$tag" agregada')),
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

  Future<void> _removeTag(String tag) async {
    try {
      final currentTags = List<String>.from(_currentTags);
      currentTags.remove(tag);

      await DatabaseHelper.instance.updateMediaTags(widget.mediaId, currentTags);
      await _loadTags();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Etiqueta "$tag" removida')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etiquetas - ${widget.mediaName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input para agregar etiqueta
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva etiqueta',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                  tooltip: 'Agregar etiqueta',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lista de etiquetas actuales
            Expanded(
              child: _currentTags.isEmpty
                  ? const Center(
                child: Text(
                  'No hay etiquetas',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _currentTags.length,
                itemBuilder: (context, index) {
                  final tag = _currentTags[index];
                  return Card(
                    child: ListTile(
                      title: Text(tag),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeTag(tag),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}