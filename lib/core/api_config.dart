import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Konfigurasi alamat server API.
///
/// PRIORITAS alamat server (dari atas ke bawah):
///   1. --dart-define=API_BASE_URL=...   (dev via USB & production)
///   2. customBaseUrl                    (override manual)
///   3. Deteksi otomatis per platform    ([DEV-ONLY], tidak aktif di mode release)
///
/// Contoh dev (USB):
///   adb reverse tcp:8000 tcp:8000
///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
///
/// Contoh production:
///   flutter build apk --release --dart-define=API_BASE_URL=https://domainmu.com/api
///
/// Cari tanda "[DEV-ONLY]" (Ctrl + F) untuk menemukan semua bagian yang
/// boleh dihapus setelah backend di-deploy.
class ApiConfig {
  ApiConfig._();

  /// Alamat dari --dart-define. Kosong jika tidak diberikan.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// True jika alamat sudah ditentukan dari luar (tidak perlu deteksi otomatis).
  static bool get _pakaiUrlTetap => _envBaseUrl.isNotEmpty;

  // ───────────────────────── [DEV-ONLY] mulai ─────────────────────────

  static const String _keyServerIp = 'app_server_ip';
  static const String _keyServerPort = 'app_server_port';
  static const String _keyUseEmulator = 'app_use_emulator';

  /// IP laptop saat testing di HP fisik via WiFi yang sama.
  /// Cek dengan `ipconfig` (IPv4 Address pada adapter Wi-Fi). Bisa berubah sewaktu-waktu.
  static String laptopWifiIp = '192.168.1.4';

  /// Port standar Laravel `php artisan serve`
  static int port = 8000;

  /// Mode Android Emulator (10.0.2.2).
  static bool useAndroidEmulator = false;

  /// Override manual alamat server (opsional).
  static String? customBaseUrl;

  /// Inisialisasi konfigurasi dari penyimpanan lokal (SharedPreferences).
  static Future<void> initConfig() async {
    // Alamat sudah pasti, atau aplikasi rilis: tidak perlu membaca IP tersimpan.
    if (_pakaiUrlTetap || kReleaseMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString(_keyServerIp);
      if (savedIp != null && savedIp.trim().isNotEmpty) {
        laptopWifiIp = savedIp.trim();
      }
      final savedPort = prefs.getInt(_keyServerPort);
      if (savedPort != null && savedPort > 0) {
        port = savedPort;
      }
      final savedEmulator = prefs.getBool(_keyUseEmulator);
      if (savedEmulator != null) {
        useAndroidEmulator = savedEmulator;
      } else {
        await autoDetectWorkingHost();
      }
    } catch (_) {}
  }

  /// Cek cepat apakah host tertentu aktif.
  static Future<bool> pingHost(
    String ipOrHost, {
    int? checkPort,
    int timeoutMs = 800,
  }) async {
    try {
      final p = checkPort ?? port;
      final client = HttpClient()
        ..connectionTimeout = Duration(milliseconds: timeoutMs);
      final req = await client.getUrl(
        Uri.parse('http://$ipOrHost:$p/api/ping'),
      );
      final res = await req.close().timeout(Duration(milliseconds: timeoutMs));
      final isOk = res.statusCode == 200;
      client.close();
      return isOk;
    } catch (_) {
      return false;
    }
  }

  /// Deteksi otomatis antara Android Emulator (10.0.2.2) dan HP fisik via WiFi.
  /// Tidak melakukan apa-apa jika alamat sudah ditentukan lewat --dart-define
  /// atau aplikasi berjalan di mode release.
  static Future<bool> autoDetectWorkingHost() async {
    if (kIsWeb || _pakaiUrlTetap || kReleaseMode) return false;

    try {
      if (Platform.isAndroid) {
        // 1. Android emulator
        final emuOk = await pingHost('10.0.2.2', timeoutMs: 600);
        if (emuOk) {
          useAndroidEmulator = true;
          return true;
        }

        // 2. IP WiFi laptop
        final wifiOk = await pingHost(laptopWifiIp, timeoutMs: 800);
        if (wifiOk) {
          useAndroidEmulator = false;
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  /// Simpan IP dan konfigurasi server baru ke SharedPreferences.
  static Future<void> setServerConfig({
    required String ip,
    int? customPort,
    bool? isEmulator,
  }) async {
    laptopWifiIp = ip.trim();
    if (customPort != null && customPort > 0) port = customPort;
    if (isEmulator != null) useAndroidEmulator = isEmulator;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyServerIp, laptopWifiIp);
      await prefs.setInt(_keyServerPort, port);
      await prefs.setBool(_keyUseEmulator, useAndroidEmulator);
    } catch (_) {}
  }

  /// Alamat berdasarkan platform (hanya untuk development).
  static String get _baseUrlDev {
    if (customBaseUrl != null && customBaseUrl!.trim().isNotEmpty) {
      return customBaseUrl!.trim();
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:$port/api';
    }

    try {
      if (Platform.isAndroid) {
        if (useAndroidEmulator) return 'http://10.0.2.2:$port/api';
        return 'http://$laptopWifiIp:$port/api';
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'http://127.0.0.1:$port/api';
      } else if (Platform.isIOS) {
        return 'http://$laptopWifiIp:$port/api';
      }
    } catch (_) {}

    return 'http://$laptopWifiIp:$port/api';
  }

  // ───────────────────────── [DEV-ONLY] selesai ─────────────────────────

  /// Alamat dasar API (sudah termasuk `/api` di ujungnya).
  /// Semua endpoint di bawah dibangun dari sini.
  static String get baseUrl {
    // Prioritas 1: --dart-define (dev via USB & production)
    if (_pakaiUrlTetap) return _envBaseUrl;

    // Prioritas 2/3: [DEV-ONLY] override manual & deteksi platform.
    // Setelah deploy, ganti seluruh isi getter ini dengan: return _envBaseUrl;
    return _baseUrlDev;
  }

  // ── Health Check ──
  static String get ping => '$baseUrl/ping';

  // ── Authentication Endpoints ──
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String userProfile(dynamic id) => '$baseUrl/auth/user/$id';

  // ── Beranda Mobile (Single Fetch) ──
  static String beranda({dynamic userId}) =>
      userId != null ? '$baseUrl/beranda?id_user=$userId' : '$baseUrl/beranda';

  // ── Setor Sampah & Kategori Endpoints ──
  static String get kategoriSampah => '$baseUrl/sampah/kategori';
  static String get riwayatSetor => '$baseUrl/sampah/riwayat';
  static String get setorSampah => '$baseUrl/sampah/setor';
  static String get trackingLokasi => '$baseUrl/tracking-lokasi';

  // ── Produk Prakarya / Marketplace Endpoints ──
  static String get listPrakarya => '$baseUrl/prakarya';
  static String detailPrakarya(dynamic id) => '$baseUrl/prakarya/$id';
  static String get listProduk => listPrakarya; // Alias kompatibilitas
  static String get transaksi => '$baseUrl/transaksi';
  static String get riwayatTransaksi => '$baseUrl/riwayat-transaksi';

  // ── Bank Sampah (lokasi) ──
  static String get bankSampah => '$baseUrl/bank-sampah';

  // ── Konten Edukasi & Upload Konten ──
  static String get listEdukasi => '$baseUrl/edukasi';
  static String detailEdukasi(dynamic id) => '$baseUrl/edukasi/$id';
  static String get uploadEdukasi => '$baseUrl/edukasi/upload';
  static String userKonten(dynamic userId) => '$baseUrl/edukasi/user/$userId';
}