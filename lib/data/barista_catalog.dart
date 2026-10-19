import '../utils/barista_utils.dart';

/// Profil metadata barista (bio singkat untuk layar profil).
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
}

class BaristaCatalog {
  static const Map<String, BaristaProfile> bySlug = {
    'tetsu_kasuya': BaristaProfile(
      name: 'Tetsu Kasuya',
      slug: 'tetsu_kasuya',
      country: 'Jepang',
      countryCode: 'jp',
      specialty: 'Metode 4:6 & Neo Brew',
      bio: 'Juara World Brewers Cup 2016. Pencipta metode 4:6 yang memisahkan kontrol rasa manis/asam dari kekuatan ekstraksi.',
      imageAsset: 'assets/images/avatars/portraits/tetsu_kasuya.jpg',
    ),
    'odd_steinar_tollefsen': BaristaProfile(
      name: 'Odd-Steinar Tøllefsen',
      slug: 'odd_steinar_tollefsen',
      country: 'Norwegia',
      countryCode: 'no',
      specialty: 'Natural process clarity',
      bio: 'Juara WBrC 2015. Memopulerkan natural process bersih dengan mineral air rendah dari pantai barat Norwegia.',
      imageAsset: 'assets/images/avatars/portraits/odd_steinar_tollefsen.jpg',
    ),
    'konstantinos_iatridis': BaristaProfile(
      name: 'Konstantinos Iatridis',
      slug: 'konstantinos_iatridis',
      country: 'Yunani',
      countryCode: 'gr',
      specialty: 'Frozen bean grinding',
      bio: 'Inovator teknik biji dingin untuk partikel lebih seragam dan fines lebih sedikit.',
      imageAsset: 'assets/images/avatars/portraits/konstantinos_iatridis.jpg',
    ),
    'benjamin_prager': BaristaProfile(
      name: 'Benjamin Prager',
      slug: 'benjamin_prager',
      country: 'Swiss',
      countryCode: 'ch',
      specialty: 'Single continuous pour',
      bio: 'Fokus pada kurva suhu slurry dan body sehalus sutra lewat tuangan kontinu.',
      imageAsset: 'assets/images/avatars/portraits/benjamin_prager.jpg',
    ),
    'mikaela_wallgren': BaristaProfile(
      name: 'Mikaela Wallgren',
      slug: 'mikaela_wallgren',
      country: 'Finlandia',
      countryCode: 'fi',
      specialty: 'Kalita Wave cafe flow',
      bio: 'Membawa efisiensi kedai ke panggung dunia dengan Kalita Wave dan tuangan spiral stabil.',
      imageAsset: 'assets/images/avatars/portraits/mikaela_wallgren.jpg',
    ),
    'chad_wang': BaristaProfile(
      name: 'Chad Wang',
      slug: 'chad_wang',
      country: 'Taiwan',
      countryCode: 'tw',
      specialty: 'Aroma-driven extraction',
      bio: 'Juara WBrC yang menekankan ekstraksi berbasis aroma dan kontrol fraksi tuangan.',
      imageAsset: 'assets/images/avatars/portraits/chad_wang.jpg',
    ),
    'sam_corra': BaristaProfile(
      name: 'Sam Corra',
      slug: 'sam_corra',
      country: 'Australia',
      countryCode: 'au',
      specialty: 'Precision pulse pouring',
      bio: 'Pendekatan teknis Australia dengan pulse pouring yang sangat presisi.',
      imageAsset: 'assets/images/avatars/portraits/sam_corra.jpg',
    ),
    'stathis_koremtas': BaristaProfile(
      name: 'Stathis Koremtas',
      slug: 'stathis_koremtas',
      country: 'Yunani',
      countryCode: 'gr',
      specialty: 'Hybrid & clarity',
      bio: 'Barista Yunani dengan fokus fokus kejernihan rasa dan hybrid brewers.',
      imageAsset: 'assets/images/avatars/portraits/stathis_koremtas.jpg',
    ),
    'emi_fukahori': BaristaProfile(
      name: 'Emi Fukahori',
      slug: 'emi_fukahori',
      country: 'Swiss',
      countryCode: 'ch',
      specialty: 'Cooler extraction balance',
      bio: 'Juara WBrC 2018. Ahli keseimbangan ekstraksi dengan suhu lebih rendah.',
      imageAsset: 'assets/images/avatars/portraits/emi_fukahori.jpg',
    ),
    'regine_wai_yee_beng': BaristaProfile(
      name: 'Regine Wai Yee Beng',
      slug: 'regine_wai_yee_beng',
      country: 'Malaysia',
      countryCode: 'my',
      specialty: 'Southeast Asian finesse',
      bio: 'Barista Malaysia dengan sentuhan manis dan kontrol body yang halus.',
      imageAsset: 'assets/images/avatars/portraits/regine_wai_yee_beng.jpg',
    ),
    'du_jianing': BaristaProfile(
      name: 'Du Jianing',
      slug: 'du_jianing',
      country: 'China',
      countryCode: 'cn',
      specialty: 'Structured multi-pour',
      bio: 'Pendekatan terstruktur dari China untuk multi-pour berlapis.',
      imageAsset: 'assets/images/avatars/portraits/du_jianing.jpg',
    ),
    'patrik_rolf': BaristaProfile(
      name: 'Patrik Rolf',
      slug: 'patrik_rolf',
      country: 'Swedia',
      countryCode: 'se',
      specialty: 'Nordic light roast',
      bio: 'Gaya Nordic untuk light roast dengan fokus sweetness tinggi.',
      imageAsset: 'assets/images/avatars/portraits/patrik_rolf.jpg',
    ),
    'alessandro_galtieri': BaristaProfile(
      name: 'Alessandro Galtieri',
      slug: 'alessandro_galtieri',
      country: 'Italia',
      countryCode: 'it',
      specialty: 'Italian craft pour-over',
      bio: 'Craft pour-over Italia dengan perhatian pada tekstur dan aftertaste.',
      imageAsset: 'assets/images/avatars/portraits/alessandro_galtieri.jpg',
    ),
    'matt_winton': BaristaProfile(
      name: 'Matt Winton',
      slug: 'matt_winton',
      country: 'Swiss',
      countryCode: 'ch',
      specialty: 'Blend extraction',
      bio: 'Juara WBrC 2021. Ahli mengekstrak blend kompleks termasuk eugenioides.',
      imageAsset: 'assets/images/avatars/portraits/matt_winton.jpg',
    ),
    'daiki_hatakeyama': BaristaProfile(
      name: 'Daiki Hatakeyama',
      slug: 'daiki_hatakeyama',
      country: 'Jepang',
      countryCode: 'jp',
      specialty: 'Japanese precision',
      bio: 'Presisi Jepang pada ritme tuangan dan kontrol slurry.',
      imageAsset: 'assets/images/avatars/portraits/daiki_hatakeyama.jpg',
    ),
    'elika_liftee': BaristaProfile(
      name: 'Elika Liftee',
      slug: 'elika_liftee',
      country: 'Amerika Serikat',
      countryCode: 'us',
      specialty: 'Competition clarity',
      bio: 'Juara WBrC dari AS dengan fokus kejernihan dan signature acidity.',
      imageAsset: 'assets/images/avatars/portraits/elika_liftee.jpg',
    ),
    'shih_yuan_hsu': BaristaProfile(
      name: 'Shih Yuan Hsu',
      slug: 'shih_yuan_hsu',
      country: 'Taiwan',
      countryCode: 'tw',
      specialty: 'Floral Taiwanese style',
      bio: 'Gaya Taiwan yang menonjolkan floral dan tea-like body.',
      imageAsset: 'assets/images/avatars/portraits/shih_yuan_hsu.jpg',
    ),
    'elysia_tan': BaristaProfile(
      name: 'Elysia Tan',
      slug: 'elysia_tan',
      country: 'Singapura',
      countryCode: 'sg',
      specialty: 'Clean tropical cups',
      bio: 'Barista Singapura dengan cup tropis yang bersih dan seimbang.',
      imageAsset: 'assets/images/avatars/portraits/elysia_tan.jpg',
    ),
    'carlos_medina': BaristaProfile(
      name: 'Carlos Medina',
      slug: 'carlos_medina',
      country: 'Chile',
      countryCode: 'cl',
      specialty: 'Tropical fruit clarity',
      bio: 'Juara WBrC dari Chile dengan fokus kejernihan buah tropis.',
      imageAsset: 'assets/images/avatars/portraits/carlos_medina.jpg',
    ),
    'savina_giachgia': BaristaProfile(
      name: 'Savina Giachgia',
      slug: 'savina_giachgia',
      country: 'Yunani',
      countryCode: 'gr',
      specialty: 'Elegant Greek cups',
      bio: 'Pendekatan elegan Yunani untuk body lembut dan aftertaste panjang.',
      imageAsset: 'assets/images/avatars/portraits/savina_giachgia.jpg',
    ),
    'garam_victor_um': BaristaProfile(
      name: 'Garam Victor Um',
      slug: 'garam_victor_um',
      country: 'Brasil',
      countryCode: 'br',
      specialty: 'Brazilian sweetness',
      bio: 'Menonjolkan sweetness Brasil dengan struktur ekstraksi modern.',
      imageAsset: 'assets/images/avatars/portraits/garam_victor_um.jpg',
    ),
    'martin_wolfl': BaristaProfile(
      name: 'Martin Wölfl',
      slug: 'martin_wolfl',
      country: 'Austria',
      countryCode: 'at',
      specialty: 'Alpine precision',
      bio: 'Presisi Alpine dari Austria untuk balance dan consistency.',
      imageAsset: 'assets/images/avatars/portraits/martin_wolfl.jpg',
    ),
    'wataru_iidaka': BaristaProfile(
      name: 'Wataru Iidaka',
      slug: 'wataru_iidaka',
      country: 'Jepang',
      countryCode: 'jp',
      specialty: 'Delicate Japanese brew',
      bio: 'Seduhan Jepang yang lembut dengan kontrol agitation minimal.',
      imageAsset: 'assets/images/avatars/portraits/wataru_iidaka.jpg',
    ),
    'ryan_wibawa': BaristaProfile(
      name: 'Ryan Wibawa',
      slug: 'ryan_wibawa',
      country: 'Indonesia',
      countryCode: 'id',
      specialty: 'Indonesian competition brew',
      bio: 'Barista Indonesia di panggung dunia — bangga dengan teknik kompetisi lokal.',
      imageAsset: 'assets/images/avatars/portraits/ryan_wibawa.jpg',
    ),
    'peng_jinyang': BaristaProfile(
      name: 'Peng Jinyang',
      slug: 'peng_jinyang',
      country: 'China',
      countryCode: 'cn',
      specialty: 'High extraction control',
      bio: 'Kontrol ekstraksi tinggi dengan ritme pour yang disiplin.',
      imageAsset: 'assets/images/avatars/portraits/peng_jinyang.jpg',
    ),
    'bayu_prawiro': BaristaProfile(
      name: 'Bayu Prawiro',
      slug: 'bayu_prawiro',
      country: 'Indonesia',
      countryCode: 'id',
      specialty: 'Nusantara craft',
      bio: 'Craft barista Indonesia dengan sentuhan nusantara pada pour-over modern.',
      imageAsset: 'assets/images/avatars/portraits/bayu_prawiro.jpg',
    ),
    'carlos_escobar': BaristaProfile(
      name: 'Carlos Escobar',
      slug: 'carlos_escobar',
      country: 'Kolombia',
      countryCode: 'co',
      specialty: 'Colombian origin focus',
      bio: 'Fokus origin Kolombia dengan sweetness dan cacao notes yang kaya.',
      imageAsset: 'assets/images/avatars/portraits/carlos_escobar.jpg',
    ),
    'nas_jaafar': BaristaProfile(
      name: 'Nas Jaafar',
      slug: 'nas_jaafar',
      country: 'Malaysia',
      countryCode: 'my',
      specialty: 'Malaysian competition style',
      bio: 'Gaya kompetisi Malaysia yang dinamis dan ekspresif.',
      imageAsset: 'assets/images/avatars/portraits/nas_jaafar.jpg',
    ),
    'simon_gautherin': BaristaProfile(
      name: 'Simon Gautherin',
      slug: 'simon_gautherin',
      country: 'Australia',
      countryCode: 'au',
      specialty: 'Aussie cafe precision',
      bio: 'Presisi cafe Australia dengan ritme brew yang efisien.',
      imageAsset: 'assets/images/avatars/portraits/simon_gautherin.jpg',
    ),
    'bavis_kwong': BaristaProfile(
      name: 'Bavis Kwong',
      slug: 'bavis_kwong',
      country: 'Hong Kong',
      countryCode: 'hk',
      specialty: 'HK clarity & aroma',
      bio: 'Gaya Hong Kong yang menekankan aroma dan kejernihan cangkir.',
      imageAsset: 'assets/images/avatars/portraits/bavis_kwong.jpg',
    ),
  };

  static BaristaProfile resolve(String rawAuthor, {String? imageUrl}) {
    final slug = BaristaUtils.slugFromAuthor(rawAuthor);
    final known = bySlug[slug];
    if (known != null) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return BaristaProfile(
          name: known.name,
          slug: known.slug,
          country: known.country,
          countryCode: known.countryCode,
          specialty: known.specialty,
          bio: known.bio,
          imageAsset: imageUrl,
        );
      }
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
      imageAsset: imageUrl,
    );
  }
}
