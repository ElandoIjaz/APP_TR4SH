import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/pages/produk/halaman_detail_produk.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/pages/produk/halaman_produk.dart';

void main() {
  testWidgets('HalamanProduk, Detail, Filter, and Keranjang work seamlessly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    // ── 1. Test HalamanProduk Catalog Page ──
    await tester.pumpWidget(const MaterialApp(home: HalamanProduk()));
    await tester.pump();

    // Verify Branding & Header
    expect(find.text('TR4SH!'), findsOneWidget);
    expect(find.text('ECO MARKETPLACE'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);

    // Verify Search & Categories
    expect(find.text('Cari produk daur ulang & upcycle...'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Dekorasi Rumah'), findsOneWidget);
    expect(find.text('Fashion Upcycle'), findsOneWidget);

    // Verify Hero Banner
    expect(find.text('1.200+ kg sampah terdaur ulang'), findsOneWidget);
    expect(find.text('Karya Daur Ulang Penuh Makna'), findsOneWidget);
    expect(find.text('Jelajahi Sekarang'), findsOneWidget);

    // Verify Catalog Products
    expect(find.text('Produk Pilihan'), findsOneWidget);
    expect(
      find.text('Pot Bunga dari Botol Plastik Daur Ulang'),
      findsOneWidget,
    );
    expect(find.text('Lampu Hias dari Limbah Botol'), findsOneWidget);
    expect(find.text('Tas Tote dari Karung Bekas'), findsOneWidget);
    expect(find.text('Tempat Pensil dari Kardus Bekas'), findsOneWidget);

    // Verify Bottom CTA & Nav
    expect(find.text('Kirim Sampah Anda'), findsOneWidget);
    expect(find.text('Setor Sekarang'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);

    // ── 2. Test Filter Modal Sheet ──
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filter Produk'), findsOneWidget);
    expect(find.text('MULTI-PILIHAN'), findsOneWidget);
    expect(find.text('Plastik Didaur Ulang'), findsOneWidget);
    expect(find.text('Kain / Karung Bekas'), findsOneWidget);
    expect(find.text('Terapkan Filter'), findsOneWidget);

    await tester.tap(find.text('Terapkan Filter'));
    await tester.pumpAndSettle();

    // ── 3. Test Detail Produk Page ──
    await tester.tap(find.text('Pot Bunga dari Botol Plastik Daur Ulang'));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanDetailProduk), findsOneWidget);
    expect(find.text('Detail Produk'), findsOneWidget);
    expect(find.text('Rp 35.000'), findsWidgets);
    expect(find.text('22% OFF'), findsOneWidget);
    expect(find.text('Dampak Lingkungan Produk Ini'), findsOneWidget);
    expect(find.text('250g'), findsOneWidget);
    expect(find.text('-420g'), findsOneWidget);
    expect(find.text('Karya Mandiri Eco Cr...'), findsOneWidget);
    expect(find.text('Spesifikasi Produk'), findsOneWidget);
    expect(find.text('Ulasan Pembeli'), findsOneWidget);
    expect(find.text('Anindya Putri'), findsOneWidget);
    expect(find.text('Beli Sekarang'), findsOneWidget);

    // ── 4. Test Cart Page (Conscious Cart) ──
    await tester.tap(find.text('Beli Sekarang'));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanKeranjang), findsOneWidget);
    expect(find.text('TR4SH 2.0 CONSCIOUS CART'), findsOneWidget);
    expect(find.text('Dampak Ekologis\nKeranjangmu'), findsOneWidget);
    expect(find.text('88% Tercapai'), findsOneWidget);
    expect(find.text('Karya Mandiri Eco'), findsOneWidget);
    expect(find.text('Pot Bunga Daur Ulang - Sage Green'), findsOneWidget);
    expect(find.text('Tempat Pensil Geometris'), findsOneWidget);
    expect(find.text('Re-Craft Studio'), findsOneWidget);
    expect(find.text('Tas Tote Canvas Karung Vintage'), findsOneWidget);
    expect(find.text('Voucher & Keberlanjutan'), findsOneWidget);
    expect(find.text('ECOHERO-20K'), findsOneWidget);
    expect(find.text('Rincian Pembayaran'), findsOneWidget);
    expect(find.text('Subtotal Pesanan'), findsOneWidget);
    expect(find.text('Checkout (4)'), findsOneWidget);
  });
}
