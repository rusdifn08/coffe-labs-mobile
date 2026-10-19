class BrewLog {
  final String? id;
  final String beanName;
  final String method;
  final double coffeeWeight;
  final double waterWeight;
  final int totalBrewTimeSeconds;
  final DateTime createdAt;

  BrewLog({
    this.id,
    required this.beanName,
    required this.method,
    required this.coffeeWeight,
    required this.waterWeight,
    required this.totalBrewTimeSeconds,
    required this.createdAt,
  });

  factory BrewLog.fromJson(Map<String, dynamic> json) {
    return BrewLog(
      id: json['id']?.toString(),
      beanName: json['beanName'],
      method: json['method'],
      coffeeWeight: json['coffeeWeight']?.toDouble() ?? 0.0,
      waterWeight: json['waterWeight']?.toDouble() ?? 0.0,
      totalBrewTimeSeconds: json['totalBrewTimeSeconds'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beanName': beanName,
      'method': method,
      'coffeeWeight': coffeeWeight,
      'waterWeight': waterWeight,
      'totalBrewTimeSeconds': totalBrewTimeSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
