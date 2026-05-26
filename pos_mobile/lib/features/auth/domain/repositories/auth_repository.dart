import '../../../../core/errors/failures.dart';

/// สัญญา (Contract) ที่บอกว่า Data Layer ต้องเตรียมฟังก์ชันอะไรมาให้ใช้บ้าง
abstract class AuthRepository {
  // คืนค่าเป็น Record (Failure คือ Error, String คือ Token)
  Future<(Failure?, String?)> login(String username, String password);
  Future<(Failure?, void)> logout();
  Future<(Failure?, String?)> checkAuthStatus();
}