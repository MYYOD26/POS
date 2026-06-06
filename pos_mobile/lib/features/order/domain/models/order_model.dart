import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../features/pos/domain/models/pos_models.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required List<CartItem> items,
    required double totalAmount,
    required String paymentMethod,
    required DateTime createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}