import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Service จัดการพื้นที่จัดเก็บข้อมูลที่มีการเข้ารหัส (Encrypted Storage)
/// iOS/Mac: ใช้ Keychain
/// Android: ใช้ EncryptedSharedPreferences
/// Web: ใช้ IndexedDB/WebStorage พร้อมการเข้ารหัส
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // คีย์สำหรับเก็บ Token
  static const String _tokenKey = 'jwt_token';

  /// บันทึก Token ลงเครื่อง
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// ดึง Token จากเครื่อง (คืนค่า null ถ้าไม่มี)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// ลบ Token ออกจากเครื่อง (ใช้ตอน Logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}

/// Provider สำหรับ Inject SecureStorageService ไปใช้งานทั่วแอป
@riverpod
SecureStorageService secureStorage(Ref ref) {
  // ตั้งค่า aOptions สำหรับ Android เพื่อใช้ EncryptedSharedPreferences (Best Practice ของ Android)
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return SecureStorageService(secureStorage);
}