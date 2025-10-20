// lib/screens/audio_player_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'audio_player_screen_complete.dart';

// Clase simple que redirige al reproductor completo
class AudioPlayerScreen extends StatefulWidget {
  final String path;
  final String name;

  const AudioPlayerScreen({
    super.key,
    required this.path,
    required this.name,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Reproducir el audio específico cuando se abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.playAudio(widget.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AudioPlayerFullScreen();
  }
}