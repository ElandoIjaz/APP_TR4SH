import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/data/user_account_data.dart';

export 'models/api_response.dart';
import 'models/api_response.dart';

class ApiService {
  ApiService._();

  static const String _keyToken = 'auth_token_sanctum';
  static const String _keyUser = 'auth_user_json';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  static Future<void> saveSession({
    required String token,
    required Map user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user));
    UserAccountData.updateFromUserData(Map<String, dynamic>.from(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      final userMap = jsonDecode(raw) as Map;
      UserAccountData.updateFromUserData(Map<String, dynamic>.from(userMap));
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

  static Future<Map<String, dynamic>> _getHeaders({
    bool requireAuth = true,
  }) async {
    final headers = <String, String>{
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

  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.ping))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return true;
    } catch (_) {}

    // Coba auto-deteksi host alternatif (misal emulator 10.0.2.2 atau IP WiFi baru)
    final recovered = await ApiConfig.autoDetectWorkingHost();
    if (recovered) {
      try {
        final retry = await http
            .get(Uri.parse(ApiConfig.ping))
            .timeout(const Duration(seconds: 15));
        return retry.statusCode == 200;
      } catch (_) {}
    }

    try {
      final fallback = await http
          .get(Uri.parse(ApiConfig.baseUrl))
          .timeout(const Duration(seconds: 15));
      return fallback.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  static Future<ApiResponse> login({
    String? username,
    String? email,
    required String password,
  }) async {
    final userIdentifier = (username != null && username.isNotEmpty)
        ? username
        : (email ?? '');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: (await _getHeaders()).cast<String, String>(),
            body: jsonEncode({'username': userIdentifier, 'password': password}),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      if (response.statusCode == 200 &&
          (body['success'] == true || body['token'] != null)) {
        final token = body['token']?.toString() ?? '';
        final userData = body['data'] is Map
            ? Map.from(body['data'])
            : {'username': userIdentifier};

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
        return ApiResponse(
          success: false,
          message: body['message']?.toString() ?? 'Username atau kata sandi tidak valid.',
          data: body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal terhubung ke server: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> register({
    required String username,
    required String password,
    required String namaLengkap,
    String? phone,
  }) async {
    final payload = <String, dynamic>{
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
      if (phone != null && phone.trim().isNotEmpty) 'telepon': phone.trim(),
    };

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: (await _getHeaders()).cast<String, String>(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = body['token']?.toString() ?? '';
        final userData = body['data'] is Map
            ? Map.from(body['data'])
            : {'username': username, 'nama_lengkap': namaLengkap};

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
        return ApiResponse(
          success: false,
          message: body['message']?.toString() ?? 'Pendaftaran gagal.',
          data: body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mendaftar: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> logout() async {
    try {
      final headers = await _getHeaders(requireAuth: true);
      await http
          .post(
            Uri.parse(ApiConfig.logout),
            headers: headers.cast<String, String>(),
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

  static Future<ApiResponse> kirimSetorSampah({
    int? idUser,
    int? idKategori,
    String? jenisSampah,
    double? jumlah,
    String satuan = 'kg',
    String? keterangan,
  }) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId ?? 1;
      final effectiveKategoriId = idKategori ?? 1;
      final effectiveJenis = jenisSampah ?? 'Sampah Anorganik';
      final effectiveJumlah = jumlah ?? 1.0;

      final payload = <String, dynamic>{
        'id_user': effectiveUserId,
        'id_kategori': effectiveKategoriId,
        'jenis_sampah': effectiveJenis,
        'jumlah': effectiveJumlah,
        'satuan': satuan,
        if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.setorSampah),
            headers: (await _getHeaders()).cast<String, String>(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: body['message'] ?? 'Setoran berhasil dikirim!',
        data: body['data'] ?? body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mengirim setoran: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> kirimSetorSampahMultipart({
    required int idUser,
    List<dynamic>? items,
    int? idKategori,
    String? jenisSampah,
    double? jumlah,
    String satuan = 'kg',
    String? sumber,
    String? keterangan,
    dynamic fotoFile,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.setorSampah);
      var request = http.MultipartRequest('POST', uri);

      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['id_user'] = idUser.toString();
      if (sumber != null && sumber.isNotEmpty) request.fields['sumber'] = sumber;
      if (keterangan != null && keterangan.isNotEmpty) request.fields['keterangan'] = keterangan;

      if (items != null && items.isNotEmpty) {
        request.fields['items'] = jsonEncode(items);
      } else {
        request.fields['id_kategori'] = (idKategori ?? 1).toString();
        request.fields['jenis_sampah'] = jenisSampah ?? 'Sampah';
        request.fields['jumlah'] = (jumlah ?? 1.0).toString();
        request.fields['satuan'] = satuan;
      }

      if (fotoFile != null) {
        final bytes = await fotoFile.readAsBytes();
        final originalName = fotoFile.name ?? '';
        final filename = originalName.isNotEmpty && originalName.contains('.')
            ? originalName
            : 'sampah_${DateTime.now().millisecondsSinceEpoch}.jpg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            bytes,
            filename: filename,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(_timeoutDuration);
      var response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> body = _parseJson(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Permintaan jual berhasil dikirim!',
          data: body['data'] ?? body,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Gagal mengirim permintaan jual.',
          data: body,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Koneksi error saat upload foto: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> fetchRiwayatSetor({int? idUser}) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId;
      String url = ApiConfig.riwayatSetor;
      if (effectiveUserId != null) {
        url += '?id_user=$effectiveUserId';
      }

      final response = await http
          .get(Uri.parse(url), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);
      final listRaw = body['data'] is List ? (body['data'] as List) : [];
      final double totalKg = (body['total_kg'] != null)
          ? (double.tryParse(body['total_kg'].toString()) ?? 0.0)
          : 0.0;
      final int totalCount = (body['total'] != null)
          ? (int.tryParse(body['total'].toString()) ?? listRaw.length)
          : listRaw.length;

      UserAccountData.totalSampahKg = totalKg;
      UserAccountData.totalSetoran = totalCount;

      if (listRaw.isNotEmpty) {
        UserAccountData.listRiwayatSetor = listRaw.map((item) {
          final idSampah = item['id_sampah']?.toString() ?? '0';
          final kategori = item['nama_kategori']?.toString() ?? 'Sampah';
          final berat = double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0;
          final tanggalRaw = item['created_at']?.toString() ?? '';

          return RiwayatSetorModel(
            id: 'SET-$idSampah',
            tanggal: tanggalRaw.isNotEmpty ? tanggalRaw : 'Hari Ini',
            kategori: kategori,
            beratKg: berat,
            poin: (berat * 15).round(),
            lokasiBankSampah: item['keterangan']?.toString() ?? 'TR4SH Drop Point',
            status: item['status_verifikasi'] == 'accepted' 
                ? 'Disetujui' 
                : (item['status_verifikasi'] == 'denied' ? 'Ditolak' : 'Pending'),
            estimasiCo2: '${(berat * 1.5).toStringAsFixed(1)} kg CO2e',
          );
        }).toList();
      }

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Riwayat berhasil dimuat.',
        data: {'items': listRaw, 'total_kg': totalKg, 'total': totalCount},
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

  static Future<ApiResponse> fetchKategoriSampah() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.kategoriSampah), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Kategori berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat kategori: $e',
        statusCode: 500,
      );
    }
  }

  // ── Katalog Produk Prakarya Daur Ulang ──

  /// Ambil daftar produk prakarya dari `/api/prakarya`
  static Future<ApiResponse> fetchProduk({String? search}) async {
    try {
      String url = ApiConfig.listPrakarya;
      if (search != null && search.trim().isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search.trim())}';
      }

      final response = await http
          .get(Uri.parse(url), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Produk berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat produk: $e',
        statusCode: 500,
      );
    }
  }

  /// Ambil daftar bank sampah (beserta koordinat) dari `/api/bank-sampah`
  static Future<ApiResponse> fetchBankSampah() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.bankSampah), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Daftar bank sampah berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat bank sampah dari server: $e',
        statusCode: 500,
      );
    }
  }

  // ── Broadcast Promo (notifikasi in-app) ──

  /// Ambil broadcast promo yang aktif dari `/api/broadcast`
  static Future<ApiResponse> fetchBroadcast() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.broadcast), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Daftar broadcast berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat broadcast dari server: $e',
        statusCode: 500,
      );
    }
  }

  // ── Konten Edukasi Publik ──

  /// Ambil konten edukasi publik dari `/api/edukasi`
  static Future<ApiResponse> fetchEdukasi({
    String? kategori,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (kategori != null && kategori.isNotEmpty) queryParams['kategori'] = kategori;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiConfig.listEdukasi)
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http
          .get(uri, headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Edukasi berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat edukasi: $e',
        statusCode: 500,
      );
    }
  }

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
            headers: (await _getHeaders()).cast<String, String>(),
            body: jsonEncode(payload),
          )
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: body['message'] ?? 'Konten berhasil dikirim!',
        data: body['data'] ?? body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal mengunggah konten: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> fetchKontenSaya({int? idUser}) async {
    try {
      final effectiveUserId = idUser ?? UserAccountData.currentUserId ?? 1;
      final url = ApiConfig.userKonten(effectiveUserId);

      final response = await http
          .get(Uri.parse(url), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Konten saya berhasil dimuat.',
        data: body['data'] ?? [],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat konten saya: $e',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> checkUserStatus(dynamic userId) async {
    try {
      if (userId == null) {
        return const ApiResponse(success: false, message: 'ID tidak valid', statusCode: 400);
      }
      final url = '${ApiConfig.baseUrl}/auth/check-status/$userId';
      final response = await http
          .get(Uri.parse(url), headers: (await _getHeaders()).cast<String, String>())
          .timeout(const Duration(seconds: 4));

      final Map<String, dynamic> body = _parseJson(response.body);
      final bool isBlocked = (response.statusCode == 403 || body['is_blocked'] == true);

      if (isBlocked) await clearSession();

      return ApiResponse(
        success: !isBlocked && response.statusCode == 200,
        message: body['message'] ?? 'Status aktif.',
        data: body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Gagal cek status: $e', statusCode: 500);
    }
  }

  static Future<ApiResponse> fetchBeranda({int? userId}) async {
    try {
      final effectiveUserId = userId ?? UserAccountData.currentUserId;
      final url = ApiConfig.beranda(userId: effectiveUserId);

      final response = await http
          .get(Uri.parse(url), headers: (await _getHeaders()).cast<String, String>())
          .timeout(_timeoutDuration);

      final Map<String, dynamic> body = _parseJson(response.body);

      return ApiResponse(
        success: response.statusCode == 200,
        message: 'Beranda berhasil dimuat.',
        data: body['data'] ?? {},
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal memuat beranda: $e',
        statusCode: 500,
      );
    }
  }

  static Map<String, dynamic> _parseJson(String source) {
    if (source.trim().isEmpty) {
      return {'message': 'Gagal memproses respons server.'};
    }
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return {'data': decoded};
    } catch (_) {
      return {'message': source};
    }
  }
}