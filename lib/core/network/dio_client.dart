import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'dio_client.g.dart';

/// Representasi exception jaringan terstruktur untuk memetakan status HTTP dan kegagalan koneksi.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  const ApiException({
    required this.message,
    this.statusCode,
    this.endpoint,
  });

  @override
  String toString() => message;
}

/// Interceptor Otentikasi & Resolusi Base URL Dinamis:
/// 1. Menyuntikkan header `Authorization: Bearer <jwt>` secara otomatis.
/// 2. Mendukung override Base URL dari pengaturan lokal (SharedPreferences).
/// 3. Menangani error 401 Unauthorized dengan percobaan refresh JWT otomatis (`/api/auth/refresh`).
class AuthAndRefreshInterceptor extends QueuedInterceptor {
  static const String _serverUrlKey = 'coffeehub_backend_server_url';
  static const String _authTokenKey = 'coffeehub_auth_token_v1';
  static const String _legacyJwtKey = 'coffeehub_auth_jwt_token';
  static const String _refreshTokenKey = 'coffeehub_refresh_token_v1';
  static const String defaultBaseUrl = 'https://coffe-labs-backend.onrender.com';

  final Dio _dio;

  AuthAndRefreshInterceptor(this._dio);

  Future<String> _resolveBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_serverUrlKey)?.trim();
      if (savedUrl != null &&
          savedUrl.isNotEmpty &&
          !savedUrl.contains('localhost') &&
          !savedUrl.contains('10.0.2.2')) {
        return savedUrl.endsWith('/') ? savedUrl.substring(0, savedUrl.length - 1) : savedUrl;
      }
    } catch (_) {}
    return defaultBaseUrl;
  }

  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey) ?? prefs.getString(_legacyJwtKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final baseUrl = await _resolveBaseUrl();
    options.baseUrl = baseUrl;

    final token = await _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Jika 401 Unauthorized dan bukan endpoint login/refresh, coba refresh token otomatis
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/refresh');

    if (statusCode == 429 && err.requestOptions.extra['retried_429'] != true) {
      final retryOptions = err.requestOptions;
      retryOptions.extra['retried_429'] = true;
      try {
        retryOptions.baseUrl = 'http://localhost:3000';
        final localResponse = await _dio.fetch(retryOptions);
        return handler.resolve(localResponse);
      } catch (_) {
        try {
          await Future.delayed(const Duration(seconds: 3));
          retryOptions.baseUrl = await _resolveBaseUrl();
          final retryResponse = await _dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {}
      }
    }

    if (statusCode == 401 && !isAuthEndpoint) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString(_refreshTokenKey);

        if (refreshToken != null && refreshToken.isNotEmpty) {
          final baseUrl = await _resolveBaseUrl();
          final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
          final refreshResponse = await refreshDio.post(
            '/api/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data is Map) {
            final newToken = refreshResponse.data['token']?.toString();
            if (newToken != null && newToken.isNotEmpty) {
              await prefs.setString(_authTokenKey, newToken);
              await prefs.setString(_legacyJwtKey, newToken);

              // Ulangi request awal dengan token baru
              final retryOptions = err.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newToken';
              final clonedResponse = await _dio.fetch(retryOptions);
              return handler.resolve(clonedResponse);
            }
          }
        }
      } catch (_) {
        // Jika refresh gagal, lanjutkan ke global error mapper
      }
    }

    handler.next(err);
  }
}

/// Interceptor Pemetaan Error Global (401, 403, 404, 500, Timeout) & Logging Diagnostik.
class GlobalErrorAndLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🌐 [DIO REQ] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ [DIO RES] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ [DIO ERR] ${err.response?.statusCode ?? err.type} ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }

  /// Utilitas pemetaan DioException ke [ApiException] yang bersih untuk lapisan Repository/UI.
  static ApiException mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final endpoint = e.requestOptions.path;
    final data = e.response?.data;

    String? serverMessage;
    if (data is Map) {
      serverMessage = data['message']?.toString() ?? data['error']?.toString();
    } else if (data is String && data.trim().isNotEmpty) {
      serverMessage = data.trim();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: serverMessage ??
              'Koneksi timeout (server Cloud Render sedang bangun dari mode siaga). Silakan coba sesaat lagi.',
          statusCode: statusCode ?? 408,
          endpoint: endpoint,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Tidak ada koneksi internet ke Rust backend.',
          statusCode: 503,
          endpoint: endpoint,
        );
      default:
        break;
    }

    if (statusCode == 401) {
      return ApiException(
        message: serverMessage ?? 'Sesi otentikasi tidak valid atau berakhir (401).',
        statusCode: 401,
        endpoint: endpoint,
      );
    } else if (statusCode == 403) {
      return ApiException(
        message: serverMessage ?? 'Akses ditolak oleh kebijakan keamanan server (403).',
        statusCode: 403,
        endpoint: endpoint,
      );
    } else if (statusCode != null && statusCode >= 500) {
      return ApiException(
        message: serverMessage ?? 'Terjadi gangguan internal pada server Rust ($statusCode).',
        statusCode: statusCode,
        endpoint: endpoint,
      );
    }

    return ApiException(
      message: serverMessage ?? e.message ?? 'Gagal menghubungi server backend.',
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }
}

/// Provider Dependency Injection Singleton-like untuk [Dio] dengan konfigurasi penuh Interceptor.
@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AuthAndRefreshInterceptor.defaultBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    AuthAndRefreshInterceptor(dio),
    GlobalErrorAndLoggingInterceptor(),
  ]);

  return dio;
}
