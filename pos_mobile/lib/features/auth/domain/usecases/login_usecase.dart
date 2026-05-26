import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// คลาสสำหรับเก็บพารามิเตอร์ที่ต้องส่งเข้ามาตอนล็อกอิน
class LoginParams {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});
}

/// UseCase สำหรับการล็อกอินโดยเฉพาะ (สืบทอดจาก BaseUseCase)
class LoginUseCase implements BaseUseCase<String, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<(Failure?, String?)> call(LoginParams params) {
    // โยนงานต่อให้ Repository จัดการ
    return repository.login(params.username, params.password);
  }
}