import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/data/user_account_data.dart';

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
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // ── 1. Token & Session Management ──

  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user));
    UserAccountData.updateFromUserData(user);
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
      final userMap = jsonDecode(raw) as Map<String, dynamic>;
      UserAccountData.updateFromUserData(userMap);
      return userMap;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    UserAccountData.resetSession();
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
          .get(Uri.parse(ApiConfig.ping))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      try {
        final fallback = await http
            .get(Uri.parse(ApiConfig.baseUrl))
            .timeout(const Duration(seconds: 3));
        return fallback.statusCode < 500;
      } catch (_) {
        return false;
      }
    }
  }

  // ── 3. Autentikasi Pengguna Mobile (TR4SH Laravel) ──

  /// Login menggunakan `username` (atau `email`) dan `password` ke endpoint `/api/auth/login`
  static Future<ApiResponse> login({
    String? username,
    String? email,
    required String password,
  }) async {
    try {
      final userIdentifier = (username != null && username.isNotEmpty)
          ? username
          : (email ?? '');

      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: await _getHeaders(),
            body: jsonEncode({
              'username': userIdentifier,
              'password': password,
            }),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      if (response.statusCode == 200 && (body['success'] == true || body['token'] != null)) {
        final token = body['token']?.toString() ?? '';
        final userData = body['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(body['data'])
            : <String, dynamic>{'username': userIdentifier};

        if (token.isNotEmpty) {
          await saveSession(token: token, user: userData);
        }

        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Login berhasil.',
          data: userData,
          statusCode: response.statusCode,
        );
      } else {
        String errorMsg = (body['message'] != null && body['message'].toString().trim().isNotEmpty)
            ? body['message'].toString()
            : 'Username atau kata sandi tidak valid.';
        if (body['errors'] is Map) {
          final errors = body['errors'] as Map;
          if (errors.isNotEmpty) {
            errorMsg = errors.values.first is List
                ? errors.values.first[0].toString()
                : errors.values.first.toString();
          }
        }

        return ApiResponse(
          success: false,
          message: errorMsg,
          data: body,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return const ApiResponse(
        success: false,
        message: 'Koneksi ke server timeout. Pastikan Laravel `php artisan serve` aktif.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server Laravel: $e',
        statusCode: 500,
      );
    }
  }

  /// Register akun baru ke endpoint `/api/auth/register`
  static Future<ApiResponse> register({
    required String username,
    required String password,
    required String namaLengkap,
    String? phone,
  }) async {
    try {
      final payload = <String, dynamic>{
        'username': username,
        'password': password,
        'nama_lengkap': namaLengkap,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: await _getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = body['token']?.toString() ?? '';
        final userData = body['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(body['data'])
            : <String, dynamic>{'username': username, 'nama_lengkap': namaLengkap};

        if (token.isNotEmpty) {
          await saveSession(token: token, user: userData);
        }

        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Pendaftaran akun berhasil.',
          data: userData,
          statusCode: response.statusCode,
        );
      } else {
        String errorMsg = (body['message'] != null && body['message'].toString().trim().isNotEmpty)
            ? body['message'].toString()
            : 'Pendaftaran akun gagal.';
        if (body['errors'] is Map) {
          final errors = body['errors'] as Map;
          if (errors.isNotEmpty) {
            errorMsg = errors.values.first is List
                ? errors.values.first[0].toString()
                : errors.values.first.toString();
          }
        }

        return ApiResponse(
          success: false,
          message: errorMsg,
          data: body,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return const ApiResponse(
        success: false,
        message: 'Koneksi timeout saat mendaftar. Periksa koneksi backend Anda.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mendaftar ke server: $e',
        statusCode: 500,
      );
    }
  }

  /// Logout akun
  static Future<ApiResponse> logout() async {
    try {
      await http
          .post(
            Uri.parse(ApiConfig.logout),
            headers: await _getHeaders(requireAuth: true),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {}

    await clearSession();
    return const ApiResponse(
      success: true,
      message: 'Berhasil keluar akun.',
      statusCode: 200,
    );
  }

  // ── 4. Setor Sampah & Riwayat (TR4SH Laravel) ──

  /// Kirim data setor sampah baru ke `/api/sampah/setor`
  static Future<ApiResponse> kirimSetorSampah({
    int? idUser,
    int? idKategori,
    String? jenisSampah,
    double? jumlah,
    String satuan = 'kg',
    String? keterangan,
    // Parameter kompatibilitas / legacy:
    String? kategori,
    int? jumlahItem,
    double? beratKg,
    double? latitude,
    double? longitude,
    String? alamatJemput,
    String? patokan,
  }) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId ?? 1;
      final effectiveKategoriId = idKategori ?? 1;
      final effectiveJenis = (jenisSampah != null && jenisSampah.isNotEmpty)
          ? jenisSampah
          : (kategori ?? 'Sampah Anorganik');
      final effectiveJumlah = jumlah ?? beratKg ?? (jumlahItem != null ? jumlahItem.toDouble() : 1.0);

      String effectiveKet = keterangan ?? '';
      if (effectiveKet.isEmpty && alamatJemput != null) {
        effectiveKet = alamatJemput;
        if (patokan != null && patokan.isNotEmpty) {
          effectiveKet += ' (Patokan: $patokan)';
        }
      }

      final payload = <String, dynamic>{
        'id_user': effectiveUserId,
        'id_kategori': effectiveKategoriId,
        'jenis_sampah': effectiveJenis,
        'jumlah': effectiveJumlah,
        'satuan': satuan,
        if (effectiveKet.isNotEmpty) 'keterangan': effectiveKet,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.setorSampah),
            headers: await _getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: body['message'] ?? 'Setoran sampah berhasil dikirim!',
        data: body['data'] ?? body,
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

  /// Ambil riwayat setoran sampah dari `/api/sampah/riwayat`
  static Future<ApiResponse> fetchRiwayatSetor({int? idUser}) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId;
      String url = ApiConfig.riwayatSetor;
      if (effectiveUserId != null) {
        url += '?id_user=$effectiveUserId';
      }

      final response = await http
          .get(Uri.parse(url), headers: await _getHeaders())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Riwayat sampah berhasil dimuat.',
        data: body['data'] ?? [],
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

  /// Ambil daftar kategori sampah dari `/api/sampah/kategori`
  static Future<ApiResponse> fetchKategoriSampah() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.kategoriSampah), headers: await _getHeaders())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Kategori sampah berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat kategori sampah: $e',
        statusCode: 500,
      );
    }
  }

  // ── 5. Katalog Produk Prakarya Daur Ulang ──

  /// Ambil daftar produk prakarya dari `/api/prakarya`
  static Future<ApiResponse> fetchProduk({String? search}) async {
    try {
      String url = ApiConfig.listPrakarya;
      if (search != null && search.trim().isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search.trim())}';
      }

      final response = await http
          .get(Uri.parse(url), headers: await _getHeaders())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Daftar produk prakarya berhasil dimuat.',
        data: body['data'] ?? [],
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

  // ── 6. Konten Edukasi Publik ──

  /// Ambil konten edukasi publik dari `/api/edukasi`
  static Future<ApiResponse> fetchEdukasi({String? kategori, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (kategori != null && kategori.isNotEmpty) queryParams['kategori'] = kategori;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiConfig.listEdukasi).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http.get(uri, headers: await _getHeaders()).timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Konten edukasi berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat edukasi dari server: $e',
        statusCode: 500,
      );
    }
  }

  /// Unggah konten video YouTube baru ke `/api/edukasi/upload`
  static Future<ApiResponse> uploadKonten({
    int? idUser,
    required String title,
    required String mediaUrl,
    required String description,
    String jenisEdukasi = 'Edukasi Lingkungan',
    String tipeMedia = 'Video YouTube',
  }) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId ?? 1;

      final payload = <String, dynamic>{
        'id_user': effectiveUserId,
        'title': title,
        'media_url': mediaUrl,
        'description': description,
        'jenis_edukasi': jenisEdukasi,
        'tipe_media': tipeMedia,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.uploadEdukasi),
            headers: await _getHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Konten berhasil dikirim! Menunggu konfirmasi admin.',
          data: body['data'] ?? body,
          statusCode: response.statusCode,
        );
      } else {
        String errorMsg = (body['message'] != null && body['message'].toString().trim().isNotEmpty)
            ? body['message'].toString()
            : 'Gagal mengunggah konten.';
        if (body['errors'] is Map) {
          final errors = body['errors'] as Map;
          if (errors.isNotEmpty) {
            errorMsg = errors.values.first is List
                ? errors.values.first[0].toString()
                : errors.values.first.toString();
          }
        }
        return ApiResponse(
          success: false,
          message: errorMsg,
          data: body,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return const ApiResponse(
        success: false,
        message: 'Koneksi timeout. Pastikan server Laravel `php artisan serve` aktif.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mengunggah konten: $e',
        statusCode: 500,
      );
    }
  }

  /// Ambil riwayat konten yang diunggah oleh user dari `/api/edukasi/user/{id_user}`
  static Future<ApiResponse> fetchKontenSaya({int? idUser}) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId ?? 1;
      final url = ApiConfig.userKonten(effectiveUserId);

      final response = await http
          .get(Uri.parse(url), headers: await _getHeaders())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Daftar konten berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat riwayat konten: $e',
        statusCode: 500,
      );
    }
  }

  // ── 7. Beranda Agregat Single Fetch ──

  /// Ambil seluruh data beranda dari `/api/beranda?id_user={id}`
  static Future<ApiResponse> fetchBeranda({int? userId}) async {
    try {
      final effectiveUserId = userId ?? UserAccountData.currentUserId;
      final url = ApiConfig.beranda(userId: effectiveUserId);

      final response = await http
          .get(Uri.parse(url), headers: await _getHeaders())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Data beranda berhasil dimuat.',
        data: body['data'] ?? {},
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat data beranda: $e',
        statusCode: 500,
      );
    }
  }

  // Helper untuk parsing JSON secara aman
  static Map<String, dynamic> _parseJson(String source) {
    if (source.trim().isEmpty) {
      return {'message': 'Gagal memproses respons dari server.'};
    }
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {'data': decoded};
    } catch (_) {
      return {'message': source};
    }
  }
}
