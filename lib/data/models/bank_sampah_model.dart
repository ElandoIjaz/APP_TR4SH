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
    final rawId = json['id_bank_sampah'] ?? json['id'];
    final rawIsUtama = json['is_utama'];

    return BankSampah(
      id: int.tryParse(rawId?.toString() ?? '') ?? 0,
      nama: (json['nama_bank_sampah'] ?? json['nama'] ?? 'Bank Sampah').toString(),
      alamat: json['alamat']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      noTelp: json['no_telp']?.toString(),
      jamOperasional: json['jam_operasional']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      isUtama: rawIsUtama == true || rawIsUtama == 1 || rawIsUtama == '1',
    );
  }
}