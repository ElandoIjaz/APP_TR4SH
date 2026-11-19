export 'models/transaksi_model.dart';
export 'models/riwayat_setor_model.dart';

import 'models/transaksi_model.dart';
import 'models/riwayat_setor_model.dart';

class UserAccountData {
  UserAccountData._();

  static int? currentUserId;
  static String currentNama = 'Tamu';
  static String currentUsername = '';
  static String currentPhone = '';
  static String? currentFoto;
  static String currentStatusAkun = 'tamu';
  static double totalSampahKg = 0.0;
  static int totalSetoran = 0;
  static bool isNewAccount = false;
  static bool isGuest = true;
  static List<dynamic> listKontenSaya = [];

  static bool get isLoggedIn => !isGuest && currentUserId != null;

  static void setGuestMode() {
    isGuest = true;
    currentUserId = null;
    currentNama = 'Tamu';
    currentUsername = '';
    currentPhone = '';
    currentFoto = null;
    currentStatusAkun = 'tamu';
    totalSampahKg = 0.0;
    totalSetoran = 0;
    isNewAccount = false;
    listRiwayatSetor = [];
    listKontenSaya = [];
    listTransaksi = [];
  }

  static void initNewUser({
    required String nama,
    required String username,
    required String phone,
    int? userId,
  }) {
    isGuest = false;
    currentUserId = userId;
    currentNama = nama;
    currentUsername = username;
    currentPhone = phone;
    currentFoto = null;
    currentStatusAkun = 'aktif';
    totalSampahKg = 0.0;
    totalSetoran = 0;
    isNewAccount = true;
    listRiwayatSetor = [];
    listKontenSaya = [];
    listTransaksi = [];
  }

  static void updateFromUserData(Map<String, dynamic> user) {
    isGuest = false;
    if (user['id_user'] != null) {
      currentUserId = int.tryParse(user['id_user'].toString());
    }
    if (user['nama_lengkap'] != null &&
        user['nama_lengkap'].toString().isNotEmpty) {
      currentNama = user['nama_lengkap'].toString();
    }
    if (user['username'] != null && user['username'].toString().isNotEmpty) {
      currentUsername = user['username'].toString();
    }

    // Sinkronisasi nomor telepon dari kolom no_wa backend (plus fallback)
    final rawPhone = user['no_wa'] ??
        user['telepon'] ??
        user['no_hp'] ??
        user['phone'];
    if (rawPhone != null && rawPhone.toString().trim().isNotEmpty) {
      currentPhone = rawPhone.toString().trim();
    }

    if (user.containsKey('foto')) {
      final rawFoto = user['foto']?.toString().trim();
      currentFoto = (rawFoto != null && rawFoto.isNotEmpty) ? rawFoto : null;
    }

    if (user['status_akun'] != null) {
      currentStatusAkun = user['status_akun'].toString();
    }

    final stats = user['statistik'];
    if (stats != null && stats is Map) {
      totalSampahKg =
          double.tryParse(stats['total_sampah_kg'].toString()) ?? 0.0;
      totalSetoran = int.tryParse(stats['total_setoran'].toString()) ?? 0;
    } else if (user['total_sampah_kg'] != null ||
        user['total_setoran'] != null) {
      totalSampahKg =
          double.tryParse((user['total_sampah_kg'] ?? '0').toString()) ?? 0.0;
      totalSetoran =
          int.tryParse((user['total_setoran'] ?? '0').toString()) ?? 0;
    }

    isNewAccount = user['is_new'] == true;
  }

  static void resetSession() {
    setGuestMode();
  }

  static List<TransaksiModel> listTransaksi = [];
  static List<RiwayatSetorModel> listRiwayatSetor = [];
}