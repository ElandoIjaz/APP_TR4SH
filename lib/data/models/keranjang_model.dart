import 'dart:math';

/// Model untuk tingkat diskon grosir
class TingkatGrosirModel {
  final int minQty;
  final double diskonPersen;

  TingkatGrosirModel({
    required this.minQty,
    required this.diskonPersen,
  });

  Map<String, dynamic> toJson() => {
        'min_qty': minQty,
        'diskon_persen': diskonPersen,
      };

  factory TingkatGrosirModel.fromJson(Map<String, dynamic> json) =>
      TingkatGrosirModel(
        minQty: json['min_qty'] is int
            ? json['min_qty'] as int
            : int.tryParse(json['min_qty']?.toString() ?? '0') ?? 0,
        diskonPersen:
            double.tryParse(json['diskon_persen']?.toString() ?? '0') ?? 0.0,
      );
}

/// Model item keranjang belanja riil
class ItemKeranjangModel {
  final int idProduct;
  final String namaProduk;
  final int harga;
  final double diskonPersen; // Diskon langsung
  final List<TingkatGrosirModel> grosirs; // Daftar grosir bertingkat
  final String foto;
  final String merchant;
  final String lokasi;
  int quantity;
  final int stokMaksimal; // Batas stok dari database
  bool isSelected;

  static const double maksDiskon = 15.0;

  ItemKeranjangModel({
    required this.idProduct,
    required this.namaProduk,
    required this.harga,
    this.diskonPersen = 0.0,
    this.grosirs = const [],
    required this.foto,
    this.merchant = 'Bank Sampah Ibu TR4SH',
    this.lokasi = 'Jember, Jawa Timur',
    this.quantity = 1,
    required this.stokMaksimal,
    this.isSelected = true,
  });

  /// Logika "Ambil diskon terbaik" (Sama dengan Product.php di Laravel)
  double diskonBerlaku(int qty) {
    double diskonGrosir = 0.0;
    for (var g in grosirs) {
      if (qty >= g.minQty && g.diskonPersen > diskonGrosir) {
        diskonGrosir = g.diskonPersen;
      }
    }

    final double diskonTerbaik = max(diskonPersen, diskonGrosir);
    return min(maksDiskon, diskonTerbaik);
  }

  /// Menghitung harga satuan efektif berdasarkan quantity saat ini
  int get hargaFinal {
    final double diskon = diskonBerlaku(quantity);
    if (diskon > 0) {
      final diskonNominal = (harga * (diskon / 100)).round();
      return harga - diskonNominal;
    }
    return harga;
  }

  /// Mengecek apakah item saat ini mendapatkan diskon (langsung atau grosir)
  bool get adaDiskon => diskonBerlaku(quantity) > 0;

  Map<String, dynamic> toJson() => {
        'id_product': idProduct,
        'nama_produk': namaProduk,
        'harga': harga,
        'diskon_persen': diskonPersen,
        'grosirs': grosirs.map((e) => e.toJson()).toList(),
        'foto': foto,
        'merchant': merchant,
        'lokasi': lokasi,
        'quantity': quantity,
        'stok_maksimal': stokMaksimal,
        'is_selected': isSelected,
      };

  factory ItemKeranjangModel.fromJson(Map<String, dynamic> json) {
    List<TingkatGrosirModel> listGrosir = [];
    if (json['grosir'] != null && json['grosir'] is List) {
      listGrosir = (json['grosir'] as List)
          .map((e) =>
              TingkatGrosirModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (json['grosirs'] != null && json['grosirs'] is List) {
      listGrosir = (json['grosirs'] as List)
          .map((e) =>
              TingkatGrosirModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return ItemKeranjangModel(
      idProduct: json['id_product'] as int? ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? 'Produk Daur Ulang',
      harga: json['harga'] is int
          ? json['harga'] as int
          : int.tryParse(json['harga'].toString()) ?? 0,
      diskonPersen:
          double.tryParse(json['diskon_persen']?.toString() ?? '0') ?? 0.0,
      grosirs: listGrosir,
      foto: json['foto']?.toString() ?? '',
      merchant: json['merchant']?.toString() ?? 'Bank Sampah Ibu TR4SH',
      lokasi: json['lokasi']?.toString() ?? 'Jember, Jawa Timur',
      quantity: json['quantity'] as int? ?? 1,
      stokMaksimal: json['stok_maksimal'] as int? ?? 999,
      isSelected: json['is_selected'] as bool? ?? true,
    );
  }
}