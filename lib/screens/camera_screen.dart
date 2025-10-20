// lib/providers/audio_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import '../database/database_helper.dart';

class AudioProvider with ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  // Estados de grabación
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  String _audioQuality = 'media'; // 'baja', 'media', 'alta'
  int _recordTimerLimit = 0; // 0 = sin límite, en segundos
  double _amplitude = 0.0;

  // Estados de reproducción
  bool _isPlaying = false;
  int _playDuration = 0;
  int _totalDuration = 0;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  // Playlist y control
  List<Map<String, dynamic>> _playlist = [];
  int _currentTrackIndex = -1;
  String? _currentAudioPath;

  // Getters - Grabación
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  int get recordDuration => _recordDuration;
  String get audioQuality => _audioQuality;
  int get recordTimerLimit => _recordTimerLimit;
  double get amplitude => _amplitude;

  // Getters - Reproducción
  bool get isPlaying => _isPlaying;
  int get playDuration => _playDuration;
  int get totalDuration => _totalDuration;
  List<Map<String, dynamic>> get playlist => _playlist;
  int get currentTrackIndex => _currentTrackIndex;
  Map<String, dynamic>? get currentTrack =>
      _currentTrackIndex >= 0 && _currentTrackIndex < _playlist.length
          ? _playlist[_currentTrackIndex]
          : null;
  bool get hasPrevious => _currentTrackIndex > 0;
  bool get hasNext => _currentTrackIndex < _playlist.length - 1;

  AudioProvider() {
    _setupAudioPlayer();
  }

  /// Configurar listeners del reproductor
  void _setupAudioPlayer() {
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();

      // Auto-reproducir siguiente al terminar
      if (state == PlayerState.completed && hasNext) {
        playNext();
      }
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      _playDuration = position.inSeconds;
      notifyListeners();
    });

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _totalDuration = duration.inSeconds;
      notifyListeners();
    });
  }

  // ============ GRABACIÓN ============

  /// Iniciar grabación
  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filename = 'AUD_$timestamp.m4a';
        final String path = '${appDir.path}/$filename';

        // Configurar calidad según selección
        final config = _getRecordConfig();

        await _recorder.start(config, path: path);

        _isRecording = true;
        _isPaused = false;
        _recordDuration = 0;
        _currentAudioPath = path;

        _startRecordTimer();
        _startAmplitudeMonitoring();

        notifyListeners();
        debugPrint('✅ Grabación iniciada: $filename');
      } else {
        debugPrint('❌ Permiso de micrófono denegado');
      }
    } catch (e) {
      debugPrint('❌ Error al iniciar grabación: $e');
    }
  }

  /// Pausar grabación
  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
      _isPaused = true;
      _recordTimer?.cancel();
      notifyListeners();
      debugPrint('⏸️ Grabación pausada');
    } catch (e) {
      debugPrint('❌ Error al pausar: $e');
    }
  }

  /// Reanudar grabación
  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
      _isPaused = false;
      _startRecordTimer();
      notifyListeners();
      debugPrint('▶️ Grabación reanudada');
    } catch (e) {
      debugPrint('❌ Error al reanudar: $e');
    }
  }

  /// Detener grabación y guardar
  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _recordTimer?.cancel();

      _isRecording = false;
      _isPaused = false;

      if (path != null) {
        final file = File(path);
        final size = await file.length();
        final duration = _recordDuration;

        // Guardar en base de datos
        await DatabaseHelper.instance.insertMedia({
          'path': path,
          'type': 'audio',
          'name': path.split('/').last,
          'created_at': DateTime.now().toIso8601String(),
          'size': size,
          'duration': duration,
          'quality': _audioQuality,
          'album': 'General',
        });

        debugPrint('✅ Audio guardado: $path ($duration segundos)');
      }

      _recordDuration = 0;
      _amplitude = 0.0;
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Error al detener grabación: $e');
    }
  }

  /// Timer de grabación con límite
  void _startRecordTimer() {
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordDuration++;

      // Detener automáticamente si alcanza el límite
      if (_recordTimerLimit > 0 && _recordDuration >= _recordTimerLimit) {
        stopRecording();
        debugPrint('⏱️ Límite de grabación alcanzado');
      }

      notifyListeners();
    });
  }

  /// Monitorear amplitud para visualización
  void _startAmplitudeMonitoring() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      _recorder.getAmplitude().then((amp) {
        _amplitude = (amp.current / amp.max).clamp(0.0, 1.0);
        notifyListeners();
      });
    });
  }

  /// Configurar calidad de grabación
  RecordConfig _getRecordConfig() {
    switch (_audioQuality) {
      case 'baja':
        return const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 22050,
        );
      case 'alta':
        return const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 192000,
          sampleRate: 44100,
        );
      case 'media':
      default:
        return const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );
    }
  }

  /// Establecer calidad de audio
  void setAudioQuality(String quality) {
    if (!_isRecording) {
      _audioQuality = quality;
      notifyListeners();
      debugPrint('🎵 Calidad de audio: $quality');
    }
  }

  /// Establecer límite de tiempo de grabación
  void setRecordTimerLimit(int seconds) {
    if (!_isRecording) {
      _recordTimerLimit = seconds;
      notifyListeners();
      debugPrint('⏱️ Límite de grabación: ${seconds}s');
    }
  }

  // ============ REPRODUCCIÓN ============

  /// Cargar playlist desde base de datos
  Future<void> loadPlaylist() async {
    try {
      final allMedia = await DatabaseHelper.instance.getAllMedia();
      _playlist = allMedia.where((m) => m['type'] == 'audio').toList();
      notifyListeners();
      debugPrint('📋 Playlist cargada: ${_playlist.length} audios');
    } catch (e) {
      debugPrint('❌ Error al cargar playlist: $e');
      _playlist = [];
    }
  }

  /// Reproducir audio específico por path
  Future<void> playAudio(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));

      // Buscar índice en playlist
      _currentTrackIndex = _playlist.indexWhere((audio) => audio['path'] == path);

      debugPrint('▶️ Reproduciendo: $path');
    } catch (e) {
      debugPrint('❌ Error al reproducir: $e');
    }
  }

  /// Reproducir audio por índice en playlist
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentTrackIndex = index;
      final audio = _playlist[index];
      await playAudio(audio['path']);
    }
  }

  /// Reproducir siguiente
  Future<void> playNext() async {
    if (hasNext) {
      await playAtIndex(_currentTrackIndex + 1);
    }
  }

  /// Reproducir anterior
  Future<void> playPrevious() async {
    if (hasPrevious) {
      await playAtIndex(_currentTrackIndex - 1);
    }
  }

  /// Pausar reproducción
  Future<void> pausePlayback() async {
    try {
      await _player.pause();
      debugPrint('⏸️ Reproducción pausada');
    } catch (e) {
      debugPrint('❌ Error al pausar reproducción: $e');
    }
  }

  /// Reanudar reproducción
  Future<void> resumePlayback() async {
    try {
      await _player.resume();
      debugPrint('▶️ Reproducción reanudada');
    } catch (e) {
      debugPrint('❌ Error al reanudar reproducción: $e');
    }
  }

  /// Detener reproducción
  Future<void> stopPlayback() async {
    try {
      await _player.stop();
      _playDuration = 0;
      _currentTrackIndex = -1;
      notifyListeners();
      debugPrint('⏹️ Reproducción detenida');
    } catch (e) {
      debugPrint('❌ Error al detener reproducción: $e');
    }
  }

  /// Buscar posición en audio
  Future<void> seekAudio(int seconds) async {
    try {
      await _player.seek(Duration(seconds: seconds));
      debugPrint('⏩ Buscando: ${seconds}s');
    } catch (e) {
      debugPrint('❌ Error al buscar: $e');
    }
  }

  /// Formatear duración a MM:SS
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}