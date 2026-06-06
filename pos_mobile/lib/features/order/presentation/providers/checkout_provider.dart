import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkout_provider.g.dart';

enum PaymentMethod { cash, creditCard, promptPay }

@riverpod
class PaymentMethodNotifier extends _$PaymentMethodNotifier {
  @override
  PaymentMethod build() {
    return PaymentMethod.cash;
  }

  void selectMethod(PaymentMethod method) {
    state = method;
  }
}