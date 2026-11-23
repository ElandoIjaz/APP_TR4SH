import 'keranjang_model.dart';

class ProdukModel {
  final int idProduct;
  final String namaProduk;
  final String deskripsi;
  final String kategori;
  final int harga;
  final double diskonPersen;
  final int terjual;
  final int stok;
  final String foto;
  final String plastikPet;
  final String jejakKarbon;
  final String bahan;
  final String dimensi;
  final String fiturUtama;
  final String tentangKoleksi;
  final List<TingkatGrosirModel> grosir;
  final Map<String, dynamic> rawJson;

  const ProdukModel({
    required this.idProduct,
    required this.namaProduk,
    this.deskripsi = '',
    this.kategori = '',
    required this.harga,
    this.diskonPersen = 0.0,
    this.terjual = 0,
    this.stok = 0,
    this.foto = '',
    this.plastikPet = '-',
    this.jejakKarbon = '-',
    this.bahan = '-',
    this.dimensi = '-',
    this.fiturUtama = '-',
    this.tentangKoleksi = '-',
    this.grosir = const [],
    this.rawJson = const {},
  });

  /// Harga setelah diskon langsung (jika ada)
  int get hargaFinal => diskonPersen > 0
      ? (harga - (harga * (diskonPersen / 100))).round()
      : harga;

  bool get adaDiskon => diskonPersen > 0;

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    final List<TingkatGrosirModel> listGrosir = [];
    if (json['grosir'] is List) {
      for (final g in json['grosir'] as List) {
        if (g is Map) {
          listGrosir.add(
            TingkatGrosirModel.fromJson(Map<String, dynamic>.from(g)),
          );
        }
      }
    }

    String readText(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final val = json[key];
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString();
        }
      }
      return fallback;
    }

    return ProdukModel(
      idProduct: json['id_product'] is int
          ? json['id_product'] as int
          : int.tryParse(json['id_product']?.toString() ?? '0') ?? 0,
      namaProduk: readText(
        [
          'nama_product',
          'nama_produk',
          'nama_prakarya',
          'nama',
          'nama_barang',
          'title',
          'name',
          'judul',
        ],
        fallback: 'Tanpa Nama',
      ),
      deskripsi: readText(['deskripsi', 'keterangan', 'detail', 'description']),
      kategori: readText(['kategori', 'kategori_produk', 'category']),
      harga: int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      diskonPersen:
          double.tryParse(json['diskon_persen']?.toString() ?? '0') ?? 0.0,
      terjual: int.tryParse(json['terjual']?.toString() ?? '0') ?? 0,
      stok: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      foto: readText(['foto', 'gambar', 'image']),
      plastikPet: readText(['plastik_pet'], fallback: '-'),
      jejakKarbon: readText(['jejak_karbon'], fallback: '-'),
      bahan: readText(['bahan'], fallback: '-'),
      dimensi: readText(['dimensi'], fallback: '-'),
      fiturUtama: readText(['fitur_utama'], fallback: '-'),
      tentangKoleksi: readText(['tentang_koleksi'], fallback: '-'),
      grosir: listGrosir,
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// Pencocokan kategori & kata kunci pencarian (sama persis dengan filter lama)
  bool matchesFilter({
    required String selectedKategori,
    required String query,
  }) {
    final String namaLower = namaProduk.toLowerCase();
    final String deskripsiLower = deskripsi.toLowerCase();
    final String kategoriLower = kategori.toLowerCase();

    if (selectedKategori != 'Semua') {
      final String target = selectedKategori.toLowerCase();
      if (!kategoriLower.contains(target) && !namaLower.contains(target)) {
        return false;
      }
    }

    if (query.isNotEmpty) {
      final bool matchField = namaLower.contains(query) ||
          deskripsiLower.contains(query) ||
          kategoriLower.contains(query);
      final bool matchAnyValue = rawJson.values.any((val) {
        if (val == null) return false;
        return val.toString().toLowerCase().contains(query);
      });

      if (!matchField && !matchAnyValue) {
        return false;
      }
    }

    return true;
  }

  /// Konversi ke Map untuk dikirim ke CartService.tambahProduk()
  Map<String, dynamic> toCartMap() => {
        'id_product': idProduct,
        'nama_product': namaProduk,
        'nama_produk': namaProduk,
        'harga': harga,
        'diskon_persen': diskonPersen,
        'jumlah': stok,
        'foto': foto,
        'grosir': grosir.map((e) => e.toJson()).toList(),
      };
}