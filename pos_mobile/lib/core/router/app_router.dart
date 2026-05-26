import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ใช้ Absolute Imports ทั้งหมด
import 'package:pos_mobile/core/router/app_routes.dart';
import 'package:pos_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:pos_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pos_mobile/features/splash/presentation/pages/splash_page.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  // 1. สร้าง Notifier สำหรับแจ้งเตือน GoRouter เมื่อสถานะล็อกอินเปลี่ยน
  final refreshNotifier = ValueNotifier<void>(null);
  
  // ป้องกัน Memory Leak โดยทำลาย Notifier ทิ้งเมื่อ Router ถูกทำลาย
  ref.onDispose(refreshNotifier.dispose);

  // 2. ดักฟัง AuthNotifier หาก State เปลี่ยน (เช่น ล็อกเอาท์) ให้สั่ง GoRouter รีเฟรชเส้นทางใหม่
  ref.listen(authNotifierProvider, (_, __) {
    refreshNotifier.notifyListeners();
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.splash.path,
    refreshListenable: refreshNotifier, // เชื่อม Notifier เข้ากับ GoRouter
    debugLogDiagnostics: true,
    
    // 3. ระบบรักษาความปลอดภัย (Auth Guard)
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final path = state.matchedLocation;
      
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      final isInitialOrLoading = authState.maybeWhen(
        initial: () => true,
        loading: () => true,
        orElse: () => false,
      );

      final isGoingToLogin = path == AppRoute.login.path;
      final isSplash = path == AppRoute.splash.path;

      // กฎ 1: กำลังโหลดหรือเช็ค Token ให้อยู่หน้า Splash ไปก่อน
      if (isInitialOrLoading && isSplash) {
        return null;
      }

      // กฎ 2: ถ้า "ยังไม่ได้ล็อกอิน" และ "ไม่ได้กำลังจะไปหน้า Login" -> ดีดไปหน้า Login
      if (!isAuthenticated && !isGoingToLogin) {
        return AppRoute.login.path;
      }

      // กฎ 3: ถ้า "ล็อกอินแล้ว" แต่จะกลับไปหน้า "Login หรือ Splash" -> ดีดไปหน้า Dashboard
      if (isAuthenticated && (isGoingToLogin || isSplash)) {
        return AppRoute.dashboard.path;
      }

      // ผ่านเงื่อนไขปกติ
      return null;
    },
    
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.dashboard.path,
        name: AppRoute.dashboard.name,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}