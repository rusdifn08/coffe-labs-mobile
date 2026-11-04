import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/network/rust_api_client.dart';
import '../models/curated_roastery_bean.dart';
import '../models/bean_recommendation_models.dart';

part 'bean_repository.g.dart';

/// Kontrak Repositori Katalog Biji Kopi Roastery & Rekomendasi Seduh Cerdas.
abstract class BeanRepository {
  Future<List<CuratedRoasteryBean>> getAllBeans();
  Future<List<CuratedRoasteryBean>> searchBeans(String query);
  Future<List<CuratedRoasteryBean>> getBeansByRoastery(String roasteryId);
  RecommendedBrewRecipe getDialInRecommendation({
    required CuratedRoasteryBean bean,
    required BeanDripper dripper,
    required FlavorGoal goal,
    double coffeeGrams = 15.0,
  });
  Future<void> syncBeansFromRustBackend();
}

/// Implementasi BeanRepository dengan katalog terkurasi dan mesin dial-in barista lokal.
class BeanRepositoryImpl implements BeanRepository {
  final RustApiClient _apiClient;
  List<CuratedRoasteryBean>? _cachedBeans;

  BeanRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CuratedRoasteryBean>> getAllBeans() async {
    if (_cachedBeans != null) return _cachedBeans!;
    final beans = CuratedRoasteryBean.getAllCatalogBeans();
    _cachedBeans = beans;
    return beans;
  }

  @override
  Future<List<CuratedRoasteryBean>> searchBeans(String query) async {
    final all = await getAllBeans();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase().trim();
    return all.where((b) {
      return b.name.toLowerCase().contains(q) ||
          b.roasteryName.toLowerCase().contains(q) ||
          b.origin.toLowerCase().contains(q) ||
          b.tastingNotes.toLowerCase().contains(q) ||
          b.variety.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<CuratedRoasteryBean>> getBeansByRoastery(String roasteryId) async {
    final all = await getAllBeans();
    return all.where((b) => b.roasteryName.toLowerCase() == roasteryId.toLowerCase()).toList();
  }

  @override
  RecommendedBrewRecipe getDialInRecommendation({
    required CuratedRoasteryBean bean,
    required BeanDripper dripper,
    required FlavorGoal goal,
    double coffeeGrams = 15.0,
  }) {
    return BeanRecommenderEngine.calculate(
      beanName: bean.name,
      origin: bean.origin,
      variety: bean.variety,
      tastingNotes: bean.tastingNotesList,
      roast: bean.roastLevel,
      process: bean.process,
      goal: goal,
      dripper: dripper,
      dose: coffeeGrams,
    );
  }

  @override
  Future<void> syncBeansFromRustBackend() async {
    try {
      final response = await _apiClient.get('/api/beans');
      if (response != null) {
        // Parsing live updates if backend provides catalog delta
      }
    } catch (_) {}
  }
}

/// Provider Dependency Injection untuk [BeanRepository].
@riverpod
BeanRepository beanRepository(Ref ref) {
  final apiClient = ref.watch(rustApiClientProvider);
  return BeanRepositoryImpl(apiClient: apiClient);
}
