import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/keranjang_model.dart';

export 'models/keranjang_model.dart';

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
            .map((e) => ItemKeranjangModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
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
    final double diskon =
        double.tryParse(product['diskon_persen']?.toString() ?? '0') ?? 0.0;
    final int stokTersedia =
        int.tryParse(product['jumlah']?.toString() ?? '0') ?? 0;

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
            content: Text(
                'Stok $nama tidak mencukupi. Sisa stok: $stokTersedia unit.'),
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
          .map((e) =>
              TingkatGrosirModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final String foto =
        product['foto'] ?? product['gambar'] ?? product['image'] ?? '';

    final int existingIndex =
        items.indexWhere((element) => element.idProduct == id && id != 0);

    if (existingIndex != -1) {
      // 3. Validasi saat produk sudah ada di keranjang: kuantitas total tidak boleh tembus stok
      if (items[existingIndex].quantity + qty > stokTersedia) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Tidak dapat menambah. Sisa stok $nama hanya $stokTersedia unit.'),
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