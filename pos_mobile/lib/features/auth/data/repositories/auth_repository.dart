import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/dio_provider.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storageService;
  
  AuthRepository(this._dio, this._storageService);

  Future<String> login(String username, String password) async {
    try {
      /* // === โค้ดสำหรับยิง API ของจริงเมื่อ Backend พร้อม ===
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      final token = response.data['token']; // สมมติว่า Backend คืนค่ากลับมาใน Key ชื่อ token
      await _storageService.saveToken(token);
      return token;
      */

      // จำลองสถานการณ์: ยิง API
      await Future.delayed(const Duration(seconds: 2));

      if (username == 'admin' && password == 'password') {
        const mockJwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI...'; 
        await _storageService.saveToken(mockJwtToken);
        return mockJwtToken;
      } else {
        throw Exception('Invalid username or password');
      }
    } on DioException catch (e) {
      // ดักจับ Error จาก Dio เช่น เน็ตหลุด หรือ Backend พัง
      throw Exception(e.response?.data['message'] ?? 'Network Error');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  Future<String?> checkAuthStatus() async {
    return await _storageService.getToken();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  // Inject Dio และ Storage ให้ Repository อัตโนมัติ
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
}