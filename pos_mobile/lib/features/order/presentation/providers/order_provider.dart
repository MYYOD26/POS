import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/order_model.dart';

part 'order_provider.g.dart';

@Riverpod(keepAlive: true)
class OrderHistory extends _$OrderHistory {
  @override
  List<OrderModel> build() {
    return []; // เริ่มต้นประวัติการขายเป็นคลาสว่าง
  }

  /// ฟังก์ชันเพิ่มบิลใหม่เข้าไปในระบบ (วางไว้บนสุด)
  void addOrder(OrderModel order) {
    state = [order, ...state];
  }
}