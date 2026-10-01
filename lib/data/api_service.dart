import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/core/api_config.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 200,
  });
}

class ApiService {
  ApiService._();

  static const String _keyToken = 'auth_token_sanctum';
  static const String _keyUser = 'auth_user_json';
  static const Duration _timeoutDuration = Duration(seconds: 8);

  // ── 1. Token & Session Management ──

  static Future<void> saveSession({required String token, required Map<String, dynamic> user}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ── 2. Health Check ──

  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.baseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  // ── 3. Authentication (Login, Register, Logout) ──

  static Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: await _getHeaders(),
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeoutDuration);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && (body['success'] == true || body['token'] != null)) {
        final token = body['token'] ?? body['data']?['token'];
        final user = body['user'] ?? body['data']?['user'] ?? {'email': email};
        if (token != null) {
          await saveSession(token: token.toString(), user: user as Map<String, dynamic>);
        }
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Login berhasil',
          data: body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Email atau password salah',
          data: body,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return const ApiResponse(
        success: false,
        message: 'Koneksi ke server Laravel timeout. Pastikan `php artisan serve` aktif.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal terhubung ke Laravel: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      };
      if (phone != null) {
        payload['phone'] = phone;
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: await _getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = body['token'] ?? body['data']?['token'];
        final user = body['user'] ?? body['data']?['user'] ?? {'name': name, 'email': email};
        if (token != null) {
          await saveSession(token: token.toString(), user: user as Map<String, dynamic>);
        }
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Registrasi berhasil',
          data: body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Pendaftaran gagal',
          data: body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mendaftar ke server: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> logout() async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.logout),
            headers: await _getHeaders(requireAuth: true),
          )
          .timeout(_timeoutDuration);

      await clearSession();

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Berhasil logout',
        statusCode: response.statusCode,
      );
    } catch (_) {
      await clearSession();
      return const ApiResponse(success: true, message: 'Berhasil logout lokal');
    }
  }

  // ── 4. Setor Sampah & Live GPS Tracking ──

  static Future<ApiResponse> kirimSetorSampah({
    required String kategori,
    required int jumlahItem,
    required double beratKg,
    required double latitude,
    required double longitude,
    required String alamatJemput,
    String? patokan,
  }) async {
    try {
      final payload = <String, dynamic>{
        'kategori': kategori,
        'jumlah_item': jumlahItem,
        'berat_kg': beratKg,
        'latitude': latitude,
        'longitude': longitude,
        'alamat_jemput': alamatJemput,
      };
      if (patokan != null) {
        payload['patokan'] = patokan;
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.setorSampah),
            headers: await _getHeaders(requireAuth: true),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final body = jsonDecode(response.body);

      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: body['message'] ?? 'Jadwal penjemputan sampah berhasil dikirim!',
        data: body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mengirim setoran sampah: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> fetchRiwayatSetor() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.riwayatSetor),
            headers: await _getHeaders(requireAuth: true),
          )
          .timeout(_timeoutDuration);

      final body = jsonDecode(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Data riwayat berhasil diambil',
        data: body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat riwayat: $e',
        statusCode: 500,
      );
    }
  }

  // ── 5. Katalog Produk ──

  static Future<ApiResponse> fetchProduk() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.listProduk),
            headers: await _getHeaders(),
          )
          .timeout(_timeoutDuration);

      final body = jsonDecode(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Daftar produk berhasil dimuat',
        data: body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat produk dari server: $e',
        statusCode: 500,
      );
    }
  }
}
