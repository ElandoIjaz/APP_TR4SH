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
