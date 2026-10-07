import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static const String _keyServerIp = 'app_server_ip';
  static const String _keyServerPort = 'app_server_port';
  static const String _keyUseEmulator = 'app_use_emulator';

  /// IP Laptop / Server lokal saat testing di HP fisik via WiFi yang sama.
  /// Berdasarkan command `ipconfig`, IP WiFi laptop saat ini adalah 10.10.181.109
  static String laptopWifiIp = '10.10.181.109';

  /// Port standar Laravel `php artisan serve`
  static int port = 8000;

  /// Mode Android Emulator (10.0.2.2). Default false, otomatis disetel true jika emulator terdeteksi.
  static bool useAndroidEmulator = false;

  /// Custom Base URL jika ingin di-override secara eksplisit
  static String? customBaseUrl;

  /// Inisialisasi konfigurasi dari penyimpanan lokal (SharedPreferences)
  static Future<void> initConfig() async {
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
        // Auto-deteksi jika belum disimpan secara manual oleh user
        await autoDetectWorkingHost();
      }
    } catch (_) {}
  }

  /// Cek cepat apakah koneksi ke host tertentu aktif
  static Future<bool> pingHost(String ipOrHost, {int? checkPort, int timeoutMs = 800}) async {
    try {
      final p = checkPort ?? port;
      final client = HttpClient()..connectionTimeout = Duration(milliseconds: timeoutMs);
      final req = await client.getUrl(Uri.parse('http://$ipOrHost:$p/api/ping'));
      final res = await req.close().timeout(Duration(milliseconds: timeoutMs));
      final isOk = res.statusCode == 200;
      client.close();
      return isOk;
    } catch (_) {
      return false;
    }
  }

  /// Melakukan deteksi otomatis antara Android Emulator (10.0.2.2) dan HP Fisik via WiFi (laptopWifiIp)
  static Future<bool> autoDetectWorkingHost() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        // 1. Coba loopback Android emulator (10.0.2.2)
        final emuOk = await pingHost('10.0.2.2', timeoutMs: 600);
        if (emuOk) {
          useAndroidEmulator = true;
          return true;
        }

        // 2. Coba IP WiFi laptop
        final wifiOk = await pingHost(laptopWifiIp, timeoutMs: 800);
        if (wifiOk) {
          useAndroidEmulator = false;
          return true;
        }

        // 3. Coba IP default cadangan jika laptopWifiIp belum sesuai
        if (laptopWifiIp != '10.10.181.109') {
          final defaultWifiOk = await pingHost('10.10.181.109', timeoutMs: 800);
          if (defaultWifiOk) {
            laptopWifiIp = '10.10.181.109';
            useAndroidEmulator = false;
            return true;
          }
        }
      }
    } catch (_) {}

    return false;
  }

  /// Simpan IP dan konfigurasi server baru ke SharedPreferences
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

  /// Penentu Base URL otomatis berdasarkan platform yang sedang berjalan:
  /// - Web: Menggunakan 127.0.0.1
  /// - Windows Desktop / macOS / Linux: Menggunakan 127.0.0.1
  /// - Android Emulator: Menggunakan 10.0.2.2 (jika useAndroidEmulator == true)
  /// - HP Fisik Android/iOS: Menggunakan IP WiFi Laptop (10.10.181.109)
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.trim().isNotEmpty) {
      return customBaseUrl!.trim();
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:$port/api';
    }

    try {
      if (Platform.isAndroid) {
        if (useAndroidEmulator) {
          return 'http://10.0.2.2:$port/api';
        }
        return 'http://$laptopWifiIp:$port/api';
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'http://127.0.0.1:$port/api';
      } else if (Platform.isIOS) {
        return 'http://$laptopWifiIp:$port/api';
      }
    } catch (_) {}

    return 'http://$laptopWifiIp:$port/api';
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

  // ── Konten Edukasi & Upload Konten ──
  static String get listEdukasi => '$baseUrl/edukasi';
  static String detailEdukasi(dynamic id) => '$baseUrl/edukasi/$id';
  static String get uploadEdukasi => '$baseUrl/edukasi/upload';
  static String userKonten(dynamic userId) => '$baseUrl/edukasi/user/$userId';
}
