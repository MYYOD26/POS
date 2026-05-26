import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/models/pos_models.dart';

part 'pos_repository.g.dart';

class PosRepository {
  final Dio _dio;

  PosRepository(this._dio);

  /// ฟังก์ชันดึงรายการสินค้าจาก Backend
  Future<List<Product>> getProducts() async {
    try {
      /* // === โค้ดสำหรับยิง API จริง ===
      final response = await _dio.get('/products');
      final List data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
      */

      // จำลองการโหลดข้อมูลจาก Database หรือ API (ใช้เวลา 1.5 วินาที)
      await Future.delayed(const Duration(milliseconds: 1500));

      // คืนค่าข้อมูลจำลอง
      return [
        const Product(id: '1', name: 'Premium Espresso', price: 120.0, category: 'Beverage'),
        const Product(id: '2', name: 'Matcha Latte', price: 140.0, category: 'Beverage'),
        const Product(id: '3', name: 'Butter Croissant', price: 85.0, category: 'Bakery'),
        const Product(id: '4', name: 'Chocolate Cake', price: 150.0, category: 'Bakery'),
        const Product(id: '5', name: 'Earl Grey Tea', price: 95.0, category: 'Beverage'),
        const Product(id: '6', name: 'Club Sandwich', price: 110.0, category: 'Food'),
        const Product(id: '7', name: 'Iced Americano', price: 100.0, category: 'Beverage'),
        const Product(id: '8', name: 'Blueberry Muffin', price: 75.0, category: 'Bakery'),
      ];
    } on DioException catch (e) {
      throw Exception('Failed to load products: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}

// สร้าง Provider สำหรับ Inject Repository
@riverpod
PosRepository posRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return PosRepository(dio);
}