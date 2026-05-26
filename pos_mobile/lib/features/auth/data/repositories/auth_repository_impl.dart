import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SecureStorageService _localDatasource;

  AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<(Failure?, String?)> login(String username, String password) async {
    try {
      // 1. เรียก API ผ่าน Remote Datasource
      final token = await _remoteDatasource.login(username, password);
      
      // 2. บันทึก Token ลงเครื่องผ่าน Local Datasource
      await _localDatasource.saveToken(token);
      
      // 3. คืนค่าสำเร็จ (ไม่มี Error, มี Token)
      return (null, token);
    } catch (e) {
      // แปลง Exception เป็น Failure ตามมาตรฐานของระบบ
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> logout() async {
    try {
      await _localDatasource.deleteToken();
      return (null, null);
    } catch (e) {
      return (CacheFailure('Failed to logout'), null);
    }
  }

  @override
  Future<(Failure?, String?)> checkAuthStatus() async {
    try {
      final token = await _localDatasource.getToken();
      return (null, token);
    } catch (e) {
      return (CacheFailure('Failed to read token'), null);
    }
  }
}

// Provider สำหรับ Inject Repository
@riverpod
AuthRepository authRepository(Ref ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  final local = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(remote, local);
}