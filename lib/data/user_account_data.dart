class AlamatModel {
  final String id;
  final String label; // 'Rumah', 'Kantor', dll.
  final String penerima;
  final String telepon;
  final String alamatLengkap;
  final String kota;
  final String kodePos;
  final String patokan;
  final double latitude;
  final double longitude;
  final String akurasiGps;
  bool isUtama;

  AlamatModel({
    required this.id,
    required this.label,
    required this.penerima,
    required this.telepon,
    required this.alamatLengkap,
    required this.kota,
    required this.kodePos,
    required this.patokan,
    required this.latitude,
    required this.longitude,
    this.akurasiGps = '±2 meter (Sangat Akurat)',
    this.isUtama = false,
  });
}

class TransaksiModel {
  final String id;
  final String noInvoice;
  final String tanggal;
  final String namaToko;
  final String judulProduk;
  final String gambarProduk;
  final int totalHarga;
  final int jumlahBarang;
  final String status;
  final String limbahTerselamatkan;

  TransaksiModel({
    required this.id,
    required this.noInvoice,
    required this.tanggal,
    required this.namaToko,
    required this.judulProduk,
    required this.gambarProduk,
    required this.totalHarga,
    required this.jumlahBarang,
    required this.status,
    required this.limbahTerselamatkan,
  });
}

class RiwayatSetorModel {
  final String id;
  final String tanggal;
  final String kategori;
  final double beratKg;
  final int poin;
  final String lokasiBankSampah;
  final String status;
  final String estimasiCo2;

  RiwayatSetorModel({
    required this.id,
    required this.tanggal,
    required this.kategori,
    required this.beratKg,
    required this.poin,
    required this.lokasiBankSampah,
    required this.status,
    required this.estimasiCo2,
  });
}

class HadiahRewardModel {
  final String id;
  final String judul;
  final String kategori;
  final int poinDibutuhkan;
  final String deskripsi;
  final String badge;
  final bool isTersedia;

  HadiahRewardModel({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.poinDibutuhkan,
    required this.deskripsi,
    required this.badge,
    this.isTersedia = true,
  });
}

class UserAccountData {
  UserAccountData._();

  static int userPoints = 500;

  static List<AlamatModel> listAlamat = [
    AlamatModel(
      id: 'addr-1',
      label: 'Rumah',
      penerima: 'Bintang Pratama',
      telepon: '0812-3456-7890',
      alamatLengkap: 'Jl. Riau No. 45, RT 03 / RW 07, Kel. Citarum, Kec. Bandung Wetan',
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
      deskripsi: 'Potongan langsung Rp 20.000 untuk belanja di TR4SH! Marketplace.',
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
