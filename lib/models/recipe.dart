class Recipe {
  final String? id;
  final String title;
  final String beanName;
  final String method;
  final int waterTempCelsius;
  final String steps;
  final String? forkedFromId;

  Recipe({
    this.id,
    required this.title,
    required this.beanName,
    required this.method,
    required this.waterTempCelsius,
    required this.steps,
    this.forkedFromId,
  });
}
