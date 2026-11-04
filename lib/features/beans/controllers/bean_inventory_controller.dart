import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../repositories/bean_repository.dart';

part 'bean_inventory_controller.freezed.dart';
part 'bean_inventory_controller.g.dart';

/// State filter pencarian biji kopi menggunakan Freezed.
@freezed
abstract class BeanFilterState with _$BeanFilterState {
  const factory BeanFilterState({
    @Default('') String query,
    @Default('Semua') String selectedRoastery,
  }) = _BeanFilterState;
}

/// Filter Notifier untuk katalog biji roastery.
@riverpod
class BeanFilterController extends _$BeanFilterController {
  @override
  BeanFilterState build() => const BeanFilterState();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setRoastery(String r) => state = state.copyWith(selectedRoastery: r);
  void reset() => state = const BeanFilterState();
}

/// AsyncNotifier untuk katalog biji kopi roastery terkurasi.
@riverpod
class BeanInventoryController extends _$BeanInventoryController {
  @override
  Future<List<CuratedRoasteryBean>> build() async {
    final repo = ref.watch(beanRepositoryProvider);
    return repo.getAllBeans();
  }

  /// Menghitung rekomendasi dial-in barista otomatis untuk biji tertentu.
  RecommendedBrewRecipe calculateDialIn({
    required CuratedRoasteryBean bean,
    required BeanDripper dripper,
    required FlavorGoal goal,
    double coffeeGrams = 15.0,
  }) {
    final repo = ref.read(beanRepositoryProvider);
    return repo.getDialInRecommendation(
      bean: bean,
      dripper: dripper,
      goal: goal,
      coffeeGrams: coffeeGrams,
    );
  }
}

/// Computed selector untuk daftar biji terfilter secara instan dan reaktif.
@riverpod
List<CuratedRoasteryBean> filteredBeans(Ref ref) {
  final beansAsync = ref.watch(beanInventoryControllerProvider);
  final filter = ref.watch(beanFilterControllerProvider);

  return beansAsync.maybeWhen(
    data: (beans) {
      return beans.where((b) {
        if (filter.selectedRoastery != 'Semua' &&
            filter.selectedRoastery.isNotEmpty &&
            b.roasteryName.toLowerCase() != filter.selectedRoastery.toLowerCase()) {
          return false;
        }

        if (filter.query.trim().isNotEmpty) {
          final q = filter.query.toLowerCase().trim();
          if (!b.name.toLowerCase().contains(q) &&
              !b.roasteryName.toLowerCase().contains(q) &&
              !b.origin.toLowerCase().contains(q) &&
              !b.tastingNotes.toLowerCase().contains(q)) {
            return false;
          }
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
}
