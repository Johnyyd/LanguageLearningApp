import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
    late final Dio dio;
    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    ApiClient() {
        dio = Dio(
            BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 120),
                headers: {'Content-Type': 'application/json'},
            ),
        );

        // Add Interceptors for Token & Error Logging
        dio.interceptors.add(
            InterceptorsWrapper(
                onRequest: (options, handler) async {
                    final token = await _secureStorage.read(key: AppConstants.tokenKey);
                    if (token != null) {
                        options.headers['Authorization'] = 'Bearer $token';
                    }
                    debugPrint("🌐 [API Request] ${options.method} ${options.uri}");
                    return handler.next(options);
                },
                onResponse: (response, handler) {
                    debugPrint("✅ [API Response] ${response.statusCode} - ${response.requestOptions.path}");
                    return handler.next(response);
                },
                onError: (DioException e, handler) {
                    debugPrint("❌ [API Error] ${e.type} - ${e.message}");
                    return handler.next(e);
                },
            ),
        );
    }
}
