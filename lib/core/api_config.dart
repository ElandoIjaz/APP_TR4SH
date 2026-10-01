import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// IP Laptop / Server lokal saat testing di HP fisik via WiFi yang sama.
  /// Silakan ganti dengan IP laptop Anda (bisa dilihat via command `ipconfig`).
  static String laptopWifiIp = '192.168.1.10';

  /// Port standar Laravel `php artisan serve`
  static int port = 8000;

  /// Penentu Base URL otomatis berdasarkan platform yang sedang berjalan:
  /// - Android Emulator: Menggunakan 10.0.2.2 (alias localhost PC di Android Emulator)
  /// - Windows Desktop / Web: Menggunakan 127.0.0.1 atau localhost
  /// - iOS Simulator: Menggunakan 127.0.0.1
  /// - HP Fisik Android/iOS: Menggunakan IP WiFi Laptop
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:$port/api';
    }

    try {
      if (Platform.isAndroid) {
        // Cek apakah berjalan di emulator Android standar
        return 'http://10.0.2.2:$port/api';
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'http://127.0.0.1:$port/api';
      } else if (Platform.isIOS) {
        return 'http://127.0.0.1:$port/api';
      }
    } catch (_) {}

    return 'http://$laptopWifiIp:$port/api';
  }

  // ── Authentication Endpoints ──
  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get logout => '$baseUrl/logout';
  static String get userProfile => '$baseUrl/user-profile';

  // ── Setor Sampah & Tracking Endpoints ──
  static String get setorSampah => '$baseUrl/setor-sampah';
  static String get riwayatSetor => '$baseUrl/riwayat-setor';
  static String get trackingLokasi => '$baseUrl/tracking-lokasi';

  // ── Produk / Marketplace Endpoints ──
  static String get listProduk => '$baseUrl/produk';
  static String get transaksi => '$baseUrl/transaksi';
  static String get riwayatTransaksi => '$baseUrl/riwayat-transaksi';
}
