class KomentarModel {
  final int id;
  final int edukasiId;
  final String namaPenulis;
  final String isiKomentar;
  final String createdAt;

  KomentarModel({
    required this.id,
    required this.edukasiId,
    required this.namaPenulis,
    required this.isiKomentar,
    required this.createdAt,
  });

  /// Factory untuk mengonversi JSON response dari API menjadi Object Dart
  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    return KomentarModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      edukasiId: json['edukasi_id'] is int
          ? json['edukasi_id']
          : int.tryParse(json['edukasi_id']?.toString() ?? '0') ?? 0,
      namaPenulis: json['nama_penulis'] ?? json['nama'] ?? 'Tamu',
      isiKomentar: json['isi_komentar'] ?? json['isi'] ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  /// Body data untuk dikirimkan saat POST Komentar Baru
  Map<String, String> toPostJson() {
    return {
      'nama': namaPenulis,
      'isi_komentar': isiKomentar,
    };
  }
}