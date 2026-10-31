class BankSampah {
  final int id;
  final String nama;
  final String? alamat;
  final String? kecamatan;
  final String? noTelp;
  final String? jamOperasional;
  final double latitude;
  final double longitude;
  final bool isUtama;

  const BankSampah({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    this.alamat,
    this.kecamatan,
    this.noTelp,
    this.jamOperasional,
    this.isUtama = false,
  });

  factory BankSampah.fromJson(Map<String, dynamic> json) {
    return BankSampah(
      id: json['id_bank_sampah'] as int,
      nama: json['nama_bank_sampah'] as String,
      alamat: json['alamat'] as String?,
      kecamatan: json['kecamatan'] as String?,
      noTelp: json['no_telp'] as String?,
      jamOperasional: json['jam_operasional'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isUtama: json['is_utama'] as bool? ?? false,
    );
  }
}