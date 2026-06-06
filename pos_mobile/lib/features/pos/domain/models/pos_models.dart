import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_models.freezed.dart';
part 'pos_models.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    required String category,
    String? imageUrl, // ใส่ ? เพราะอาจจะไม่มีรูปภาพ
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required Product product,
    @Default(1) int quantity,
  }) = _CartItem;

  const CartItem._(); // อนุญาตให้เพิ่ม Custom Methods ลงใน Freezed

  // 🔥 เพิ่มบรรทัดนี้เข้ามา เพื่อให้มันแปลงเป็น JSON ไปบันทึกในหน้า Order ได้ครับ
  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

  // Method ช่วยคำนวณราคารวมของสินค้ารายการนี้
  double get totalPrice => product.price * quantity;
}