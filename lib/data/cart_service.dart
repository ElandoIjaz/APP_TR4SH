import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        diskonPersen: double.tryParse(json['diskon_persen']?.toString() ?? '0') ?? 0.0,
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
          .map((e) => TingkatGrosirModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (json['grosirs'] != null && json['grosirs'] is List) {
      listGrosir = (json['grosirs'] as List)
          .map((e) => TingkatGrosirModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return ItemKeranjangModel(
      idProduct: json['id_product'] as int? ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? 'Produk Daur Ulang',
      harga: json['harga'] is int
          ? json['harga'] as int
          : int.tryParse(json['harga'].toString()) ?? 0,
      diskonPersen: double.tryParse(json['diskon_persen']?.toString() ?? '0') ?? 0.0,
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

/// Pengelola keranjang belanja global
class CartService {
  CartService._();

  static const String _keyCart = 'user_cart_items_json';
  static List<ItemKeranjangModel> items = [];

  static Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_keyCart);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        items = list
            .map((e) => ItemKeranjangModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Gagal memuat keranjang: $e');
    }
  }

  static Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_keyCart, encoded);
    } catch (e) {
      debugPrint('Gagal menyimpan keranjang: $e');
    }
  }

  static int get totalCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  static Future<bool> tambahProduk(
    Map<String, dynamic> product, {
    int qty = 1,
    BuildContext? context,
  }) async {
    final int id = product['id_product'] is int
        ? product['id_product'] as int
        : int.tryParse(product['id_product'].toString()) ?? 0;

    final String nama = product['nama_product'] ??
        product['nama_produk'] ??
        product['title'] ??
        'Produk Daur Ulang';

    final int harga = int.tryParse(product['harga'].toString()) ?? 0;
    final double diskon = double.tryParse(product['diskon_persen']?.toString() ?? '0') ?? 0.0;
    final int stokTersedia = int.tryParse(product['jumlah']?.toString() ?? '0') ?? 0;

    // 1. Validasi awal: Jika stok produk kosong / 0
    if (stokTersedia <= 0) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maaf, stok $nama sedang habis!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }

    // 2. Validasi awal: Jika quantity yang diminta melebihi stok yang ada
    if (qty > stokTersedia) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok $nama tidak mencukupi. Sisa stok: $stokTersedia unit.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }

    // Parsing data grosir dari response API
    List<TingkatGrosirModel> grosirs = [];
    if (product['grosir'] != null && product['grosir'] is List) {
      grosirs = (product['grosir'] as List)
          .map((e) => TingkatGrosirModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final String foto = product['foto'] ??
        product['gambar'] ??
        product['image'] ??
        '';

    final int existingIndex = items.indexWhere((element) => element.idProduct == id && id != 0);

    if (existingIndex != -1) {
      // 3. Validasi saat produk sudah ada di keranjang: kuantitas total tidak boleh tembus stok
      if (items[existingIndex].quantity + qty > stokTersedia) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat menambah. Sisa stok $nama hanya $stokTersedia unit.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return false;
      }

      items[existingIndex].quantity += qty;

      if (grosirs.isNotEmpty) {
        items[existingIndex] = ItemKeranjangModel(
          idProduct: items[existingIndex].idProduct,
          namaProduk: nama,
          harga: harga,
          diskonPersen: diskon,
          grosirs: grosirs,
          foto: foto.isNotEmpty ? foto : items[existingIndex].foto,
          quantity: items[existingIndex].quantity,
          stokMaksimal: stokTersedia,
          isSelected: items[existingIndex].isSelected,
        );
      }
    } else {
      items.add(
        ItemKeranjangModel(
          idProduct: id,
          namaProduk: nama,
          harga: harga,
          diskonPersen: diskon,
          grosirs: grosirs,
          foto: foto,
          quantity: qty,
          stokMaksimal: stokTersedia,
          isSelected: true,
        ),
      );
    }

    await _saveCart();
    return true;
  }

  static Future<void> hapusProduk(int idProduct) async {
    items.removeWhere((element) => element.idProduct == idProduct);
    await _saveCart();
  }

  static Future<void> kosongkanKeranjang() async {
    items.clear();
    await _saveCart();
  }

  static Future<void> updateItem() async {
    await _saveCart();
  }
}