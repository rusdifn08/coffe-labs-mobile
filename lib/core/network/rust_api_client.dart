import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_client.dart';

part 'rust_api_client.g.dart';

/// Client jaringan terpusat untuk komunikasi dengan Rust (Axum) API backend Coffee Labs
/// berbasis Dio dengan Interceptor otentikasi, refresh JWT otomatis, dan pemetaan error global.
class RustApiClient {
  static const String defaultBaseUrl = AuthAndRefreshInterceptor.defaultBaseUrl;
  static const String _serverUrlKey = 'coffeehub_backend_server_url';
  static const String _authTokenKey = 'coffeehub_auth_token_v1';

  final Dio _dio;

  RustApiClient({required Dio dio}) : _dio = dio;

  /// Mendapatkan Base URL backend aktif dari konfigurasi lokal pengguna atau default production.
  Future<String> getBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_serverUrlKey)?.trim();
      if (savedUrl != null && savedUrl.isNotEmpty) {
        return savedUrl.endsWith('/') ? savedUrl.substring(0, savedUrl.length - 1) : savedUrl;
      }
    } catch (_) {}
    return defaultBaseUrl;
  }

  /// Mengambil token otentikasi Bearer JWT.
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Eksekusi HTTP GET via Dio dengan penanganan interceptor dan pemetaan error.
  Future<dynamic> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _normalizeResponseData(response.data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  /// Eksekusi HTTP POST dengan payload JSON via Dio.
  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _dio.post<dynamic>(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _normalizeResponseData(response.data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  /// Eksekusi HTTP PUT dengan payload JSON via Dio.
  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _dio.put<dynamic>(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _normalizeResponseData(response.data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  /// Eksekusi HTTP DELETE via Dio.
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete<dynamic>(
        endpoint,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _normalizeResponseData(response.data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  dynamic _normalizeResponseData(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      if (data.isEmpty) return null;
      try {
        return json.decode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }
}

/// Provider Dependency Injection untuk [RustApiClient] yang menyuntikkan singleton [dioClientProvider].
@Riverpod(keepAlive: true)
RustApiClient rustApiClient(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return RustApiClient(dio: dio);
}
