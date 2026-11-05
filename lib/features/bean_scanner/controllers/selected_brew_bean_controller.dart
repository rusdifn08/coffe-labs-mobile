import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resolved_coffee_bean.dart';

class SelectedBrewBeanController extends Notifier<ResolvedCoffeeBean?> {
  @override
  ResolvedCoffeeBean? build() => null;

  void setBean(ResolvedCoffeeBean bean) {
    state = bean;
  }

  void clear() {
    state = null;
  }
}

final selectedBrewBeanProvider =
    NotifierProvider<SelectedBrewBeanController, ResolvedCoffeeBean?>(
  SelectedBrewBeanController.new,
);
