class AuditoriumModel {
  final String id;
  final String name;
  final String blockName;
  final int capacity;
  final String imageUrl;
  final List<String> facilities;
  final String description;
  final String floor;
  final bool isAvailable;

  AuditoriumModel({
    required this.id,
    required this.name,
    required this.blockName,
    required this.capacity,
    required this.imageUrl,
    required this.facilities,
    required this.description,
    required this.floor,
    this.isAvailable = true,
  });

  AuditoriumModel copyWith({
    String? id,
    String? name,
    String? blockName,
    int? capacity,
    String? imageUrl,
    List<String>? facilities,
    String? description,
    String? floor,
    bool? isAvailable,
  }) {
    return AuditoriumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      blockName: blockName ?? this.blockName,
      capacity: capacity ?? this.capacity,
      imageUrl: imageUrl ?? this.imageUrl,
      facilities: facilities ?? this.facilities,
      description: description ?? this.description,
      floor: floor ?? this.floor,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
