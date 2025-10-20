/// Modelo para representar un item multimedia (imagen o audio)
class MediaItem {
  final int? id;
  final String path;
  final String type; // 'image' o 'audio'
  final String name;
  final DateTime createdAt;
  final int? size; // Tamaño en bytes
  final int? duration; // Duración en segundos (para audio)
  final String? filter; // Filtro aplicado (para imágenes)
  final String? quality; // Calidad (para audio)
  final double? latitude;
  final double? longitude;
  final List<String>? tags;

  MediaItem({
    this.id,
    required this.path,
    required this.type,
    required this.name,
    required this.createdAt,
    this.size,
    this.duration,
    this.filter,
    this.quality,
    this.latitude,
    this.longitude,
    this.tags,
  });

  /// Crear MediaItem desde Map (base de datos)
  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as int?,
      path: map['path'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      size: map['size'] as int?,
      duration: map['duration'] as int?,
      filter: map['filter'] as String?,
      quality: map['quality'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : null,
    );
  }

  /// Convertir MediaItem a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'type': type,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'size': size,
      'duration': duration,
      'filter': filter,
      'quality': quality,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags?.join(','),
    };
  }

  /// Obtener tamaño formateado legible
  String get formattedSize {
    if (size == null) return 'Desconocido';

    final kb = size! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';

    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  /// Obtener duración formateada (MM:SS)
  String get formattedDuration {
    if (duration == null) return '--:--';

    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Verificar si es imagen
  bool get isImage => type == 'image';

  /// Verificar si es audio
  bool get isAudio => type == 'audio';

  /// Copiar con modificaciones
  MediaItem copyWith({
    int? id,
    String? path,
    String? type,
    String? name,
    DateTime? createdAt,
    int? size,
    int? duration,
    String? filter,
    String? quality,
    double? latitude,
    double? longitude,
    List<String>? tags,
  }) {
    return MediaItem(
      id: id ?? this.id,
      path: path ?? this.path,
      type: type ?? this.type,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      filter: filter ?? this.filter,
      quality: quality ?? this.quality,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
    );
  }
}