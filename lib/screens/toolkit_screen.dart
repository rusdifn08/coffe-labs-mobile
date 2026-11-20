import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';
import '../widgets/toolkit_card.dart';
import '../widgets/toolkit_section_svg_icons.dart';
import 'bean_freshness_screen.dart';
import '../features/beans_radar/models/beans_radar_models.dart';
import 'bean_radar_screen.dart';
import 'bean_recipe_recommender_screen.dart';
import 'brew_journal_screen.dart';
import 'coffee_roastery_screen.dart';
import 'dial_in_assistant_screen.dart';
import 'favorites_screen.dart';
import 'flavor_wheel_screen.dart';
import 'four_six_calculator_screen.dart';
import 'grinder_converter_screen.dart';
import 'marketplace_screen.dart';
import 'smart_scale_screen.dart';
import 'social_coffee_screen.dart';
import 'tds_extraction_screen.dart';
import 'water_recipe_screen.dart';
import '../features/annotation_studio/presentation/studio_ai_hub_screen.dart';
import '../features/barista_toolkit/presentation/brew_doctor/brew_doctor_compass_screen.dart';
import '../features/barista_toolkit/presentation/ebook_reader/ebook_library_screen.dart';
import '../features/barista_toolkit/presentation/game_brew/game_brew_v60_screen.dart';
import '../features/barista_toolkit/presentation/lms_academy/barista_lms_courses_screen.dart';
import '../features/live_brew/presentation/screens/customer_live_brew_tracker_screen.dart';

class ToolkitScreen extends StatefulWidget {
  const ToolkitScreen({super.key});

  @override
  State<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends State<ToolkitScreen> {
  bool _isTrial = false;
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    LanguageService.changeNotifier.addListener(_onLanguageChange);
    TrialService.changeNotifier.addListener(_checkTrialStatus);
    AuthService.changeNotifier.addListener(_checkTrialStatus);
    _checkTrialStatus();
  }

  @override
  void dispose() {
    LanguageService.changeNotifier.removeListener(_onLanguageChange);
    TrialService.changeNotifier.removeListener(_checkTrialStatus);
    AuthService.changeNotifier.removeListener(_checkTrialStatus);
    super.dispose();
  }

