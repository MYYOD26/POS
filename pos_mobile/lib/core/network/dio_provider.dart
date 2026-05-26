import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';
import 'auth_interceptor.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    ),
  );

  // นำ AuthInterceptor มาต่อเข้ากับ Dio
  dio.interceptors.add(AuthInterceptor(ref));

  // หากรันในโหมด Debug (ตอนพัฒนา) ให้ปริ้นท์ Log ข้อมูล API เข้า Terminal ให้ดูง่ายๆ
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));
  }

  return dio;
}