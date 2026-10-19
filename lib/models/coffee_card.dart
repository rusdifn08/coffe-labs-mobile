class CoffeeCard {
  final String? id;
  final String beanName;
  final String origin;
  final String roaster;
  final int acidityLevel;
  final int bodyLevel;
  final int sweetnessLevel;
  final String flavorNotes;
  final DateTime tastedAt;

  CoffeeCard({
    this.id,
    required this.beanName,
    required this.origin,
    required this.roaster,
    required this.acidityLevel,
    required this.bodyLevel,
    required this.sweetnessLevel,
    required this.flavorNotes,
    required this.tastedAt,
  });

  factory CoffeeCard.fromJson(Map<String, dynamic> json) {
    return CoffeeCard(
      id: json['id']?.toString(),
      beanName: json['beanName'],
      origin: json['origin'],
      roaster: json['roaster'],
      acidityLevel: json['acidityLevel'] ?? 0,
      bodyLevel: json['bodyLevel'] ?? 0,
      sweetnessLevel: json['sweetnessLevel'] ?? 0,
      flavorNotes: json['flavorNotes'],
      tastedAt: json['tastedAt'] != null ? DateTime.parse(json['tastedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beanName': beanName,
      'origin': origin,
      'roaster': roaster,
      'acidityLevel': acidityLevel,
      'bodyLevel': bodyLevel,
      'sweetnessLevel': sweetnessLevel,
      'flavorNotes': flavorNotes,
      'tastedAt': tastedAt.toIso8601String(),
    };
  }
}
