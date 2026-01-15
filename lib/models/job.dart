class Job {
  final String id;
  final String buildingName;
  final String flatNumber;
  final String brand;
  final String counterType;
  final String status; // e.g., "ÖDEDİ", "DEĞİŞTİR"
  final String description; // e.g., "Sıcak Su", "Yeni"
  final String? imageUrl;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.buildingName,
    required this.flatNumber,
    required this.brand,
    required this.counterType,
    required this.status,
    required this.description,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Manufacturing a copy with updated fields (immutability pattern)
  Job copyWith({
    String? id,
    String? buildingName,
    String? flatNumber,
    String? brand,
    String? counterType,
    String? status,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Job(
      id: id ?? this.id,
      buildingName: buildingName ?? this.buildingName,
      flatNumber: flatNumber ?? this.flatNumber,
      brand: brand ?? this.brand,
      counterType: counterType ?? this.counterType,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
