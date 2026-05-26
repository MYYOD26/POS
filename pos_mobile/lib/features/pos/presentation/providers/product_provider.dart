import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/models/pos_models.dart';
import '../../data/repositories/pos_repository.dart';

part 'product_provider.g.dart';

// เพิ่ม keepAlive: true เพื่อเปิดระบบ Cache ระดับ Enterprise 
// เปิดหน้า POS ซ้ำ ข้อมูลจะขึ้นทันทีโดยไม่หมุนโหลดใหม่ แต่จะแอบอัปเดตเบื้องหลัง
@Riverpod(keepAlive: true)
Future<List<Product>> products(Ref ref) async {
  final repository = ref.watch(posRepositoryProvider);
  return await repository.getProducts();
}