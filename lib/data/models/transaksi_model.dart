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
