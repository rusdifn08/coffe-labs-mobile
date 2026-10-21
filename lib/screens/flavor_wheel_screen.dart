import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/brew_visual_catalog.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'brew_journal_screen.dart';

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

class FlavorWheelScreen extends StatefulWidget {
  const FlavorWheelScreen({super.key});

  @override
  State<FlavorWheelScreen> createState() => _FlavorWheelScreenState();
}

class _FlavorWheelScreenState extends State<FlavorWheelScreen> {
  // 1. INFORMASI SAMPEL KOPI (Default Bersih / Siap Diisi Cupper)
  final TextEditingController _beanNameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _cupperController = TextEditingController(text: 'Q-Grader Cupper');
  final TextEditingController _customVarietyController = TextEditingController();
  final TextEditingController _customProcessController = TextEditingController();

  String _selectedVariety = 'Bourbon';
  bool _isCustomVariety = false;

  String _selectedProcess = 'Washed';
  bool _isCustomProcess = false;

  String _selectedRoast = 'Light-Medium';
  final List<String> _roastPresets = const [
    'Light',
    'Light-Medium',
    'Medium',
    'Medium-Dark',
    'Dark',
  ];

  String _normalizeRoast(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('light-medium') || lower.contains('light medium')) return 'Light-Medium';
    if (lower.contains('medium-dark') || lower.contains('medium dark')) return 'Medium-Dark';
    if (lower.contains('light')) return 'Light';
    if (lower.contains('dark')) return 'Dark';
    if (lower.contains('medium')) return 'Medium';
    return 'Light-Medium';
  }

  // DAFTAR VARIETAS LENGKAP & KOMPREHENSIF (BOURBON, TYPICA, NUSANTARA, EKSOTIK DUNIA)
  static const List<CoffeeVarietyInfo> _allVarieties = [
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

  final List<String> _popularVarieties = const [
    'Bourbon',
    'Pink Bourbon',
    'Typica / Sigarar Utang',
    'Ateng Super / TimTim',
    'S-795 / Kartika',
    'Geisha / Gesha',
    'Ethiopian Heirloom',
    'SL-28 / SL-34',
    'Caturra / Catuai',
    'Pacamara',
    'Andungsari',
    'Kopyol (Bali)',
    'Custom...',
  ];

  final List<String> _popularProcesses = const [
    'Washed',
    'Natural',
    'Honey Process',
    'Natural Anaerobic',
    'Washed Anaerobic',
    'Yeast Inoculation',
    'Thermal Shock',
    'Slow Dry Natural',
    'Custom...',
  ];

  // 2. TASTING NOTES & FLAVOR WHEEL (Default Kosong)
  final Set<String> _selectedNotes = {};
  String _activeNoteCategory = '🍑 Fruity (Tropis & Batu)';
  final TextEditingController _customNoteInputController = TextEditingController();

  final List<String> _noteCategories = const [
    '🍑 Fruity (Tropis & Batu)',
    '🍎 Orchard Fruit',
    '🍓 Berry',
    '🍋 Citrus',
    '🌸 Floral',
    '🍫 Cokelat & Manis',
    '🥜 Nutty & Rempah',
    '🍵 Teh & Fermentasi',
    '✨ Body & Finish',
  ];

  // 3. SKOR SENSORI CUPPING (STANDAR SCA: 6.00 - 10.00)
  // Flag evaluasi: saat layar dibuka, skor belum dinilai (false)
  bool _hasEvaluated = false;
  double _aromaScore = 8.00;
  double _acidityScore = 8.00;
  double _sweetnessScore = 8.00;
  double _mouthfeelScore = 8.00;
  double _aftertasteScore = 8.00;
  double _balanceScore = 8.00;

  // 4. AFTERTASTE (DESKRIPSI: JUICY, CREAMY, CUSTOM, DLL.)
  String _selectedAftertasteDesc = 'Juicy';
  bool _isCustomAftertaste = false;
  final TextEditingController _customAftertasteController = TextEditingController();

  final List<String> _aftertastePresets = const [
    'Juicy',
    'Creamy',
    'Lingering Sweetness',
    'Clean & Refreshing',
    'Dark Chocolate Finish',
    'Winey & Fruity',
    'Silky Tea-like',
    'Custom...',
  ];

  // 5. MOUTHFEEL (TEKSTUR & BODY)
  String _selectedMouthfeelDesc = 'Silky & Smooth';
  bool _isCustomMouthfeel = false;
  final TextEditingController _customMouthfeelController = TextEditingController();

  final List<String> _mouthfeelPresets = const [
    'Silky & Smooth',
    'Juicy & Round',
    'Creamy & Buttery',
    'Light & Tea-like',
    'Syrupy & Heavy',
    'Velvety & Dense',
    'Clean & Crisp',
    'Custom...',
  ];

  // 6. CATATAN KESIMPULAN (Default Kosong)
  final TextEditingController _cuppingNotesController = TextEditingController();

  @override
  void dispose() {
    _beanNameController.dispose();
    _originController.dispose();
    _cupperController.dispose();
    _customVarietyController.dispose();
    _customProcessController.dispose();
    _customNoteInputController.dispose();
    _customAftertasteController.dispose();
    _customMouthfeelController.dispose();
    _cuppingNotesController.dispose();
    super.dispose();
  }

  // Perhitungan Skor Total Cupping SCA (Standar 100 poin)
  double get _totalCuppingScore {
    if (!_hasEvaluated) return 0.0;
    // Skor dasar kebersihan & keseragaman (Clean Cup 10 + Uniformity 10 + Sweetness base 20 = 40)
    // Ditambah 6 atribut sensoris spesifik (Aroma, Acidity, Sweetness, Mouthfeel, Aftertaste, Balance)
    final sum = _aromaScore + _acidityScore + _sweetnessScore + _mouthfeelScore + _aftertasteScore + _balanceScore;
    return (40.0 + sum).clamp(0.0, 100.0);
  }

  String get _cuppingGradeLabel {
    if (!_hasEvaluated) return '📋 Belum Dinilai (Siap Cupping)';
    final score = _totalCuppingScore;
    if (score >= 90.0) return '🌟 Outstanding (Presidential Award)';
    if (score >= 85.0) return '🏆 Specialty Grade (Excellent)';
    if (score >= 80.0) return '✨ Specialty Grade (Very Good)';
    return '☕ Commercial / Below Specialty';
  }

  Color get _cuppingGradeColor {
    if (!_hasEvaluated) return AppTheme.textMuted;
    final score = _totalCuppingScore;
    if (score >= 90.0) return const Color(0xFFD48806);
    if (score >= 85.0) return AppTheme.primaryBrown;
    if (score >= 80.0) return const Color(0xFF2E7D32);
    return Colors.redAccent;
  }

  void _loadDemoCuppingData() {
    setState(() {
      _hasEvaluated = true;
      _beanNameController.text = 'Aceh Gayo Bener Meriah';
      _originController.text = 'Bener Meriah, Aceh 🇮🇩';
      _cupperController.text = 'Q-Grader Cupping Lab';
      _selectedVariety = 'Bourbon';
      _isCustomVariety = false;
      _selectedProcess = 'Natural Anaerobic';
      _isCustomProcess = false;
      _selectedRoast = 'Light-Medium';
      _selectedNotes.clear();
      _selectedNotes.addAll(['Jasmine', 'Sweet Orange', 'Wild Honey']);
      _selectedAftertasteDesc = 'Juicy';
      _isCustomAftertaste = false;
      _selectedMouthfeelDesc = 'Silky & Smooth';
      _isCustomMouthfeel = false;
      _aromaScore = 8.50;
      _acidityScore = 8.50;
      _sweetnessScore = 8.75;
      _mouthfeelScore = 8.50;
      _aftertasteScore = 8.50;
      _balanceScore = 8.50;
      _cuppingNotesController.text = 'Aroma melati sangat semerbak saat crust dibuka. Acidity jeruk manis menyegarkan dengan aftertaste juicy madu yang bertahan panjang.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contoh sampel demo cupping berhasil dimuat!'),
        backgroundColor: AppTheme.primaryBrown,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetCuppingForm() {
    setState(() {
      _hasEvaluated = false;
      _beanNameController.clear();
      _originController.clear();
      _cupperController.text = 'Q-Grader Cupper';
      _customVarietyController.clear();
      _customProcessController.clear();
      _selectedVariety = 'Bourbon';
      _isCustomVariety = false;
      _selectedProcess = 'Washed';
      _isCustomProcess = false;
      _selectedRoast = 'Light-Medium';
      _selectedNotes.clear();
      _selectedAftertasteDesc = 'Juicy';
      _isCustomAftertaste = false;
      _selectedMouthfeelDesc = 'Silky & Smooth';
      _isCustomMouthfeel = false;
      _aromaScore = 8.00;
      _acidityScore = 8.00;
      _sweetnessScore = 8.00;
      _mouthfeelScore = 8.00;
      _aftertasteScore = 8.00;
      _balanceScore = 8.00;
      _cuppingNotesController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulir cupping berhasil dikosongkan (lembar baru).'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openVarietyModal() {
    String searchQuery = '';
    String selectedCategory = 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final filtered = _allVarieties.where((v) {
              final matchCat = selectedCategory == 'Semua' || v.category.contains(selectedCategory);
              final q = searchQuery.toLowerCase();
              final matchQuery = q.isEmpty ||
                  v.name.toLowerCase().contains(q) ||
                  v.origin.toLowerCase().contains(q) ||
                  v.tasteProfile.toLowerCase().contains(q);
              return matchCat && matchQuery;
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.82,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 22),
                          SizedBox(width: 8),
                          Text('Katalog Lengkap Varietas Kopi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari varietas (Bourbon, Typica, Geisha, S-795)...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: Color(0xFF2E7D32)),
                      filled: true,
                      fillColor: AppTheme.bgCream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 10),
                  // Kategori Chip
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Bourbon', 'Nusantara', 'Eksotik', 'Spesies'].map((cat) {
                        final isSel = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat == 'Semua' ? 'Semua (${_allVarieties.length})' : cat),
                            selected: isSel,
                            selectedColor: const Color(0xFF2E7D32),
                            backgroundColor: AppTheme.bgCream,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : AppTheme.textDark,
                            ),
                            onSelected: (_) => setModalState(() => selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Varietas tidak ditemukan dalam katalog.', style: TextStyle(color: AppTheme.textMuted)),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isCustomVariety = true;
                                      _customVarietyController.text = searchQuery;
                                      _selectedVariety = 'Custom...';
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  icon: const Icon(CupertinoIcons.plus, size: 16),
                                  label: Text('Gunakan "$searchQuery" sebagai Kustom'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final item = filtered[idx];
                              final isCurrent = _effectiveVariety.toLowerCase().contains(item.name.toLowerCase());
                              return Container(
                                decoration: BoxDecoration(
                                  color: isCurrent ? const Color(0xFF2E7D32).withValues(alpha: 0.08) : AppTheme.bgCream,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent ? const Color(0xFF2E7D32) : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.origin,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.tasteProfile,
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
                                      ),
                                    ),
                                    trailing: Icon(
                                      isCurrent ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.chevron_right,
                                      color: isCurrent ? const Color(0xFF2E7D32) : AppTheme.textMuted,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedVariety = item.name;
                                        _isCustomVariety = false;
                                      });
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String get _effectiveAftertaste {
    if (_isCustomAftertaste) {
      final t = _customAftertasteController.text.trim();
      return t.isEmpty ? 'Juicy' : t;
    }
    return _selectedAftertasteDesc;
  }

  String get _effectiveMouthfeel {
    if (_isCustomMouthfeel) {
      final t = _customMouthfeelController.text.trim();
      return t.isEmpty ? 'Silky & Smooth' : t;
    }
    return _selectedMouthfeelDesc;
  }

  String get _effectiveVariety {
    if (_isCustomVariety) {
      final t = _customVarietyController.text.trim();
      return t.isEmpty ? 'Single Origin Variety' : t;
    }
    return _selectedVariety;
  }

  String get _effectiveProcess {
    if (_isCustomProcess) {
      final t = _customProcessController.text.trim();
      return t.isEmpty ? 'Washed Process' : t;
    }
    return _selectedProcess;
  }

  void _openBeanCatalogModal() {
    final List<BeanVisualItem> allBeans = BrewVisualCatalog.beans;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = allBeans.where((b) {
              final q = searchQuery.toLowerCase();
              return b.name.toLowerCase().contains(q) ||
                  b.region.toLowerCase().contains(q) ||
                  b.defaultVariety.toLowerCase().contains(q) ||
                  b.process.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              minChildSize: 0.45,
              maxChildSize: 0.94,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      // Header Modal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Pilih Biji Kopi Cupping',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Search Bar
                      TextField(
                        onChanged: (v) => setModalState(() => searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Cari kopi, daerah, atau varietas...',
                          prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollCtrl,
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final b = filtered[idx];
                            return Card(
                              elevation: 0,
                              color: AppTheme.surfaceWhite,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
                                  child: const Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 20),
                                ),
                                title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(
                                  '${b.region} • ${b.defaultVariety} • ${b.process}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                                trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: AppTheme.textMuted),
                                onTap: () {
                                  setState(() {
                                    _beanNameController.text = b.name;
                                    _originController.text = b.region;
                                    if (_popularVarieties.contains(b.defaultVariety)) {
                                      _selectedVariety = b.defaultVariety;
                                      _isCustomVariety = false;
                                    } else {
                                      _isCustomVariety = true;
                                      _customVarietyController.text = b.defaultVariety;
                                      _selectedVariety = 'Custom...';
                                    }

                                    if (_popularProcesses.contains(b.process)) {
                                      _selectedProcess = b.process;
                                      _isCustomProcess = false;
                                    } else {
                                      _isCustomProcess = true;
                                      _customProcessController.text = b.process;
                                      _selectedProcess = 'Custom...';
                                    }

                                    _selectedRoast = _normalizeRoast(b.roast);
                                    // Tambahkan notes default dari katalog
                                    for (final n in b.defaultNotes) {
                                      _selectedNotes.add(n);
                                    }
                                  });
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _addCustomNote() {
    final note = _customNoteInputController.text.trim();
    if (note.isNotEmpty) {
      setState(() {
        _selectedNotes.add(note);
        _customNoteInputController.clear();
      });
    }
  }

  Future<void> _saveCuppingSession() async {
    if (!_hasEvaluated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lakukan penilaian skor cupping (geser slider sensori) sebelum menyimpan.'),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    final beanName = _beanNameController.text.trim().isEmpty ? 'Specialty Single Origin' : _beanNameController.text.trim();
    final origin = _originController.text.trim();
    final variety = _effectiveVariety;
    final process = _effectiveProcess;
    final roast = _selectedRoast;
    final cupper = _cupperController.text.trim().isEmpty ? 'Cupper' : _cupperController.text.trim();
    final aftertaste = _effectiveAftertaste;
    final mouthfeel = _effectiveMouthfeel;
    final notesText = _selectedNotes.isEmpty ? 'Balanced Specialty Cup' : _selectedNotes.join(', ');
    final evalNotes = _cuppingNotesController.text.trim();
    final score = _totalCuppingScore;
    final rating = (score / 20.0).clamp(1.0, 5.0); // Skala bintang 1.0 - 5.0 untuk Brew Journal

    final summary = '''[SCA Cupping Session • Score: ${score.toStringAsFixed(2)} - $_cuppingGradeLabel]
• Kopi: $beanName ($origin)
• Varietas: $variety | Proses: $process | Sangrai: $roast
• Cupper: $cupper
• Profil Sensoris:
  - Aroma: ${_aromaScore.toStringAsFixed(2)} | Acidity: ${_acidityScore.toStringAsFixed(2)} | Sweetness: ${_sweetnessScore.toStringAsFixed(2)}
  - Mouthfeel / Body: ${_mouthfeelScore.toStringAsFixed(2)} ($mouthfeel)
  - Aftertaste: ${_aftertasteScore.toStringAsFixed(2)} ($aftertaste)
  - Overall Balance: ${_balanceScore.toStringAsFixed(2)}
• Tasting Notes: $notesText
• Catatan Cupping: ${evalNotes.isEmpty ? '-' : evalNotes}''';

    await ApiService.addJournalEntry({
      'recipeId': 0,
      'recipeTitle': 'Cupping: $beanName ($score Poin)',
      'author': cupper,
      'authorAvatarUrl': 'assets/images/avatars/generic_fallback.jpg',
      'authorImageUrl': 'assets/images/avatars/generic_fallback.jpg',
      'grindNote': 'Cupping ($roast • $process)',
      'rating': rating,
      'notes': summary,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sesi Cupping "$beanName" berhasil disimpan ke Brew Journal!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBrown,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Lihat Journal',
          textColor: AppTheme.accentAmber,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Coffee Cupping & Flavor Wheel'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBrown,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Pilih Biji dari Katalog',
            icon: const Icon(Icons.coffee_rounded, color: Colors.white),
            onPressed: _openBeanCatalogModal,
          ),
          IconButton(
            tooltip: 'Katalog Varietas Lengkap',
            icon: const Icon(Icons.eco_rounded, color: Colors.white),
            onPressed: _openVarietyModal,
          ),
          PopupMenuButton<String>(
            tooltip: 'Opsi Lembar Cupping',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (val) {
              if (val == 'reset') {
                _resetCuppingForm();
              } else if (val == 'demo') {
                _loadDemoCuppingData();
              } else if (val == 'journal') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'demo',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.sparkles, size: 16, color: AppTheme.accentAmber),
                    SizedBox(width: 8),
                    Text('Muat Contoh Demo (90.75)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.arrow_counterclockwise, size: 16, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Reset / Formulir Baru'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'journal',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.book_fill, size: 16, color: AppTheme.primaryBrown),
                    SizedBox(width: 8),
                    Text('Buka Brew Journal'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO CARD: SKOR CUPPING REAL-TIME & STATUS GRADE SCA
            _buildHeroScoreCard(),
            const SizedBox(height: 18),

            // SEKSI 1: INFORMASI SAMPEL KOPI (BIJI, ASAL, VARIETAS, PROSES, ROAST)
            _buildCoffeeInfoSection(),
            const SizedBox(height: 18),

            // SEKSI 2: FLAVOR WHEEL & TASTING NOTES VISUAL
            _buildFlavorNotesSection(),
            const SizedBox(height: 18),

            // SEKSI 3: AFTERTASTE DENGAN DESKRIPSI (JUICY, CREAMY, CUSTOM, DLL.)
            _buildAftertasteSection(),
            const SizedBox(height: 18),

            // SEKSI 4: MOUTHFEEL / BODY DENGAN DESKRIPSI (SILKY, JUICY, CUSTOM, DLL.)
            _buildMouthfeelSection(),
            const SizedBox(height: 18),

            // SEKSI 5: PROFIL SENSORIS LAINNYA (AROMA, ACIDITY, SWEETNESS, BALANCE)
            _buildSensoryScoresSection(),
            const SizedBox(height: 18),

            // SEKSI 6: CATATAN SENSORIS CUPPER & EVALUASI
            _buildNotesSection(),
            const SizedBox(height: 24),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveCuppingSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 20),
                label: const Text(
                  'Simpan Sesi Cupping ke Journal',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: HERO CARD SKOR CUPPING
  Widget _buildHeroScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL CUPPING SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _hasEvaluated ? _totalCuppingScore.toStringAsFixed(2) : '--',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: _cuppingGradeColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ 100',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _cuppingGradeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _cuppingGradeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _cuppingGradeLabel.split('(').first.trim(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: _cuppingGradeColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Mini Metrics Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Aroma', _hasEvaluated ? _aromaScore : null),
              _buildMiniMetric('Acidity', _hasEvaluated ? _acidityScore : null),
              _buildMiniMetric('Sweet', _hasEvaluated ? _sweetnessScore : null),
              _buildMiniMetric('Mouthfeel', _hasEvaluated ? _mouthfeelScore : null),
              _buildMiniMetric('Aftertaste', _hasEvaluated ? _aftertasteScore : null),
            ],
          ),
          if (!_hasEvaluated) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasEvaluated = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: const BorderSide(color: AppTheme.primaryBrown, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(CupertinoIcons.play_fill, size: 14),
                    label: const Text('Mulai Penilaian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadDemoCuppingData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.primaryBrown,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBrown),
                    label: const Text('Muat Contoh Demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _resetCuppingForm,
                  icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 13, color: AppTheme.textMuted),
                  label: const Text('Reset Form', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, double? val) {
    return Column(
      children: [
        Text(
          val != null ? val.toStringAsFixed(2) : '--',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // WIDGET: SEKSI 1 INFORMASI SAMPEL KOPI
  Widget _buildCoffeeInfoSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.coffee_rounded, color: AppTheme.primaryBrown, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '1. Sampel Biji Kopi Cupping',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _openBeanCatalogModal,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                icon: const Icon(CupertinoIcons.search, size: 12, color: AppTheme.primaryBrown),
                label: const Text(
                  'Katalog',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama Kopi & Asal Daerah
          TextField(
            controller: _beanNameController,
            decoration: InputDecoration(
              labelText: 'Nama Kopi / Single Origin',
              labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              prefixIcon: const Icon(Icons.coffee_rounded, size: 18, color: AppTheme.primaryBrown),
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _originController,
            decoration: InputDecoration(
              labelText: 'Asal Daerah / Negara',
              labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              prefixIcon: const Icon(CupertinoIcons.globe, size: 18, color: AppTheme.primaryBrown),
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 14),

          // Varietas Kopi Selector
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              const Text('Varietas Kopi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const Spacer(),
              InkWell(
                onTap: _openVarietyModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.search, size: 11, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text('Katalog Lengkap (30+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Terpilih: ', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
              Expanded(
                child: Text(
                  _effectiveVariety,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _popularVarieties.map((v) {
                final isSelected = (_selectedVariety == v && !_isCustomVariety) || (v == 'Custom...' && _isCustomVariety);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(v, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textDark)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32),
                    backgroundColor: AppTheme.bgCream,
                    onSelected: (_) {
                      setState(() {
                        if (v == 'Custom...') {
                          _isCustomVariety = true;
                        } else {
                          _selectedVariety = v;
                          _isCustomVariety = false;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isCustomVariety) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customVarietyController,
              decoration: InputDecoration(
                hintText: 'Ketik varietas kustom (misal: Pacamara, Sidra, Typica)...',
                filled: true,
                fillColor: AppTheme.bgCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Proses Pasca-Panen Selector
          Row(
            children: [
              const Icon(Icons.science_rounded, size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 6),
              const Text('Proses Pasca-Panen:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const Spacer(),
              Text(_effectiveProcess, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _popularProcesses.map((p) {
                final isSelected = (_selectedProcess == p && !_isCustomProcess) || (p == 'Custom...' && _isCustomProcess);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(p, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textDark)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE65100),
                    backgroundColor: AppTheme.bgCream,
                    onSelected: (_) {
                      setState(() {
                        if (p == 'Custom...') {
                          _isCustomProcess = true;
                        } else {
                          _selectedProcess = p;
                          _isCustomProcess = false;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isCustomProcess) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customProcessController,
              decoration: InputDecoration(
                hintText: 'Ketik proses kustom (misal: Yeast Fermentation, Carbonic Maceration)...',
                filled: true,
                fillColor: AppTheme.bgCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Tingkat Sangrai & Nama Cupper
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('roast_dropdown_$_selectedRoast'),
                  initialValue: _roastPresets.contains(_selectedRoast) ? _selectedRoast : 'Light-Medium',
                  decoration: InputDecoration(
                    labelText: 'Roast Level',
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: _roastPresets.map((r) {
                    String label = r;
                    if (r == 'Light') {
                      label = 'Light Roast';
                    } else if (r == 'Medium') {
                      label = 'Medium Roast';
                    } else if (r == 'Dark') {
                      label = 'Dark Roast';
                    }
                    return DropdownMenuItem(value: r, child: Text(label, style: const TextStyle(fontSize: 12.5)));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedRoast = v);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _cupperController,
                  decoration: InputDecoration(
                    labelText: 'Nama Cupper',
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: SEKSI 2 FLAVOR WHEEL & TASTING NOTES VISUAL (WAJIB PILIH PER KATEGORI)
  Widget _buildFlavorNotesSection() {
    final catClean = _activeNoteCategory.toLowerCase();
    final List<FlavorNoteVisualItem> displayedNotes = BrewVisualCatalog.flavorNotes.where((fn) {
      final g = fn.group.toLowerCase();
      if (catClean.contains('fruity')) return g == 'stone fruit' || g == 'tropical';
      if (catClean.contains('orchard')) return g == 'orchard fruit';
      if (catClean.contains('berry')) return g == 'berry';
      if (catClean.contains('citrus')) return g == 'citrus';
      if (catClean.contains('floral')) return g == 'floral';
      if (catClean.contains('cokelat') || catClean.contains('manis')) return g == 'sweet' || g == 'cocoa';
      if (catClean.contains('nutty') || catClean.contains('rempah')) return g == 'nutty' || g == 'herbal';
      if (catClean.contains('teh') || catClean.contains('fermentasi')) return g == 'tea-like' || g == 'winey';
      if (catClean.contains('body') || catClean.contains('finish')) return g == 'mouthfeel';
      return false;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.sparkles, color: AppTheme.accentAmber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '2. Flavor Wheel & Tasting Notes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_selectedNotes.length} Terpilih',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Category Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _noteCategories.map((cat) {
                final isSelected = _activeNoteCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.bgCream,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) => setState(() => _activeNoteCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Flavor Notes Wrap Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayedNotes.map((fn) {
              final isSelected = _selectedNotes.contains(fn.label);
              return FlavorNoteVisualBadge(
                noteText: fn.label,
                selected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedNotes.remove(fn.label);
                    } else {
                      _selectedNotes.add(fn.label);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Custom Note Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customNoteInputController,
                  decoration: InputDecoration(
                    hintText: 'Tambah rasa unik custom (misal: Earl Grey Apricot)...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _addCustomNote(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addCustomNote,
                icon: const Icon(CupertinoIcons.plus, size: 18),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
              ),
            ],
          ),

          // Selected Notes Summary
          if (_selectedNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedNotes.map((note) {
                return Chip(
                  label: Text(note, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: AppTheme.primaryBrown,
                  deleteIcon: const Icon(CupertinoIcons.xmark, size: 12, color: Colors.white),
                  onDeleted: () => setState(() => _selectedNotes.remove(note)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // WIDGET: SEKSI 3 AFTERTASTE DENGAN DESKRIPSI (JUICY, CREAMY, CUSTOM, DLL.)
  Widget _buildAftertasteSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.drop_triangle_fill, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '3. Aftertaste (Sensasi Akhir)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Text(
                'Skor: ${_aftertasteScore.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Karakter rasa yang tertinggal di langit-langit mulut setelah kopi ditelan:',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),

          // Slider Skor Aftertaste
          _buildCuppingSlider(_aftertasteScore, (v) => setState(() => _aftertasteScore = v)),
          const SizedBox(height: 10),

          // Descriptors Chips: Juicy, Creamy, Custom dll
          Row(
            children: [
              const Text('Karakter Aftertaste: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              Text(_effectiveAftertaste, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.accentAmber)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _aftertastePresets.map((desc) {
              final isSelected = (_selectedAftertasteDesc == desc && !_isCustomAftertaste) || (desc == 'Custom...' && _isCustomAftertaste);
              return ChoiceChip(
                label: Text(desc),
                selected: isSelected,
                selectedColor: AppTheme.accentAmber,
                backgroundColor: AppTheme.bgCream,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
                onSelected: (_) {
                  setState(() {
                    if (desc == 'Custom...') {
                      _isCustomAftertaste = true;
                    } else {
                      _selectedAftertasteDesc = desc;
                      _isCustomAftertaste = false;
                    }
                  });
                },
              );
            }).toList(),
          ),

          // Custom Aftertaste Input Field
          if (_isCustomAftertaste) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customAftertasteController,
              decoration: InputDecoration(
                hintText: 'Tuliskan deskripsi aftertaste kustom (misal: Juicy apel malang, lingering chocolate)...',
                hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }

  // WIDGET: SEKSI 4 MOUTHFEEL / BODY DENGAN DESKRIPSI (SILKY, JUICY, CREAMY, CUSTOM)
  Widget _buildMouthfeelSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.circle_bottomthird_split, color: Color(0xFF00ACC1), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '4. Mouthfeel / Body (Tekstur)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Text(
                'Skor: ${_mouthfeelScore.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Sensasi bobot, kekentalan, dan kehalusan cairan kopi di lidah:',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),

          // Slider Skor Mouthfeel
          _buildCuppingSlider(_mouthfeelScore, (v) => setState(() => _mouthfeelScore = v)),
          const SizedBox(height: 10),

          // Descriptors Chips: Silky, Juicy, Creamy, Custom dll
          Row(
            children: [
              const Text('Tekstur Lidah: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              Text(_effectiveMouthfeel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF00ACC1))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _mouthfeelPresets.map((desc) {
              final isSelected = (_selectedMouthfeelDesc == desc && !_isCustomMouthfeel) || (desc == 'Custom...' && _isCustomMouthfeel);
              return ChoiceChip(
                label: Text(desc),
                selected: isSelected,
                selectedColor: const Color(0xFF00ACC1),
                backgroundColor: AppTheme.bgCream,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
                onSelected: (_) {
                  setState(() {
                    if (desc == 'Custom...') {
                      _isCustomMouthfeel = true;
                    } else {
                      _selectedMouthfeelDesc = desc;
                      _isCustomMouthfeel = false;
                    }
                  });
                },
              );
            }).toList(),
          ),

          // Custom Mouthfeel Input Field
          if (_isCustomMouthfeel) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customMouthfeelController,
              decoration: InputDecoration(
                hintText: 'Tuliskan tekstur mouthfeel kustom (misal: Silky lembut seperti teh hijau, creamy mentega)...',
                hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }

  // WIDGET: SEKSI 5 PROFIL SENSORIS LAINNYA (AROMA, ACIDITY, SWEETNESS, BALANCE)
  Widget _buildSensoryScoresSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 20),
              SizedBox(width: 8),
              Text(
                '5. Atribut Sensori SCA Lengkap',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fragrance / Aroma
          _buildScoreRow('Aroma & Fragrance (Wangi Kering / Basah)', _aromaScore, (v) => setState(() => _aromaScore = v)),
          const Divider(height: 18),

          // Acidity
          _buildScoreRow('Acidity (Kecerahan Asam Buah)', _acidityScore, (v) => setState(() => _acidityScore = v)),
          const Divider(height: 18),

          // Sweetness
          _buildScoreRow('Sweetness (Kemanisan Alami)', _sweetnessScore, (v) => setState(() => _sweetnessScore = v)),
          const Divider(height: 18),

          // Balance
          _buildScoreRow('Overall Balance (Keseimbangan Cangkir)', _balanceScore, (v) => setState(() => _balanceScore = v)),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                score.toStringAsFixed(2),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
              ),
            ),
          ],
        ),
        _buildCuppingSlider(score, onChanged),
      ],
    );
  }

  Widget _buildCuppingSlider(double value, Function(double) onChanged) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppTheme.primaryBrown,
        inactiveTrackColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
        thumbColor: AppTheme.primaryBrown,
        overlayColor: AppTheme.primaryBrown.withValues(alpha: 0.18),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        trackHeight: 4,
      ),
      child: Slider(
        value: value,
        min: 6.0,
        max: 10.0,
        divisions: 16, // Kelipatan 0.25 (standar lembar cupping SCA)
        onChanged: (v) {
          if (!_hasEvaluated) {
            setState(() => _hasEvaluated = true);
          }
          onChanged(v);
        },
      ),
    );
  }

  // WIDGET: SEKSI 6 CATATAN CUPPER
  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: AppTheme.primaryBrown, size: 20),
              SizedBox(width: 8),
              Text(
                '6. Kesimpulan & Catatan Cupper',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cuppingNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tuliskan evaluasi sensoris, kebersihan cangkir (clean cup), atau rekomendasi resep seduh...',
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}
