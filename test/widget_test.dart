import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/main.dart';
import 'package:test23/pages/main_navigation.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserAccountData.isGuest = false;
    UserAccountData.isNewAccount = false;
    UserAccountData.currentUserId = null;
    UserAccountData.currentNama = 'Bintang Pratama';
    UserAccountData.currentUsername = 'bintang_eco';
    UserAccountData.totalSampahKg = 12.5;
    UserAccountData.totalSetoran = 3;
  });

  testWidgets('MainNavigationPage renders Beranda and navigates across tabs', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp(initialHome: MainNavigationPage()));
    await tester.pumpAndSettle();

    // Verify Beranda Header and Branding
    expect(find.text('TR4SH!'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);

    // Verify Hero Card
    expect(find.text('Bank Sampah Digital'), findsOneWidget);
    expect(find.text('Setor Sampah Jadi Berkah'), findsOneWidget);
    expect(find.text('Mulai Setor'), findsOneWidget);
    expect(find.text('Cari Cabang'), findsOneWidget);

    // Verify Riwayat Setor Sampah
    expect(find.text('RIWAYAT SETOR SAMPAH'), findsOneWidget);

    // Verify Cara Menabung Sampah & Video Card
    expect(find.text('Cara Menabung Sampah'), findsOneWidget);
    expect(find.text('Panduan Pilah Sampah Rumah Tangga'), findsOneWidget);

    // Verify Pilih Jenis Sampah
    expect(find.text('Pilih Jenis Sampah'), findsOneWidget);
    expect(find.text('Plastik'), findsOneWidget);
    expect(find.text('Kaca'), findsOneWidget);
    expect(find.text('Kertas & Karton'), findsOneWidget);
    expect(find.text('Logam / Kaleng'), findsOneWidget);

    // Verify Workshop Card
    expect(find.text('Daftar Workshop'), findsOneWidget);

    // Verify Bottom Navigation Items
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Konten'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);

    // Test tapping Pilih Jenis Sampah category (Plastik)
    await tester.scrollUntilVisible(
      find.text('Plastik'),
      200,
      scrollable: find.descendant(
        of: find.byType(SingleChildScrollView).first,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Plastik'));
    await tester.pumpAndSettle();
    expect(find.text('Mengerti & Kembali'), findsOneWidget);
    await tester.tap(find.text('Mengerti & Kembali'));
    await tester.pumpAndSettle();

    // Test navigating to HalamanAkun via bottom nav 'Akun'
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();

    // Verify HalamanAkun Profile & Stats elements
    expect(find.text('Bintang Pratama'), findsOneWidget);
    expect(find.text('@bintang_eco'), findsOneWidget);
    expect(find.text('Anggota Aktif'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('3 Kali'), findsOneWidget);
    expect(find.text('12.5 kg'), findsOneWidget);
    expect(find.text('DAMPAK POSITIFMU'), findsOneWidget);

    // Verify Menu List
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Riwayat Setor Sampah'), findsOneWidget);
    expect(find.text('Konten Edukasi Saya'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Bantuan & FAQ'), findsOneWidget);
    expect(find.text('Pengaturan Akun'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    // Test navigating to HalamanKonten via bottom nav 'Konten'
    await tester.tap(find.text('Konten'));
    await tester.pumpAndSettle();
    expect(find.text('SOROTAN UTAMA'), findsOneWidget);
    expect(find.text('Wawasan Komunitas'), findsOneWidget);

    // Test navigating to HalamanProduk via bottom nav 'Produk'
    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();
    expect(find.text('ECO MARKETPLACE'), findsOneWidget);
    expect(find.text('Produk Pilihan'), findsOneWidget);

    // Test navigating to HalamanTracking via bottom nav 'Tracking'
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Setor Sampah'), findsOneWidget);
  });
}
