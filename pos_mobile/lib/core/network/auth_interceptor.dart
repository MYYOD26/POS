import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. ดึง Token จาก Secure Storage
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();

    // 2. แนบ Token ไปกับ Header อัตโนมัติ (ถ้ามี)
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // 3. บังคับ Header มาตรฐานสำหรับ Enterprise REST API
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ถ้า Backend ตอบกลับมาว่า 401 Unauthorized (เช่น Token หมดอายุ หรือ โดนแบน)
    if (err.response?.statusCode == 401) {
      // สั่ง Logout ผ่าน Riverpod 
      // (ระบบ Router Guard จาก Step 5 จะทำงานและเตะกลับหน้า Login อัตโนมัติ!)
      ref.read(authNotifierProvider.notifier).logout();
    }
    
    return handler.next(err);
  }
}