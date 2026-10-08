export 'models/alamat_model.dart';
export 'models/transaksi_model.dart';
export 'models/riwayat_setor_model.dart';
export 'models/hadiah_reward_model.dart';

import 'models/alamat_model.dart';
import 'models/transaksi_model.dart';
import 'models/riwayat_setor_model.dart';
import 'models/hadiah_reward_model.dart';

class UserAccountData {
  UserAccountData._();

  static int userPoints = 500;
  static int? currentUserId;
  static String currentNama = 'Bintang Pratama';
  static String currentUsername = 'bintang_eco';
  static String currentPhone = '0812-3456-7890';
  static String? currentFoto;
  static String currentStatusAkun = 'aktif';
  static double totalSampahKg = 0.0;
  static int totalSetoran = 0;
  static int totalMisiSelesai = 3;
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
    userPoints = 0;
    totalSampahKg = 0.0;
    totalSetoran = 0;
    totalMisiSelesai = 0;
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
    userPoints = 0;
    totalSampahKg = 0.0;
    totalSetoran = 0;
    totalMisiSelesai = 0;
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
    if (user['poin'] != null) {
      userPoints = int.tryParse(user['poin'].toString()) ?? 0;
    } else if (user['points'] != null) {
      userPoints = int.tryParse(user['points'].toString()) ?? 0;
    }
    if (user['total_sampah_kg'] != null) {
      totalSampahKg =
          double.tryParse(user['total_sampah_kg'].toString()) ?? 0.0;
    }
    if (user['total_setoran'] != null) {
      totalSetoran = int.tryParse(user['total_setoran'].toString()) ?? 0;
    }
    final bool isUserBaru =
        user['is_new'] == true ||
        isNewAccount ||
        (user['id_user'] != null && totalSampahKg == 0.0 && totalSetoran == 0);
    if (isUserBaru) {
      userPoints = user['poin'] != null
          ? (int.tryParse(user['poin'].toString()) ?? 0)
          : 0;
      totalSampahKg = 0.0;
      totalSetoran = 0;
      totalMisiSelesai = 0;
      isNewAccount = true;
      listRiwayatSetor = [];
      listKontenSaya = [];
      listTransaksi = [];
    }
  }

  static void resetSession() {
    isGuest = true;
    currentUserId = null;
    currentNama = 'Tamu';
    currentUsername = '';
    currentFoto = null;
    userPoints = 0;
    totalSampahKg = 0.0;
    totalSetoran = 0;
    totalMisiSelesai = 0;
    isNewAccount = false;
    listRiwayatSetor = [];
    listKontenSaya = [];
    listTransaksi = [];
  }

  static List<AlamatModel> listAlamat = [
    AlamatModel(
      id: 'addr-1',
      label: 'Rumah',
      penerima: 'Bintang Pratama',
      telepon: '0812-3456-7890',
      alamatLengkap:
          'Jl. Riau No. 45, RT 03 / RW 07, Kel. Citarum, Kec. Bandung Wetan',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40115',
      patokan: 'Pagar besi hitam, depan bank sampah RT 03',
      latitude: -6.907482,
      longitude: 107.618954,
      akurasiGps: '±2 meter (GPS Akurat)',
      isUtama: true,
    ),
    AlamatModel(
      id: 'addr-2',
      label: 'Kantor',
      penerima: 'Bintang Pratama (TR4SH Office)',
      telepon: '0813-9876-5432',
      alamatLengkap: 'Gedung Eco Hub Lt. 4, Jl. Ir. H. Juanda No. 128',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40132',
      patokan: 'Lobby timur, samping drop box daur ulang',
      latitude: -6.892114,
      longitude: 107.610842,
      akurasiGps: '±3 meter (GPS Akurat)',
      isUtama: false,
    ),
  ];

  static List<TransaksiModel> listTransaksi = [
    TransaksiModel(
      id: 'trx-1',
      noInvoice: 'INV/20260928/TR4SH/001',
      tanggal: '28 Sep 2026, 10:30 WIB',
      namaToko: 'Karya Mandiri Eco',
      judulProduk: 'Pot Bunga dari Botol Plastik Daur Ulang',
      gambarProduk: 'assets/images/produk_pot_bunga.jpg',
      totalHarga: 35000,
      jumlahBarang: 1,
      status: 'Dikirim',
      limbahTerselamatkan: '250g plastik',
    ),
    TransaksiModel(
      id: 'trx-2',
      noInvoice: 'INV/20260925/TR4SH/089',
      tanggal: '25 Sep 2026, 14:15 WIB',
      namaToko: 'Re-Craft Studio',
      judulProduk: 'Tas Tote dari Karung Bekas',
      gambarProduk: 'assets/images/produk_tas_karung.jpg',
      totalHarga: 55000,
      jumlahBarang: 1,
      status: 'Selesai',
      limbahTerselamatkan: '180g karung',
    ),
    TransaksiModel(
      id: 'trx-3',
      noInvoice: 'INV/20260920/TR4SH/045',
      tanggal: '20 Sep 2026, 09:00 WIB',
      namaToko: 'Karya Mandiri Eco',
      judulProduk: 'Lampu Hias dari Limbah Botol',
      gambarProduk: 'assets/images/produk_lampu_botol.jpg',
      totalHarga: 78000,
      jumlahBarang: 1,
      status: 'Selesai',
      limbahTerselamatkan: '320g kaca',
    ),
  ];

  static List<RiwayatSetorModel> listRiwayatSetor = [
    RiwayatSetorModel(
      id: 'setor-1',
      tanggal: '27 Sep 2026, 11:20 WIB',
      kategori: 'Botol Plastik PET',
      beratKg: 4.2,
      poin: 630,
      lokasiBankSampah: 'Bank Sampah Citarum Bersih',
      status: 'Berhasil Diverifikasi',
      estimasiCo2: '6.3 kg CO2e dicegah',
    ),
    RiwayatSetorModel(
      id: 'setor-2',
      tanggal: '21 Sep 2026, 15:40 WIB',
      kategori: 'Kardus & Kertas Bekas',
      beratKg: 8.5,
      poin: 850,
      lokasiBankSampah: 'Unit Drop Point Dago',
      status: 'Berhasil Diverifikasi',
      estimasiCo2: '11.9 kg CO2e dicegah',
    ),
    RiwayatSetorModel(
      id: 'setor-3',
      tanggal: '15 Sep 2026, 10:10 WIB',
      kategori: 'Kaleng Logam & Seng',
      beratKg: 2.1,
      poin: 420,
      lokasiBankSampah: 'Bank Sampah Citarum Bersih',
      status: 'Berhasil Diverifikasi',
      estimasiCo2: '4.8 kg CO2e dicegah',
    ),
  ];

  static List<HadiahRewardModel> listHadiah = [
    HadiahRewardModel(
      id: 'rew-1',
      judul: 'Voucher Belanja Eco Rp 20.000',
      kategori: 'Voucher Belanja',
      poinDibutuhkan: 200,
      deskripsi:
          'Potongan langsung Rp 20.000 untuk belanja di TR4SH! Marketplace.',
      badge: 'Terpopuler',
    ),
    HadiahRewardModel(
      id: 'rew-2',
      judul: 'Tote Bag Sirkular Eksklusif',
      kategori: 'Merchandise',
      poinDibutuhkan: 450,
      deskripsi: 'Tas belanja ramah lingkungan edisi terbatas dari serat goni upcycle.',
      badge: 'Edisi Terbatas',
    ),
    HadiahRewardModel(
      id: 'rew-3',
      judul: 'Donasi 1 Bibit Pohon Mangrove',
      kategori: 'Dampak Sosial',
      poinDibutuhkan: 150,
      deskripsi: 'Ditanam atas nama Anda di pesisir pantai bekerja sama dengan LindungiHutan.',
      badge: 'Dampak Nyata',
    ),
    HadiahRewardModel(
      id: 'rew-4',
      judul: 'Saldo E-Wallet Rp 50.000',
      kategori: 'E-Wallet',
      poinDibutuhkan: 600,
      deskripsi: 'Tukar poin menjadi saldo GoPay, OVO, atau DANA.',
      badge: 'Pilihan Favorit',
    ),
  ];
}
