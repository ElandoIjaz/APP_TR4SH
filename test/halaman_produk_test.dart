import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/produk/halaman_keranjang.dart';
import 'package:test23/pages/produk/halaman_produk.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserAccountData.isGuest = false;
  });

  testWidgets('HalamanProduk renders header, categories, offline state, and navigates to Keranjang', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HalamanProduk()));
    await tester.pumpAndSettle();

    // Verify Branding & Header
    expect(find.text('TR4SH!'), findsOneWidget);
    expect(find.text('ECO MARKETPLACE'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);

    // Verify Search & Categories
    expect(find.text('Cari produk daur ulang & upcycle...'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Dekorasi Rumah'), findsOneWidget);
    expect(find.text('Fashion Upcycle'), findsOneWidget);

    // Verify Section Title & Offline API Fallback UI
    expect(find.text('Produk Pilihan'), findsOneWidget);
    expect(find.text('Ups, koneksi terputus!'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    // Verify Bottom CTA Banner
    expect(find.text('Kirim Sampah Anda'), findsOneWidget);
    expect(find.text('Setor Sekarang'), findsOneWidget);

    // Tap Cart Icon opens HalamanKeranjang
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byType(HalamanKeranjang), findsOneWidget);
  });
}
