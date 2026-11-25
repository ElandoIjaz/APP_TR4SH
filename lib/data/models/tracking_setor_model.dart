class PengajuanSetorModel {
  final int idSampah;
  final String namaKategori;
  final String jenisSampah;
  final double jumlah;
  final String satuan;
  final double totalRupiah;
  final String? createdAt;
  final String statusVerifikasi;
  final String? pesanAdmin;

  const PengajuanSetorModel({
    required this.idSampah,
    required this.namaKategori,
    required this.jenisSampah,
    required this.jumlah,
    required this.satuan,
    required this.totalRupiah,
    this.createdAt,
    required this.statusVerifikasi,
    this.pesanAdmin,
  });

  factory PengajuanSetorModel.fromJson(Map<String, dynamic> json) {
    return PengajuanSetorModel(
      idSampah: int.tryParse(json['id_sampah']?.toString() ?? '0') ?? 0,
      namaKategori: json['nama_kategori']?.toString() ?? 'Sampah',
      jenisSampah: json['jenis_sampah']?.toString() ?? 'Setoran',
      jumlah: double.tryParse(json['jumlah']?.toString() ?? '0') ?? 0.0,
      satuan: json['satuan']?.toString() ?? 'kg',
      totalRupiah: double.tryParse(json['total_rupiah']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString(),
      statusVerifikasi:
          (json['status_verifikasi']?.toString() ?? 'pending').toLowerCase(),
      pesanAdmin: json['pesan_admin']?.toString(),
    );
  }

  bool get isAccepted => statusVerifikasi == 'accepted';
  bool get isPending => statusVerifikasi == 'pending';
  bool get isDenied => statusVerifikasi == 'denied';

  String get statusLabel {
    if (isAccepted) return 'Accepted';
    if (isDenied) return 'Denied';
    return 'Pending';
  }

  String get formattedRupiah {
    final formatted = totalRupiah.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  Map<String, dynamic> toMap() {
    return {
      'id_sampah': idSampah,
      'nama_kategori': namaKategori,
      'jenis_sampah': jenisSampah,
      'jumlah': jumlah,
      'satuan': satuan,
      'total_rupiah': totalRupiah,
      'created_at': createdAt,
      'status_verifikasi': statusVerifikasi,
      'pesan_admin': pesanAdmin,
    };
  }
}

class KeranjangSetorItemModel {
  final int idKategori;
  final String namaKategori;
  String jenisSampah;
  double jumlah;
  final String satuan;
  final double hargaPerKg;

  KeranjangSetorItemModel({
    required this.idKategori,
    required this.namaKategori,
    required this.jumlah,
    this.satuan = 'kg',
    required this.hargaPerKg,
    String? jenisSampah,
  }) : jenisSampah =
            jenisSampah ?? '$namaKategori ${jumlah.toStringAsFixed(1)} $satuan';

  void updateBerat(double beratBaru) {
    jumlah = double.parse(beratBaru.toStringAsFixed(1));
    jenisSampah = '$namaKategori ${jumlah.toStringAsFixed(1)} $satuan';
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'id_kategori': idKategori,
      'jenis_sampah': jenisSampah,
      'jumlah': jumlah,
      'satuan': satuan,
    };
  }
}

class KategoriSampahModel {
  final int idKategori;
  final String namaKategori;
  final double hargaPerKg;

  const KategoriSampahModel({
    required this.idKategori,
    required this.namaKategori,
    required this.hargaPerKg,
  });

  factory KategoriSampahModel.fromJson(Map<String, dynamic> json) {
    return KategoriSampahModel(
      idKategori: json['id_kategori'] is int
          ? json['id_kategori'] as int
          : int.tryParse(json['id_kategori']?.toString() ?? '1') ?? 1,
      namaKategori: json['nama_kategori']?.toString() ?? 'Kategori',
      hargaPerKg: json['harga_per_kg'] is num
          ? (json['harga_per_kg'] as num).toDouble()
          : double.tryParse(json['harga_per_kg']?.toString() ?? '3000') ??
              3000.0,
    );
  }
}