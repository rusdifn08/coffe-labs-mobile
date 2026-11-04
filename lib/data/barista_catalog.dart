import '../services/coffee_translator.dart';
import '../utils/barista_utils.dart';
import 'baristas/baristas_part_1.dart';
import 'baristas/baristas_part_2.dart';

class BaristaProfile {
  final String name;
  final String slug;
  final String country;
  final String countryCode;
  final String specialty;
  final String bio;
  final String? imageAsset;

  const BaristaProfile({
    required this.name,
    required this.slug,
    required this.country,
    required this.countryCode,
    required this.specialty,
    required this.bio,
    this.imageAsset,
  });

  String get localizedBio => CoffeeTranslator.translateBio(bio);
  String get localizedCountry => CoffeeTranslator.translateCountry(country);
  String get localizedSpecialty => CoffeeTranslator.translateSpecialty(specialty);
  String? get coverAsset => BaristaCatalog.coverForSlug(slug);
}

class BaristaCatalog {
  static const Map<String, BaristaProfile> bySlug = {
    ...baristasPart1,
    ...baristasPart2,
  };

  static const Set<String> knownCovers = {
    'alan_adler',
    'alessandro_galtieri',
    'bavis_kwong',
    'bayu_prawiro',
    'benjamin_prager',
    'carlos_escobar',
    'carlos_medina',
    'chad_wang',
    'daiki_hatakeyama',
    'dody_samsura',
    'du_jianing',
    'elika_liftee',
    'elysia_tan',
    'emi_fukahori',
    'garam_victor_um',
    'harison_chandra',
    'hiro_lesmana',
    'james_hoffmann',
    'john_christopher',
    'jonathan_gagne',
    'konstantinos_iatridis',
    'lance_hedrick',
    'martin_wolfl',
    'matt_perger',
    'matt_winton',
    'melvin_fugol',
    'mikaela_wallgren',
    'mikael_jasin',
    'mirza_luqman',
    'muhammad_aga',
    'nas_jaafar',
    'odd_steinar_tollefsen',
    'patrik_rolf',
    'peng_jinyang',
    'pepeng_klinik_kopi',
    'regine_wai_yee_beng',
    'ryan_wibawa',
    'sam_corra',
    'savina_giachgia',
    'scott_rao',
    'shayneella',
    'shih_yuan_hsu',
    'simon_gautherin',
    'stathis_koremtas',
    'tetsu_kasuya',
    'tim_wendelboe',
    'tuomas_merikanto',
    'wataru_iidaka',
    'wendelien_van_bunnik',
    'wisnu_aji',
    'yoshua_tanu',
  };

  static String? coverForSlug(String slug) {
    if (knownCovers.contains(slug)) {
      return 'assets/images/avatars/covers/$slug.jpg';
    }
    return null;
  }

  static BaristaProfile resolve(String rawAuthor, {String? imageUrl}) {
    final slug = BaristaUtils.slugFromAuthor(rawAuthor);
    final known = bySlug[slug];
    if (known != null) {
      return known;
    }
    final name = BaristaUtils.cleanName(rawAuthor);
    return BaristaProfile(
      name: name.isEmpty ? 'Barista' : name,
      slug: slug,
      country: BaristaUtils.countryLabel(rawAuthor),
      countryCode: BaristaUtils.countryCode(rawAuthor),
      specialty: 'Custom brew recipes',
      bio: 'Kreator resep di Coffee Labs. Jelajahi teknik seduh dan catat hasil brew Anda.',
      imageAsset: imageUrl ?? 'assets/images/avatars/generic_fallback.jpg',
    );
  }
}
