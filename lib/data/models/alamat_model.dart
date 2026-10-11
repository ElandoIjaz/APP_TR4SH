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
