class CoffeeVarietyInfo {
  final String name;
  final String category;
  final String origin;
  final String tasteProfile;

  const CoffeeVarietyInfo({
    required this.name,
    required this.category,
    required this.origin,
    required this.tasteProfile,
  });
}

class CoffeeVarietiesCatalog {
  static const List<CoffeeVarietyInfo> all = [
    // BOURBON FAMILY
    CoffeeVarietyInfo(
      name: 'Bourbon',
      category: 'Bourbon Family',
      origin: 'Pulau Réunion / Dunia',
      tasteProfile: 'Manis karamel alami tinggi, keasaman kompleks, body berimbang & halus.',
    ),
    CoffeeVarietyInfo(
      name: 'Pink Bourbon',
      category: 'Bourbon Family',
      origin: 'Huila, Kolombia',
      tasteProfile: 'Aroma melati semerbak, buah peach, keasaman sitrun manis elegan.',
    ),
    CoffeeVarietyInfo(
      name: 'Yellow Bourbon',
      category: 'Bourbon Family',
      origin: 'Brasil / Amerika Latin',
      tasteProfile: 'Body lembut dan tebal, rasa almond madu dan cokelat manis.',
    ),
    CoffeeVarietyInfo(
      name: 'Red Bourbon',
      category: 'Bourbon Family',
      origin: 'Rwanda / Burundi / El Salvador',
      tasteProfile: 'Manis buah plum, gula merah karamel, keasaman ceri cerah.',
    ),
    CoffeeVarietyInfo(
      name: 'Bourbon Pointu (Laurina)',
      category: 'Bourbon Family',
      origin: 'Pulau Réunion',
      tasteProfile: 'Alami rendah kafein, keasaman buah halus dan rasa super clean.',
    ),
    CoffeeVarietyInfo(
      name: 'Caturra',
      category: 'Bourbon Family',
      origin: 'Brasil / Kolombia',
      tasteProfile: 'Mutasi alami Bourbon, bright acidity, sitrun segar & manis gula tebu.',
    ),
    CoffeeVarietyInfo(
      name: 'Catuai',
      category: 'Bourbon Family',
      origin: 'Brasil / Amerika Tengah',
      tasteProfile: 'Persilangan Mundo Novo x Caturra, aftertaste bersih & manis.',
    ),
    CoffeeVarietyInfo(
      name: 'Pacas',
      category: 'Bourbon Family',
      origin: 'El Salvador',
      tasteProfile: 'Mutasi kerdil Bourbon, floral, keasaman buah sedang menyegarkan.',
    ),
    CoffeeVarietyInfo(
      name: 'Villa Sarchi',
      category: 'Bourbon Family',
      origin: 'Kosta Rika',
      tasteProfile: 'Mutasi Bourbon, keasaman anggur cerah, manis buah persik madu.',
    ),

    // TYPICA & TRADISIONAL NUSANTARA
    CoffeeVarietyInfo(
      name: 'Typica / Bergendal',
      category: 'Nusantara',
      origin: 'Nusantara / Yaman',
      tasteProfile: 'Induk arabika klasik tertua, floral bersih, rasa manis berimbang.',
    ),
    CoffeeVarietyInfo(
      name: 'Sigarar Utang (Typica Sumatera)',
      category: 'Nusantara',
      origin: 'Sumatera Utara (Gayo / Lintong)',
      tasteProfile: 'Varietas unggulan nasional, aroma rempah herba & buah manis.',
    ),
    CoffeeVarietyInfo(
      name: 'Ateng Super / TimTim (Catimor)',
      category: 'Nusantara',
      origin: 'Aceh Gayo / Timor',
      tasteProfile: 'Body tebal sirupis, aroma herbal tanah basah khas, cokelat gelap.',
    ),
    CoffeeVarietyInfo(
      name: 'S-795 (Jember) / Lini S',
      category: 'Nusantara',
      origin: 'Jember / Toraja / Wamena',
      tasteProfile: 'Body sirupis tebal, rasa cokelat moka, keasaman buah matang.',
    ),
    CoffeeVarietyInfo(
      name: 'Kartika (Catimor)',
      category: 'Nusantara',
      origin: 'Jawa Barat / Bali',
      tasteProfile: 'Asam sitrun cerah menyegarkan, manis tebu, aftertaste bersih.',
    ),
    CoffeeVarietyInfo(
      name: 'Andungsari',
      category: 'Nusantara',
      origin: 'Kayumas / Jawa Barat',
      tasteProfile: 'Aroma bunga jeruk manis, keasaman seimbang, aftertaste panjang.',
    ),
    CoffeeVarietyInfo(
      name: 'Kopyol (Bali Kintamani)',
      category: 'Nusantara',
      origin: 'Kintamani, Bali',
      tasteProfile: 'Khas jeruk kintamani (citrusy), floral wangi, body ringan halus.',
    ),
    CoffeeVarietyInfo(
      name: 'Java / Abyssinia',
      category: 'Nusantara',
      origin: 'Jawa / Ethiopia',
      tasteProfile: 'Karakter spicy manis, cokelat rempah, keasaman halus elegan.',
    ),
    CoffeeVarietyInfo(
      name: 'Komasti',
      category: 'Nusantara',
      origin: 'Puslitkoka Jember',
      tasteProfile: 'Seleksi unggul nasional, citarasa sangat bersih dan manis gula aren.',
    ),
    CoffeeVarietyInfo(
      name: 'Usda 762',
      category: 'Nusantara',
      origin: 'Mandheling Klasik',
      tasteProfile: 'Body sangat tebal, karakter earthy manis dan rempah kakao.',
    ),
    CoffeeVarietyInfo(
      name: 'Besemah Pagaralam',
      category: 'Nusantara',
      origin: 'Sumatera Selatan',
      tasteProfile: 'Khas dataran tinggi Dempo, aroma rempah hangat dan gula merah.',
    ),
    CoffeeVarietyInfo(
      name: 'Maragogype (Biji Gajah)',
      category: 'Nusantara',
      origin: 'Brasil / Nikaragua',
      tasteProfile: 'Ukuran biji sangat besar, tekstur lembut, aroma floral halus.',
    ),
    CoffeeVarietyInfo(
      name: 'Pacamara',
      category: 'Nusantara',
      origin: 'El Salvador',
      tasteProfile: 'Persilangan Pacas x Maragogype, buah tropis eksotis, juicy pekat.',
    ),

    // EKSOTIK DUNIA
    CoffeeVarietyInfo(
      name: 'Geisha / Gesha',
      category: 'Eksotik Dunia',
      origin: 'Panama / Colombia / Gesha Village',
      tasteProfile: 'Aroma melati spektakuler, teh bergamot earl grey, peach & mangga.',
    ),
    CoffeeVarietyInfo(
      name: 'Ethiopian Heirloom',
      category: 'Eksotik Dunia',
      origin: 'Yirgacheffe / Guji, Ethiopia',
      tasteProfile: 'Varietas purba hutan liar, blueberry, teh hitam melati bergamot.',
    ),
    CoffeeVarietyInfo(
      name: 'SL-28',
      category: 'Eksotik Dunia',
      origin: 'Nyeri / Kirinyaga, Kenya',
      tasteProfile: 'Blackcurrant intens, phosphoric acidity tinggi, juicy buah beri.',
    ),
    CoffeeVarietyInfo(
      name: 'SL-34',
      category: 'Eksotik Dunia',
      origin: 'Kenya',
      tasteProfile: 'Body lembut seperti sutra, rasa jeruk manis dan buah plum matang.',
    ),
    CoffeeVarietyInfo(
      name: 'Wush Wush',
      category: 'Eksotik Dunia',
      origin: 'Ethiopia / Kolombia',
      tasteProfile: 'Fermentasi buah tropis nanas markisa, floral manis pekat.',
    ),
    CoffeeVarietyInfo(
      name: 'Sudan Rume',
      category: 'Eksotik Dunia',
      origin: 'Sudan / Kolombia',
      tasteProfile: 'Varietas purba, aroma rempah kapulaga, buah mangga manis juicy.',
    ),
    CoffeeVarietyInfo(
      name: 'Eugenioides',
      category: 'Eksotik Dunia',
      origin: 'Danau Kivu, Afrika',
      tasteProfile: 'Induk Coffea Arabica, rasa manis alami luar biasa seperti madu sereal.',
    ),
    CoffeeVarietyInfo(
      name: 'Castillo',
      category: 'Eksotik Dunia',
      origin: 'Kolombia',
      tasteProfile: 'Keasaman seimbang, rasa karamel, sitrun dan cokelat susu.',
    ),
    CoffeeVarietyInfo(
      name: 'Sidra',
      category: 'Eksotik Dunia',
      origin: 'Ekuador / Kolombia',
      tasteProfile: 'Hibrida Red Bourbon x Typica, floral mawar dan apel hijau renyah.',
    ),

    // SPESIES SPESIAL LAINNYA
    CoffeeVarietyInfo(
      name: 'Fine Robusta (BP 42 / BP 358)',
      category: 'Spesies Lain',
      origin: 'Temanggung / Dampit / Lampung',
      tasteProfile: 'Cokelat hitam pekat, kacang hazelnut, body tebal, rendah asam.',
    ),
    CoffeeVarietyInfo(
      name: 'Liberica / Excelsa',
      category: 'Spesies Lain',
      origin: 'Jambi / Riau / Wonosalam',
      tasteProfile: 'Aroma nangka manis unik, smoky manis, body sangat tebal.',
    ),
  ];
}
