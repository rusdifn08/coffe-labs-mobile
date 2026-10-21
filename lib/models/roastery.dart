class CoffeeLineupItem {
  final String name;
  final String origin;
  final String roastProfile;
  final String variety;
  final String process;
  final String tastingNotes;
  final String price100g;
  final String price200g;
  final String originalPackage;
  final String? badge;
  final bool isAvailable;

  const CoffeeLineupItem({
    required this.name,
    required this.origin,
    required this.roastProfile,
    required this.variety,
    required this.process,
    required this.tastingNotes,
    required this.price100g,
    required this.price200g,
    required this.originalPackage,
    this.badge,
    this.isAvailable = true,
  });
}

class Roastery {
  final String id;
  final String name;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final String specialties;
  final String cluster;
  final String imageUrl;
  final double rating;
  final String salesHighlight;
  final List<CoffeeLineupItem> lineups;

  const Roastery({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.specialties,
    required this.cluster,
    this.imageUrl = 'assets/images/avatars/covers/harison_chandra.jpg',
    this.rating = 4.9,
    this.salesHighlight = 'Specialty Grade',
    this.lineups = const [],
  });
}
