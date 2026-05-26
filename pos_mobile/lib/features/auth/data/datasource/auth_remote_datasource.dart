import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';

part 'auth_remote_datasource.g.dart';

abstract class AuthRemoteDatasource {
  Future<String> login(String username, String password);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasourceImpl(this._dio);

  @override
  Future<String> login(String username, String password) async {
    try {
      // จำลองการยิง API 2 วินาที (ใช้ของจริงให้เปิดคอมเมนต์ Dio)
      await Future.delayed(const Duration(seconds: 2));

      if (username == 'admin' && password == 'password') {
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI...'; // Mock Token
      } else {
        throw Exception('Invalid username or password');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}

// Provider สำหรับ Inject Datasource
@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDatasourceImpl(dio);
}