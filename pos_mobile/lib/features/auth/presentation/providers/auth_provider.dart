// 1. เพิ่ม Import flutter_riverpod เพื่อให้ระบบรู้จักคลาส Ref
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
// 2. เพิ่ม Import ไปยังไฟล์ Impl ที่เราสร้าง Provider ของ Repository เอาไว้ใน Step 12
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  // FIX: เปลี่ยนจาก authNotifierProvider เป็น authRepositoryProvider
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkInitialAuth();
    return const AuthState.initial();
  }

  Future<void> _checkInitialAuth() async {
    state = const AuthState.loading();
    
    // FIX: เปลี่ยนจาก authNotifierProvider เป็น authRepositoryProvider
    final repository = ref.read(authRepositoryProvider);
    
    final (failure, token) = await repository.checkAuthStatus();

    if (failure == null && token != null) {
      state = AuthState.authenticated(token: token);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    state = const AuthState.loading();
    
    final usecase = ref.read(loginUseCaseProvider);
    
    final (failure, token) = await usecase(
      LoginParams(username: username, password: password),
    );

    if (failure != null) {
      state = AuthState.error(failure.message);
      
      await Future.delayed(const Duration(seconds: 3));
      state.maybeWhen(
        error: (_) => state = const AuthState.unauthenticated(),
        orElse: () {},
      );
    } else if (token != null) {
      state = AuthState.authenticated(token: token);
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    
    // FIX: เปลี่ยนจาก authNotifierProvider เป็น authRepositoryProvider
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    
    state = const AuthState.unauthenticated();
  }
}