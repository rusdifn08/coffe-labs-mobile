import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_pos_models.dart';

class PosCartState {
  final List<PosCartItem> items;
  final String paymentMethod;
  final String? customerName;
  final String? notes;

  const PosCartState({
    this.items = const [],
    this.paymentMethod = 'Cash',
    this.customerName,
    this.notes,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get tax => (subtotal * 0.10).toInt(); // PPN 10% jika dibutuhkan, atau 0
  int get total => subtotal; // default no tax or inclusive

  String get formattedTotal {
    final thousands = total.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $thousands';
  }

  PosCartState copyWith({
    List<PosCartItem>? items,
    String? paymentMethod,
    String? customerName,
    String? notes,
  }) {
    return PosCartState(
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
    );
  }
}

class PosCartController extends Notifier<PosCartState> {
  @override
  PosCartState build() {
    return const PosCartState();
  }

  void addItem(BusinessMenuItem item, {Map<String, String>? modifiers}) {
    final existingIndex = state.items.indexWhere((ci) => ci.menuItem.id == item.id);
    if (existingIndex >= 0) {
      final updatedList = List<PosCartItem>.from(state.items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          PosCartItem(menuItem: item, quantity: 1, modifiers: modifiers ?? {}),
        ],
      );
    }
  }

  void decrementItem(String itemId) {
    final existingIndex = state.items.indexWhere((ci) => ci.menuItem.id == itemId);
    if (existingIndex >= 0) {
      final updatedList = List<PosCartItem>.from(state.items);
      final current = updatedList[existingIndex];
      if (current.quantity > 1) {
        updatedList[existingIndex] = current.copyWith(quantity: current.quantity - 1);
        state = state.copyWith(items: updatedList);
      } else {
        removeItem(itemId);
      }
    }
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((ci) => ci.menuItem.id != itemId).toList(),
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void clearCart() {
    state = const PosCartState();
  }
}

final posCartProvider = NotifierProvider<PosCartController, PosCartState>(
  PosCartController.new,
);