  Future<void> _checkTrialStatus() async {
    await TrialService.getPolicy();
    final trial = await TrialService.isTrialMode();
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isTrial = trial &&
            (user == null || (!user.isPro && !user.isBusiness && !user.isAdmin));
      });
    }
  }

  void _onLanguageChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final lockSmartBrew = TrialService.isToolkitItemLocked(
      isTrial: _isTrial,
      sectionId: 'smart_brew',
      user: _currentUser,
    );
    final lockLab = TrialService.isToolkitItemLocked(
      isTrial: _isTrial,
      sectionId: 'lab',
      user: _currentUser,
    );

    // 1. Lab Ekstraksi & AI
    final List<ToolkitItem> extractionTools = [
      ToolkitItem(
        featureKey: 'SMART_BREW_AI',
        title: isEn ? 'Smart Brew Dial-In' : 'Smart Brew AI',
        subtitle: isEn ? 'Roast, process & cup prediction' : 'Kalkulator Smart Brew & profil rasa',
        iconType: 'smart_brew_ai',
        fallbackIcon: Icons.auto_awesome_rounded,
        primaryColor: AppTheme.primaryBrown,
        secondaryColor: AppTheme.accentAmber,
        gradientColors: const [Color(0xFFFAF3EC), Color(0xFFF3E7DC)],
        destination: const BeanRecipeRecommenderScreen(),
        isLocked: lockSmartBrew,
      ),
      ToolkitItem(
        featureKey: 'AI_BEAN_SCANNER',
        title: isEn ? 'AI Bean Studio' : 'Studio AI',
        subtitle: isEn ? 'Train custom coffee bag models' : 'Latih AI kenali kemasan kopi baru',
        iconType: 'studio_ai',
        fallbackIcon: CupertinoIcons.camera_viewfinder,
        primaryColor: const Color(0xFFD4AF37),
        secondaryColor: const Color(0xFF5C3A21),
        gradientColors: const [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        destination: const StudioAiHubScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'DIAL_IN_ASSISTANT',
        title: isEn ? 'Dial-In Assistant' : 'Asisten Dial-In',
        subtitle: isEn ? 'Fix sour, bitter & channeling' : 'Solusi asam, pahit & channeling',
        iconType: 'dialin',
        fallbackIcon: Icons.tune_rounded,
        primaryColor: const Color(0xFFC2185B),
        secondaryColor: const Color(0xFFFF80AB),
        gradientColors: const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
        destination: const DialInAssistantScreen(),
        isLocked: lockSmartBrew,
      ),
      ToolkitItem(
        featureKey: 'GRINDER_MATRIX',
        title: isEn ? 'Grinder Click Matrix' : 'Matriks Grinder',
        subtitle: isEn ? 'C40, 1Zpresso, Timemore, Ode' : 'Konversi klik C40, 1Zpresso, Ode',
        iconType: 'grinder',
        fallbackIcon: Icons.grain_rounded,
        primaryColor: const Color(0xFF4527A0),
        secondaryColor: const Color(0xFFB39DDB),
        gradientColors: const [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
        destination: const GrinderConverterScreen(),
        isLocked: lockLab,
      ),
      ToolkitItem(
        featureKey: 'FOUR_SIX_CALC',
        title: isEn ? '4:6 Method Calc' : 'Kalkulator 4:6',
        subtitle: isEn ? 'Kasuya 4:6 sweet/acid & body' : 'Metode Kasuya 40% rasa & 60% body',
        iconType: 'foursix',
        fallbackIcon: Icons.calculate_rounded,
        primaryColor: const Color(0xFFE65100),
        secondaryColor: const Color(0xFFFFB74D),
        gradientColors: const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        destination: const FourSixCalculatorScreen(),
        isLocked: lockLab,
      ),
      ToolkitItem(
        featureKey: 'TDS_EXTRACTION',
        title: isEn ? 'SCA TDS & Extraction' : 'Ekstraksi & TDS',
        subtitle: isEn ? 'Extraction yield % & Golden Cup' : 'Kalkulator EY (%) & Golden Cup SCA',
        iconType: 'tds',
        fallbackIcon: Icons.science_rounded,
        primaryColor: const Color(0xFF2E7D32),
        secondaryColor: const Color(0xFFA5D6A7),
        gradientColors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        destination: const TdsExtractionScreen(),
        isLocked: lockLab,
      ),
    ];

    // 2. Coffee Science & Beans
    final List<ToolkitItem> scienceTools = [
      ToolkitItem(
        featureKey: 'WATER_CHEMISTRY',
        title: isEn ? 'Water Chemistry' : 'Kimia Air Seduh',
        subtitle: isEn ? 'SCA, Rao & Lotus drops recipe' : 'Resep mineral air SCA & Lotus',
        iconType: 'water',
        fallbackIcon: CupertinoIcons.drop_fill,
        primaryColor: const Color(0xFF00838F),
        secondaryColor: const Color(0xFF80DEEA),
        gradientColors: const [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
        destination: const WaterRecipeScreen(),
        isLocked: lockLab,
      ),
      ToolkitItem(
        featureKey: 'BEAN_FRESHNESS',
        title: isEn ? 'Bean Freshness' : 'Kesegaran Biji',
        subtitle: isEn ? 'CO2 degassing & peak flavor' : 'Kurva degassing & puncak rasa',
        iconType: 'freshness',
        fallbackIcon: Icons.show_chart_rounded,
        primaryColor: const Color(0xFFD84315),
        secondaryColor: const Color(0xFFFFAB91),
        gradientColors: const [Color(0xFFFBE9E7), Color(0xFFFFCCBC)],
        destination: const BeanFreshnessScreen(),
        isLocked: lockLab,
      ),
      ToolkitItem(
        featureKey: 'SMART_SCALE',
        title: isEn ? 'Smart Scale' : 'Smart Scale Brew',
        subtitle: isEn ? 'Bluetooth scale & live flow rate' : 'Timbangan Bluetooth & flow-rate',
        iconType: 'scale',
        fallbackIcon: Icons.scale_rounded,
        primaryColor: const Color(0xFF00796B),
        secondaryColor: const Color(0xFF80CBC4),
        gradientColors: const [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
        destination: const SmartScaleScreen(),
        isLocked: lockLab,
      ),
      ToolkitItem(
        featureKey: 'CUPPING_FLAVOR',
        title: isEn ? 'Cupping Flavor' : 'Cupping Flavour',
        subtitle: isEn ? 'SCA flavor wheel & sensory notes' : 'Roda rasa SCA & profil sensorik',
        iconType: 'cupping',
        fallbackIcon: Icons.donut_large_rounded,
        primaryColor: const Color(0xFFF57C00),
        secondaryColor: const Color(0xFFFFCC80),
        gradientColors: const [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        destination: const FlavorWheelScreen(),
        isLocked: lockLab,
      ),
    ];

    // 3. Ecosystem & Community (Terbuka Bebas untuk Pengunjung)
    final List<ToolkitItem> ecosystemTools = [
      ToolkitItem(
        featureKey: 'MARKETPLACE_KOPI',
        title: isEn ? 'Marketplace' : 'Marketplace Kopi',
        subtitle: isEn
            ? 'Shop specialty coffee beans & checkout'
            : 'Belanja biji kopi specialty & checkout',
        iconType: 'marketplace',
        fallbackIcon: Icons.storefront_rounded,
        primaryColor: const Color(0xFF8D4925),
        secondaryColor: const Color(0xFFD7A86E),
        gradientColors: const [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
        destination: const MarketplaceScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'COFFEE_ROASTERY',
        title: isEn ? 'Coffee Roastery' : 'Coffee Roastery',
        subtitle: isEn
            ? 'Roastery directory, lineups & Business Studio'
            : 'Direktori roastery, lineup & Studio Bisnis',
        iconType: 'roastery',
        fallbackIcon: Icons.local_fire_department_rounded,
        primaryColor: const Color(0xFF5D4037),
        secondaryColor: const Color(0xFFBCAAA4),
        gradientColors: const [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
        destination: const CoffeeRoasteryScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'BEANS_RADAR',
        title: isEn ? 'Beans Radar' : 'Beans Radar',
        subtitle: isEn
            ? 'Roasteries & specialty bean sellers'
            : 'Roastery & kafe penjual biji kopi',
        iconType: 'radar',
        fallbackIcon: Icons.radar_rounded,
        primaryColor: const Color(0xFF1565C0),
        secondaryColor: const Color(0xFF90CAF9),
        gradientColors: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        destination: const BeanRadarScreen(initialMode: RadarAppMode.beans),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'CAFE_RADAR',
        title: isEn ? 'Cafe Radar' : 'Cafe Radar',
        subtitle: isEn
            ? '10.000+ cafes, coffee shops & restos'
            : '10.000+ cafe, resto & tempat ngopi',
        iconType: 'cafe_radar',
        fallbackIcon: Icons.local_cafe_rounded,
        primaryColor: const Color(0xFF0F766E),
        secondaryColor: const Color(0xFF5EEAD4),
        gradientColors: const [Color(0xFFCCFBF1), Color(0xFF99F6E4)],
        destination: const BeanRadarScreen(initialMode: RadarAppMode.cafe),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'JURNAL_BREW',
        title: isEn ? 'Brew Journal' : 'Jurnal Brew',
        subtitle: isEn ? 'Extraction logs & sensory ratings' : 'Catatan ekstraksi & log seduh',
        iconType: 'journal',
        fallbackIcon: Icons.menu_book_rounded,
        primaryColor: const Color(0xFF303F9F),
        secondaryColor: const Color(0xFF9FA8DA),
        gradientColors: const [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
        destination: const BrewJournalScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'SOCIAL_COFFEE',
        title: isEn ? 'Social Coffee' : 'Social Coffee',
        subtitle: isEn ? 'Barista community & recipe sharing' : 'Komunitas barista & diskusi resep',
        iconType: 'social',
        fallbackIcon: CupertinoIcons.chat_bubble_2_fill,
        primaryColor: const Color(0xFFAD1457),
        secondaryColor: const Color(0xFFF48FB1),
        gradientColors: const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
        destination: const SocialCoffeeScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'FAVORITE_RECIPES',
        title: isEn ? 'Favorites' : 'Favorite',
        subtitle: isEn ? 'Saved champion recipes collection' : 'Koleksi resep seduh favorit Anda',
        iconType: 'favorite',
        fallbackIcon: CupertinoIcons.heart_fill,
        primaryColor: const Color(0xFFD32F2F),
        secondaryColor: const Color(0xFFFF8A80),
        gradientColors: const [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
        destination: const FavoritesScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'LIVE_BREW_QR',
        title: 'Live Brew QR',
        subtitle: isEn ? 'Track live barista pour & cheers' : 'Lacak seduhan barista live via QR',
        iconType: 'live_brew',
        fallbackIcon: Icons.qr_code_2_rounded,
        primaryColor: const Color(0xFF8D4E00),
        secondaryColor: const Color(0xFFECA400),
        gradientColors: const [Color(0xFFFFF8E1), Color(0xFFFFE082)],
        destination: const CustomerLiveBrewTrackerScreen(),
        isLocked: false,
      ),
    ];

    // 4. Learning Brew (4 Cards: Game Brew V60, E-Book DRM, Akademi LMS, Brew Doctor)
    final List<ToolkitItem> learningBrewTools = [
      ToolkitItem(
        featureKey: 'GAME_BREW_3D',
        title: isEn ? 'Game Brew V60' : 'Game Brew V60',
        subtitle: isEn ? '60fps V60 pour & story quest' : 'Simulasi tuang ketel V60 & cerita',
        iconType: 'game_brew',
        fallbackIcon: Icons.videogame_asset_rounded,
        primaryColor: const Color(0xFF7B3F00),
        secondaryColor: const Color(0xFFFFB74D),
        gradientColors: const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        destination: const GameBrewV60Screen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'EBOOK_DRM_LIBRARY',
        title: isEn ? 'DRM E-Book Library' : 'Pustaka E-Book DRM',
        subtitle: isEn ? '5 encrypted coffee books' : '5 buku kopi terenkripsi AES-256',
        iconType: 'ebook_drm',
        fallbackIcon: CupertinoIcons.book_circle_fill,
        primaryColor: const Color(0xFF4E342E),
        secondaryColor: const Color(0xFFD7CCC8),
        gradientColors: const [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
        destination: const EbookLibraryScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'LMS_EBOOK_ACADEMY',
        title: isEn ? 'Barista LMS Academy' : 'Akademi Barista LMS',
        subtitle: isEn ? 'HLS courses & 100-bit quizzes' : 'Kursus video HLS & kuis 100-bit',
        iconType: 'lms_academy',
        fallbackIcon: Icons.school_rounded,
        primaryColor: const Color(0xFF0369A1),
        secondaryColor: const Color(0xFF7DD3FC),
        gradientColors: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
        destination: const BaristaLmsCoursesScreen(),
        isLocked: false,
      ),
      ToolkitItem(
        featureKey: 'BREW_DOCTOR',
        title: isEn ? 'Brew Doctor & Compass' : 'Brew Doctor & Kompas',
        subtitle: isEn ? 'Fix sour, bitter & SCA plot' : 'Diagnosa asam, pahit & kompas SCA',
        iconType: 'brew_doctor',
        fallbackIcon: Icons.medical_services_rounded,
        primaryColor: const Color(0xFF2E7D32),
        secondaryColor: const Color(0xFFA5D6A7),
        gradientColors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        destination: const BrewDoctorCompassScreen(),
        isLocked: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Barista Precision Toolkit' : 'Barista Toolkit'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card (Compact Professional Suite Banner without description)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBrown,
                          AppTheme.primaryBrown.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.16),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PROFESSIONAL PRO SUITE',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                    color: AppTheme.accentGold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isEn ? 'Complete Barista Suite' : 'Peralatan Presisi Barista',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.sparkles, color: AppTheme.accentGold, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Section 1: Learning Brew (4 Cards)
                  ToolkitSectionHeader(
                    icon: const Icon(Icons.auto_stories_rounded, size: 19, color: Color(0xFF5C3A21)),
                    title: 'Learning Brew',
                    subtitle: isEn ? 'Game V60, DRM e-books, HLS LMS & Brew Doctor' : 'Game V60, E-Book DRM, Video LMS & Brew Doctor',
                    badgeBg: const Color(0xFFFFF8E1),
                    borderColor: const Color(0xFFFFE082),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD54F), width: 0.8),
                      ),
                      child: const Text(
                        '4 MODUL',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8D4E00),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          _buildSliverGrid(learningBrewTools),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            sliver: SliverToBoxAdapter(
              child: ToolkitSectionHeader(
                icon: const EcosystemSectionIcon(size: 20),
                title: isEn ? 'Ecosystem & Community' : 'Ekosistem & Komunitas',
                subtitle: isEn ? 'Marketplace, roasteries & radar' : 'Marketplace, roastery, radar & komunitas',
                badgeBg: const Color(0xFFEFEBE9),
                borderColor: const Color(0xFFD7CCC8),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
                  ),
                  child: Text(
                    isEn ? 'FREE ACCESS' : 'AKSES BEBAS',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildSliverGrid(ecosystemTools),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            sliver: SliverToBoxAdapter(
              child: ToolkitSectionHeader(
                icon: const LabSectionIcon(size: 20),
                title: isEn ? 'Extraction & AI Lab' : 'Lab Ekstraksi & AI',
                subtitle: isEn ? 'Smart AI, clicks & yield' : 'Smart AI, kalibrasi rasa & yield',
                badgeBg: const Color(0xFFFCE4EC),
                borderColor: const Color(0xFFF8BBD0),
                trailing: _isTrial
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFB74D), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lock_fill, size: 10, color: Color(0xFFE65100)),
                            SizedBox(width: 3),
                            Text(
                              'BARISTA PRO',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65100),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          ),
          _buildSliverGrid(extractionTools),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            sliver: SliverToBoxAdapter(
              child: ToolkitSectionHeader(
                icon: const ScienceSectionIcon(size: 20),
                title: isEn ? 'Coffee Science & Freshness' : 'Sains Kopi & Kesegaran',
                subtitle: isEn ? 'Water minerals & degassing' : 'Mineral air, degassing & sensorik',
                badgeBg: const Color(0xFFE0F7FA),
                borderColor: const Color(0xFFB2EBF2),
                trailing: _isTrial
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFB74D), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lock_fill, size: 10, color: Color(0xFFE65100)),
                            SizedBox(width: 3),
                            Text(
                              'BARISTA PRO',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65100),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          ),
          _buildSliverGrid(scienceTools, bottomPadding: 24),
        ],
      ),
    );
  }

  Widget _buildSliverGrid(List<ToolkitItem> items, {double bottomPadding = 0}) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: 106,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: ToolkitCard(tool: items[index]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}
