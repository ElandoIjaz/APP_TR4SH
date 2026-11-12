import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/cart_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/pages/produk/halaman_pembayaran.dart';

class HalamanKeranjang extends StatefulWidget {
  const HalamanKeranjang({super.key});

  @override
  State<HalamanKeranjang> createState() => _HalamanKeranjangState();
}

class _HalamanKeranjangState extends State<HalamanKeranjang> {
  bool _isLoading = true;
  bool _isCheckingOut = false;

  // Metode Pembayaran Terpilih: 'qris' atau 'bank_transfer'
  String _selectedMethod = 'qris';
  String _selectedBank = 'bca'; // 'bca', 'bni', 'bri', 'mandiri'

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    await CartService.loadCart();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  List<ItemKeranjangModel> get _cartItems => CartService.items;

  bool get _isAllSelected =>
      _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);

  int get _selectedItemCount => _cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  int get _totalPrice => _cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + (item.hargaFinal * item.quantity));

  void _toggleSelectAll(bool? value) async {
    final bool select = value ?? false;
    setState(() {
      for (var item in _cartItems) {
        item.isSelected = select;
      }
    });
    await CartService.updateItem();
  }

  void _removeItem(int idProduct) async {
    await CartService.hapusProduk(idProduct);
    if (!mounted) return;
    setState(() {});
  }

  void _clearCart() async {
    await CartService.kosongkanKeranjang();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Keranjang belanja dikosongkan')),
    );
  }

  Future<void> _prosesCheckout() async {
    // 1. Cek apakah user berstatus Tamu (Guest) atau belum memiliki ID User
    if (UserAccountData.isGuest || UserAccountData.currentUserId == null) {
      AuthRequiredModal.show(
        context,
        title: 'Login Diperlukan untuk Checkout',
        message:
            'Silakan masuk atau daftar akun terlebih dahulu agar pesanan dan riwayat transaksi tercatat pada akun Anda.',
        icon: Icons.shopping_bag_rounded,
      );
      return;
    }

    final selected = _cartItems.where((i) => i.isSelected).toList();
    if (selected.isEmpty) return;

    setState(() => _isCheckingOut = true);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/transaksi/checkout');
      final payload = {
        'id_user': UserAccountData.currentUserId, // Dinamis sesuai akun login
        'metode': _selectedMethod,
        'bank': _selectedMethod == 'bank_transfer' ? _selectedBank : null,
        'items': selected
            .map((e) => {'id_product': e.idProduct, 'quantity': e.quantity})
            .toList(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        if (!mounted) return;
        setState(() => _isCheckingOut = false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HalamanPembayaran(dataTransaksi: data),
          ),
        );
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F3DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.darkGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  size: 16,
                  color: Color(0xFF1E8850),
                ),
                const SizedBox(width: 4),
                Text(
                  'Keranjang Belanja ($_selectedItemCount)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            const Text(
              'TR4SH 2.0 CONSCIOUS CART',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.darkGreen,
            ),
            onPressed: _cartItems.isEmpty ? null : _clearCart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            )
          : _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Keranjang belanja Anda kosong',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Belanja Sekarang'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  // ── 1. Select All & Delete Action ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isAllSelected,
                                activeColor: AppColors.darkGreen,
                                checkColor: AppColors.limeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: _toggleSelectAll,
                              ),
                              Flexible(
                                child: Text(
                                  'Pilih Semua ($_selectedItemCount item)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGreen,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final selected = _cartItems
                                .where((item) => item.isSelected)
                                .toList();
                            for (var item in selected) {
                              await CartService.hapusProduk(item.idProduct);
                            }
                            if (!mounted) return;
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Color(0xFFE53935),
                          ),
                          label: const Text(
                            'Hapus Pilihan',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── 2. Merchant & Daftar Produk Riil ──
                  _buildMerchantSection(
                    merchantName: 'Bank Sampah Sahabat Ibu TR4SH',
                    location: 'Jember, Jawa Timur',
                    items: _cartItems,
                  ),

                  const SizedBox(height: 16),

                  // ── 3. Kartu Pilihan Metode Pembayaran ──
                  _buildPaymentMethodSection(),

                  const SizedBox(height: 16),

                  // ── 4. Rincian Pembayaran Murni ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rincian Pembayaran',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow(
                            'Total Harga ($_selectedItemCount Barang)',
                            'Rp ${_formatPrice(_totalPrice)}',
                          ),
                          const SizedBox(height: 8),
                          _buildPriceRow(
                            'Biaya Layanan Aplikasi',
                            'Gratis',
                            isHighlight: true,
                          ),
                          const Divider(height: 20, color: Color(0xFFE2EFE7)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(_totalPrice)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

      // ── 5. Bottom Checkout Bar ──
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      activeColor: AppColors.darkGreen,
                      checkColor: AppColors.limeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: _toggleSelectAll,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Pembayaran:',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(_totalPrice)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: (_selectedItemCount == 0 || _isCheckingOut)
                          ? null
                          : _prosesCheckout,
                      child: _isCheckingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Bayar ($_selectedItemCount)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.limeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Widget Pilihan Pembayaran Native ──
  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: 16,
                  color: AppColors.darkGreen,
                ),
                SizedBox(width: 6),
                Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bungkus kedua pilihan dengan RadioGroup
            RadioGroup<String>(
              groupValue: _selectedMethod,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMethod = val);
                }
              },
              child: Column(
                children: [
                  // Opsi 1: QRIS
                  InkWell(
                    onTap: () => setState(() => _selectedMethod = 'qris'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedMethod == 'qris'
                            ? const Color(0xFFE8F6EE)
                            : AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == 'qris'
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                          width: _selectedMethod == 'qris' ? 1.5 : 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.darkGreen,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QRIS (Instant)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                Text(
                                  'GoPay, ShopeePay, Dana, & Semua M-Banking',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: 'qris',
                            activeColor: AppColors.darkGreen,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Opsi 2: Bank Transfer VA
                  InkWell(
                    onTap: () =>
                        setState(() => _selectedMethod = 'bank_transfer'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedMethod == 'bank_transfer'
                            ? const Color(0xFFE8F6EE)
                            : AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == 'bank_transfer'
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                          width: _selectedMethod == 'bank_transfer' ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_rounded,
                                color: AppColors.darkGreen,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transfer Virtual Account',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    Text(
                                      'BCA, BNI, BRI, Mandiri',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: 'bank_transfer',
                                activeColor: AppColors.darkGreen,
                              ),
                            ],
                          ),

                          // Jika bank_transfer dipilih, tampilkan opsi pilihan bank
                          if (_selectedMethod == 'bank_transfer') ...[
                            const Divider(height: 16, color: Color(0xFFC7E2D1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['bca', 'bni', 'bri', 'mandiri'].map((
                                bank,
                              ) {
                                final isBankActive = _selectedBank == bank;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _selectedBank = bank),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isBankActive
                                          ? AppColors.darkGreen
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    child: Text(
                                      bank.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isBankActive
                                            ? Colors.white
                                            : AppColors.darkGreen,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantSection({
    required String merchantName,
    required String location,
    required List<ItemKeranjangModel> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final bool isMerchantAllSelected = items.every((i) => i.isSelected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isMerchantAllSelected,
                  activeColor: AppColors.darkGreen,
                  checkColor: AppColors.limeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) async {
                    setState(() {
                      for (var item in items) {
                        item.isSelected = val ?? false;
                      }
                    });
                    await CartService.updateItem();
                  },
                ),
                const Icon(
                  Icons.storefront_rounded,
                  size: 16,
                  color: AppColors.darkGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          merchantName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: Color(0xFF1E8850),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgScreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 16, color: Color(0xFFE2EFE7)),
            ...items.map((item) => _buildCartItemTile(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(ItemKeranjangModel item) {
    final int hargaAsli = item.harga;
    final double diskonAktif = item.diskonBerlaku(item.quantity);
    final int hargaFinal = item.hargaFinal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.isSelected,
            activeColor: AppColors.darkGreen,
            checkColor: AppColors.limeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) async {
              setState(() {
                item.isSelected = val ?? false;
              });
              await CartService.updateItem();
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.foto.isNotEmpty
                ? Image.network(
                    item.foto,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 68,
                      height: 68,
                      color: AppColors.mintSoft,
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  )
                : Container(
                    width: 68,
                    height: 68,
                    color: AppColors.mintSoft,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.darkGreen,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.namaProduk,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => _removeItem(item.idProduct),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6EE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Upcycled Material',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E8850),
                        ),
                      ),
                    ),
                    if (diskonAktif > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${diskonAktif.toInt()}% OFF',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp ${_formatPrice(hargaFinal)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        if (diskonAktif > 0)
                          Text(
                            'Rp ${_formatPrice(hargaAsli)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              if (item.quantity > 1) {
                                setState(() => item.quantity--);
                                await CartService.updateItem();
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (item.quantity < item.stokMaksimal) {
                                // [BARU] Cek batas stok
                                setState(() => item.quantity++);
                                await CartService.updateItem();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Maksimal stok tercapai! Sisa stok hanya ${item.stokMaksimal} unit.',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? const Color(0xFF1E8850) : AppColors.darkGreen,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
