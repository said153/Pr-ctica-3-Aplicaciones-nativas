/// Modelo para representar un álbum de la galería
class Album {
  final int? id;
  final String name;
  final String? description;
  final String? coverPath;
  final DateTime createdAt;

  Album({
    this.id,
    required this.name,
    this.description,
    this.coverPath,
    required this.createdAt,
  });

  /// Crear Album desde Map (base de datos)
  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverPath: map['cover_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convertir Album a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_path': coverPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copiar con modificaciones
  Album copyWith({
    int? id,
    String? name,
    String? description,
    String? coverPath,
    DateTime? createdAt,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}