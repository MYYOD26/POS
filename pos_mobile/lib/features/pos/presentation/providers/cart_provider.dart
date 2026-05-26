import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/pos_models.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final index =
        state.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final item = state[index];

      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(Product product) {
    final index =
        state.indexWhere((item) => item.product.id == product.id);

    if (index < 0) return;

    final item = state[index];

    if (item.quantity > 1) {
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity - 1),
        ...state.sublist(index + 1),
      ];
    } else {
      state = List.from(state)..removeAt(index);
    }
  }

  double get totalAmount =>
      state.fold(0, (sum, item) => sum + item.totalPrice);

  void clearCart() {
    state = [];
  }
}