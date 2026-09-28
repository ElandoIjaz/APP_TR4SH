import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/produk_data.dart';

class HalamanKeranjang extends StatefulWidget {
  const HalamanKeranjang({super.key});

  @override
  State<HalamanKeranjang> createState() => _HalamanKeranjangState();
}

class _HalamanKeranjangState extends State<HalamanKeranjang> {
  late List<ItemKeranjang> _cartItems;
  bool _isVoucherApplied = true;
  final TextEditingController _voucherController =
      TextEditingController(text: 'ECOHERO-20K');

  @override
  void initState() {
    super.initState();
    _cartItems = ProdukData.getInitialCart();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  bool get _isAllSelected =>
      _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);

  int get _selectedItemCount =>
      _cartItems.where((item) => item.isSelected).fold(0, (sum, item) => sum + item.quantity);

  int get _totalPrice => _cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  int get _discount => _isVoucherApplied ? 20000 : 0;

  int get _finalTotal => (_totalPrice - _discount).clamp(0, double.infinity).toInt();

  void _toggleSelectAll(bool? value) {
    final bool select = value ?? false;
    setState(() {
      for (var item in _cartItems) {
        item.isSelected = select;
      }
    });
  }

  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Keranjang belanja dikosongkan')),
    );
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
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 20),
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF1E8850)),
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
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.darkGreen),
            onPressed: _cartItems.isEmpty ? null : _clearCart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('Keranjang belanja Anda kosong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
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
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  // ── 1. Dampak Ekologis Keranjangmu Card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D4330),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.limeAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.eco_rounded, size: 14, color: AppColors.darkGreen),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Dampak Ekologis\nKeranjangmu',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.limeAccent.withValues(alpha: 0.4)),
                                ),
                                child: const Text(
                                  'Verified\nEco',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.limeAccent,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
                              children: [
                                TextSpan(text: 'Belanjaan ini menyelamatkan '),
                                TextSpan(
                                  text: '880g limbah',
                                  style: TextStyle(color: AppColors.limeAccent, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' & mencegah '),
                                TextSpan(
                                  text: '1.2kg emisi CO2',
                                  style: TextStyle(color: AppColors.limeAccent, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' dari tempat pembuangan akhir!'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Target Batch Pengolahan: 1.0kg',
                                style: TextStyle(fontSize: 10, color: Colors.white60),
                              ),
                              Text(
                                '88% Tercapai',
                                style: TextStyle(fontSize: 10, color: AppColors.limeAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: 0.88,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.limeAccent),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 2. Select All & Delete Action ──
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: _toggleSelectAll,
                            ),
                            Flexible(
                              child: Text(
                                'Pilih Semua ($_selectedItemCount item)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _cartItems.removeWhere((item) => item.isSelected);
                            });
                          },
                          icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFE53935)),
                          label: const Text(
                            'Hapus Pilihan',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFFE53935), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── 3. Merchant Group 1: Karya Mandiri Eco ──
                  _buildMerchantSection(
                    merchantName: 'Karya Mandiri Eco',
                    location: 'Bandung',
                    items: _cartItems.where((i) => i.id == 'cart-1' || i.id == 'cart-2').toList(),
                  ),

                  const SizedBox(height: 14),

                  // ── 4. Merchant Group 2: Re-Craft Studio ──
                  _buildMerchantSection(
                    merchantName: 'Re-Craft Studio',
                    location: 'Yogyakarta',
                    items: _cartItems.where((i) => i.id == 'cart-3').toList(),
                  ),

                  const SizedBox(height: 16),

                  // ── 5. Voucher & Keberlanjutan ──
                  Padding(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.confirmation_number_outlined, size: 16, color: AppColors.darkGreen),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Voucher & Keberlanjutan',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '1 Kupon Tersedia',
                                style: TextStyle(fontSize: 10, color: Color(0xFF1E8850), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgScreen,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sell_outlined, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _voucherController,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            hintText: 'Masukkan kode voucher',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.limeAccent,
                                  foregroundColor: AppColors.darkGreen,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isVoucherApplied = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Voucher ECOHERO-20K berhasil digunakan!'),
                                      backgroundColor: AppColors.darkGreen,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Gunakan',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          if (_isVoucherApplied) ...[
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF1E8850)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Voucher ECOHERO-20K aktif! Diskon Rp 20.000 berhasil dipotong.',
                                    style: TextStyle(fontSize: 10.5, color: Color(0xFF1E8850), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 6. Rincian Pembayaran ──
                  Padding(
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
                          const Text(
                            'Rincian Pembayaran',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow('Total Harga ($_selectedItemCount Barang)', 'Rp ${_formatPrice(_totalPrice)}'),
                          const SizedBox(height: 8),
                          if (_isVoucherApplied) ...[
                            _buildPriceRow('Diskon Voucher Eco', '- Rp ${_formatPrice(_discount)}', isDiscount: true),
                            const SizedBox(height: 8),
                          ],
                          _buildPriceRow('Biaya Proteksi Daur Ulang', 'Gratis', isHighlight: true),
                          const Divider(height: 20, color: Color(0xFFE2EFE7)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal Pesanan',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                              ),
                              Text(
                                'Rp ${_formatPrice(_finalTotal)}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
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

      // ── 7. Bottom Checkout Bar ──
      bottomNavigationBar: Container(
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: _toggleSelectAll,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Total: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text(
                        'Rp ${_formatPrice(_finalTotal)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
                      ),
                    ],
                  ),
                  if (_discount > 0)
                    Text(
                      'Hemat Rp ${_formatPrice(_discount)}',
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF1E8850), fontWeight: FontWeight.w700),
                    ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: _selectedItemCount == 0
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Melanjutkan ke pembayaran Rp ${_formatPrice(_finalTotal)}...'),
                            backgroundColor: AppColors.darkGreen,
                          ),
                        );
                      },
                child: Row(
                  children: [
                    Text(
                      'Checkout ($_selectedItemCount)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.limeAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.darkGreen),
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

  Widget _buildMerchantSection({
    required String merchantName,
    required String location,
    required List<ItemKeranjang> items,
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
            // Merchant Header
            Row(
              children: [
                Checkbox(
                  value: isMerchantAllSelected,
                  activeColor: AppColors.darkGreen,
                  checkColor: AppColors.limeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    setState(() {
                      for (var item in items) {
                        item.isSelected = val ?? false;
                      }
                    });
                  },
                ),
                const Icon(Icons.storefront_rounded, size: 16, color: AppColors.darkGreen),
                const SizedBox(width: 6),
                Text(
                  merchantName,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF1E8850)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.bgScreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const Divider(height: 16, color: Color(0xFFE2EFE7)),

            // Cart Items
            ...items.map((item) => _buildCartItemTile(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(ItemKeranjang item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.isSelected,
            activeColor: AppColors.darkGreen,
            checkColor: AppColors.limeAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              setState(() {
                item.isSelected = val ?? false;
              });
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.product.image,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 68,
                height: 68,
                color: AppColors.mintSoft,
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.darkGreen),
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
                        item.variant,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => _removeItem(item.id),
                      child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.materialBadge,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E8850)),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${_formatPrice(item.product.price)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (item.quantity > 1) {
                                setState(() => item.quantity--);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Text('-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() => item.quantity++);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Text('+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
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

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isHighlight = false}) {
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
            fontWeight: isDiscount || isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isDiscount || isHighlight ? const Color(0xFF1E8850) : AppColors.darkGreen,
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
