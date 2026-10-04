import 'package:flutter_test/flutter_test.dart';
import 'package:test23/main.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';

void main() {
  testWidgets('HalamanBeranda renders correctly with all widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialHome: HalamanBeranda()));
    await tester.pump();

    // Verify Header and Branding
    expect(find.text('TR4SH!'), findsOneWidget);
    expect(find.text('SELAMAT PAGI'), findsOneWidget);
    expect(find.text('Halo, Bintang 👋'), findsOneWidget);
    expect(find.text('PROFILE ANDA'), findsOneWidget);

    // Verify Hero Card
    expect(find.text('Bank Sampah Digital'), findsOneWidget);
    expect(find.text('Setor Sampah Jadi Berkah'), findsOneWidget);
    expect(find.text('Mulai Setor'), findsOneWidget);
    expect(find.text('+150 Poin/kg'), findsOneWidget);

    // Verify Riwayat Setor Sampah & Chart stats
    expect(find.text('RIWAYAT SETOR SAMPAH'), findsOneWidget);
    expect(find.text('14.8'), findsOneWidget);
    expect(find.text('Target: 20 kg'), findsOneWidget);
    expect(find.text('Botol Plastik'), findsOneWidget);
    expect(find.text('Kertas Bekas'), findsOneWidget);

    // Verify Cara Menabung Sampah & Video Card
    expect(find.text('Cara Menabung Sampah'), findsOneWidget);
    expect(find.text('Panduan Pilah Sampah Rumah Tangga'), findsOneWidget);
    expect(find.text('03:40 min'), findsOneWidget);

    // Verify Kenali Jenis Sampah
    expect(find.text('Kenali Jenis Sampah'), findsOneWidget);
    expect(find.text('Plastik'), findsOneWidget);
    expect(find.text('Kaca'), findsOneWidget);
    expect(find.text('Kertas & Karton'), findsOneWidget);
    expect(find.text('Logam / Kaleng'), findsOneWidget);

    // Verify Workshop Card
    expect(find.text('Daftar Workshop'), findsOneWidget);

    // Verify Bottom Navigation Items
    expect(find.text('Konten'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);

    // Test tapping Mulai Setor opens Setor Sampah bottom sheet
    await tester.tap(find.text('Mulai Setor'));
    await tester.pumpAndSettle();
    expect(find.text('Setor Sampah Mandiri'), findsOneWidget);
    expect(find.text('Buat Jadwal Penjemputan'), findsOneWidget);

    // Dismiss bottom sheet
    await tester.tap(find.text('Buat Jadwal Penjemputan'));
    await tester.pumpAndSettle();

    // Test tapping Kenali Jenis Sampah category (Plastik)
    await tester.scrollUntilVisible(find.text('Plastik'), 200);
    await tester.tap(find.text('Plastik'));
    await tester.pumpAndSettle();
    expect(find.text('Mengerti & Kembali'), findsOneWidget);
    await tester.tap(find.text('Mengerti & Kembali'));
    await tester.pumpAndSettle();

    // Test navigating to HalamanAkun via bottom nav 'Akun'
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();

    // Verify HalamanAkun Profile elements
    expect(find.text('Bintang Pratama'), findsOneWidget);
    expect(find.text('@bintang_eco'), findsOneWidget);
    expect(find.text('Anggota Aktif'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);

    // Verify Stats
    expect(find.text('12.5 kg'), findsOneWidget);
    expect(find.text('5 Poin'), findsOneWidget);
    expect(find.text('3 Misi'), findsOneWidget);

    // Verify Impact Banner
    expect(find.text('DAMPAK POSITIFMU'), findsOneWidget);
    expect(find.text('Total 12.5 kg sampah berhasil dikurangi dari TPA'), findsOneWidget);
    expect(find.text('Setara 18.2 kg reduksi CO2e'), findsOneWidget);

    // Verify Menu List
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Riwayat Setor Sampah'), findsOneWidget);
    expect(find.text('Poin & Hadiah'), findsOneWidget);
    expect(find.text('500 Pts'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Bantuan & FAQ'), findsOneWidget);
    expect(find.text('Pengaturan Akun'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    // Test navigating back to Beranda from HalamanAkun
    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Bintang 👋'), findsOneWidget);

    // Test navigating to HalamanTracking via bottom nav 'Tracking'
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();

    // Verify HalamanTracking elements
    expect(find.text('Tren setoran limbah daur ulangmu'), findsOneWidget);
    expect(find.text('+28% dari minggu lalu'), findsOneWidget);
    expect(find.text('ESTIMASI JUMLAH / BERAT'), findsOneWidget);
    expect(find.text('Auto-Converted'), findsOneWidget);
    expect(find.text('5 Botol (±0.5 kg)'), findsOneWidget);
    expect(find.text('5 Item'), findsOneWidget);
    expect(find.text('+ Input Sampah'), findsOneWidget);
    expect(find.text('Pilih kategori setor'), findsOneWidget);

    // Test tapping + Input Sampah opens confirmation
    await tester.scrollUntilVisible(find.text('+ Input Sampah'), 200);
    await tester.tap(find.text('+ Input Sampah'));
    await tester.pumpAndSettle();
    expect(find.text('Sampah Berhasil Diinput!'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    // Test navigating to HalamanKonten via bottom nav 'Konten'
    await tester.tap(find.text('Konten'));
    await tester.pumpAndSettle();

    // Verify HalamanKonten elements
    expect(find.text('SOROTAN UTAMA'), findsOneWidget);
    expect(find.text('Wawasan Komunitas'), findsOneWidget);

    // Test navigating to HalamanProduk via bottom nav 'Produk'
    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();

    // Verify HalamanProduk elements
    expect(find.text('ECO MARKETPLACE'), findsOneWidget);
    expect(find.text('Karya Daur Ulang Penuh Makna'), findsOneWidget);
    expect(find.text('Pot Bunga dari Botol Plastik Daur Ulang'), findsOneWidget);
  });
}
