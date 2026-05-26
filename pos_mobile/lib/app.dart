import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดึง Theme และ Router จาก Provider
    final theme = ref.watch(appThemeProvider);
    final router = ref.watch(appRouterProvider);

    // ใช้ MaterialApp.router เพื่อให้ GoRouter เป็นคนควบคุมหน้าจอทั้งหมด
    return MaterialApp.router(
      title: 'Enterprise POS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      
      // ผูก Router เข้ากับแอปที่จุดนี้
      routerConfig: router,
    );
  }
}