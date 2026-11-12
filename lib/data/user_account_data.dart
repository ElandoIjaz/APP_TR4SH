export 'models/transaksi_model.dart';
export 'models/riwayat_setor_model.dart';

import 'models/transaksi_model.dart';
import 'models/riwayat_setor_model.dart';

class UserAccountData {
  UserAccountData._();

  static int? currentUserId;
  static String currentNama = 'Bintang Pratama';
  static String currentUsername = 'bintang_eco';
  static String currentPhone = '0812-3456-7890';
  static String? currentFoto;
  static String currentStatusAkun = 'aktif';
  static double totalSampahKg = 0.0;
  static int totalSetoran = 0;
  static bool isNewAccount = false;
  static bool isGuest = false;
  static List<dynamic> listKontenSaya = [];

  static void setGuestMode() {
    isGuest = true;
    currentUserId = null;
    currentNama = 'Tamu';
    currentUsername = '';
    currentPhone = '';
    currentFoto = null;
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
    if (user['foto'] != null) {
      currentFoto = user['foto'].toString();
    }
    if (user['status_akun'] != null) {
      currentStatusAkun = user['status_akun'].toString();
    }

    // Mengambil data statistik (Total Kg & Setoran)
    final stats = user['statistik'];
    if (stats != null && stats is Map) {
      totalSampahKg = double.tryParse(stats['total_sampah_kg'].toString()) ?? 0.0;
      totalSetoran = int.tryParse(stats['total_setoran'].toString()) ?? 0;
    } else {
      if (user['total_sampah_kg'] != null) {
        totalSampahKg = double.tryParse(user['total_sampah_kg'].toString()) ?? 0.0;
      }
      if (user['total_setoran'] != null) {
        totalSetoran = int.tryParse(user['total_setoran'].toString()) ?? 0;
      }
    }
    
    isNewAccount = user['is_new'] == true;
  }

  static void resetSession() {
    isGuest = true;
    currentUserId = null;
    currentNama = 'Tamu';
    currentUsername = '';
    currentFoto = null;
    totalSampahKg = 0.0;
    totalSetoran = 0;
    isNewAccount = false;
    listRiwayatSetor = [];
    listKontenSaya = [];
    listTransaksi = [];
  }

  // List transaksi dan setoran masih menggunakan array kosong karena akan 
  // diisi dinamis dari API di masing-masing halamannya.
  static List<TransaksiModel> listTransaksi = [];
  static List<RiwayatSetorModel> listRiwayatSetor = [];
}