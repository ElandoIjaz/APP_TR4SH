import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/akun/halaman_alamat_pengiriman.dart';
import 'package:test23/pages/akun/halaman_bantuan_faq.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/akun/halaman_pengaturan_akun.dart';
import 'package:test23/pages/akun/halaman_poin_hadiah.dart';
import 'package:test23/pages/akun/halaman_riwayat_setor.dart';
import 'package:test23/pages/akun/halaman_riwayat_transaksi.dart';

void main() {
  testWidgets('HalamanAlamatPengiriman and HalamanPilihLokasiAkurat work accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanAlamatPengiriman(),
      ),
    );
    await tester.pump();

    // Verify Title & Header
    expect(find.text('Alamat Pengiriman'), findsWidgets);
    expect(find.text('Penentuan Lokasi Akurat via GPS'), findsOneWidget);

    // Verify existing dummy address cards
    expect(find.text('Rumah'), findsOneWidget);
    expect(find.text('Kantor'), findsOneWidget);
    expect(find.text('Utama'), findsOneWidget);

    // Verify accuracy badge
    expect(find.textContaining('Titik GPS:'), findsWidgets);

    // Test tapping Tambah Alamat Baru
    await tester.tap(find.text('Tambah Alamat Baru (GPS Akurat)'));
    await tester.pumpAndSettle();

    // Now in HalamanPilihLokasiAkurat
    expect(find.text('Tentukan Lokasi Akurat'), findsOneWidget);
    expect(find.textContaining('Titik Pin Presisi:'), findsOneWidget);
    expect(find.text('Kunci GPS Saya'), findsOneWidget);

    // Test locking GPS
    await tester.tap(find.text('Kunci GPS Saya'));
    await tester.pumpAndSettle();

    // Drag to scroll form into view
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Select label chip 'Apartemen'
    await tester.tap(find.text('Apartemen'));
    await tester.pump();

    // Scroll to Simpan button and tap
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Lokasi Akurat'));
    await tester.pumpAndSettle();

    // Returned to address list
    expect(find.text('Alamat Pengiriman'), findsWidgets);
  });

  testWidgets('HalamanRiwayatTransaksi renders and filters orders',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanRiwayatTransaksi(),
      ),
    );
    await tester.pump();

    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Dikirim'), findsWidgets);
    expect(find.text('Selesai'), findsWidgets);
    expect(find.text('Dibatalkan'), findsOneWidget);

    // Verify order items
    expect(find.text('Pot Bunga dari Botol Plastik Daur Ulang'), findsWidgets);
    expect(find.text('Lacak'), findsWidgets);

    // Tap Lacak opens tracking modal
    await tester.tap(find.text('Lacak').first);
    await tester.pumpAndSettle();

    expect(find.text('Pelacakan Ekspedisi Kurir'), findsOneWidget);
    expect(find.textContaining('Kurir Ramah Lingkungan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('HalamanRiwayatSetor renders metrics and waste history',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanRiwayatSetor(),
      ),
    );
    await tester.pump();

    expect(find.text('Riwayat Setor Sampah'), findsOneWidget);
    expect(find.text('14.8 kg'), findsOneWidget);
    expect(find.text('+1.900'), findsOneWidget);
    expect(find.text('23.0 kg'), findsOneWidget);

    // Verify deposit items
    expect(find.text('Botol Plastik PET'), findsOneWidget);
    expect(find.text('Kardus & Kertas Bekas'), findsOneWidget);
    expect(find.text('+630 Poin'), findsOneWidget);
    expect(find.text('Setor Sampah Sekarang'), findsOneWidget);
  });

  testWidgets('HalamanPoinHadiah allows reward redemption',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanPoinHadiah(),
      ),
    );
    await tester.pump();

    expect(find.text('Poin & Hadiah'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('Eco Guardian Tier 2'), findsOneWidget);

    // Verify rewards
    expect(find.text('Voucher Belanja Eco Rp 20.000'), findsOneWidget);
    expect(find.text('Tote Bag Sirkular Eksklusif'), findsOneWidget);

    // Test redeeming reward
    await tester.tap(find.text('Tukarkan Sekarang').first);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Penukaran'), findsOneWidget);
    expect(find.text('Tukarkan'), findsOneWidget);

    await tester.tap(find.text('Tukarkan'));
    await tester.pumpAndSettle();

    // Points reduced from 500 to 300
    expect(find.text('300'), findsOneWidget);
  });

  testWidgets('HalamanNotifikasi renders notifications and handles marking read',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanNotifikasi(),
      ),
    );
    await tester.pump();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);
    expect(find.text('Setor Sampah'), findsOneWidget);
    expect(find.text('Info & Promo'), findsOneWidget);

    expect(find.text('Penyetoran Sampah 4.2 kg Terverifikasi'), findsOneWidget);

    // Tap Tandai Semua Dibaca via icon
    await tester.tap(find.byIcon(Icons.done_all_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Semua notifikasi ditandai telah dibaca'), findsOneWidget);
  });

  testWidgets('HalamanBantuanFaq renders search and expandable FAQs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanBantuanFaq(),
      ),
    );
    await tester.pump();

    expect(find.text('Bantuan & FAQ'), findsOneWidget);
    expect(find.text('Cari pertanyaan atau kendala Anda...'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Setor Sampah'), findsOneWidget);

    // Expand FAQ
    expect(find.text('Bagaimana cara menyetor sampah di TR4SH!?'), findsOneWidget);
    await tester.tap(find.text('Bagaimana cara menyetor sampah di TR4SH!?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Setor Mandiri'), findsOneWidget);
  });

  testWidgets('HalamanPengaturanAkun toggles settings and opens modal',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanPengaturanAkun(),
      ),
    );
    await tester.pump();

    expect(find.text('Pengaturan Akun'), findsOneWidget);
    expect(find.text('Ubah Kata Sandi'), findsOneWidget);
    expect(find.text('PIN Transaksi & Dompet'), findsOneWidget);
    expect(find.text('Notifikasi Sampah & Poin'), findsOneWidget);

    // Open Ubah Kata Sandi modal
    await tester.tap(find.text('Ubah Kata Sandi'));
    await tester.pumpAndSettle();

    expect(find.text('Kata Sandi Saat Ini'), findsOneWidget);
    expect(find.text('Kata Sandi Baru'), findsOneWidget);
    expect(find.text('Konfirmasi Kata Sandi Baru'), findsOneWidget);
    // Verified: No fingerprint used, pure text password security
    expect(find.textContaining('tanpa sidik jari'), findsWidgets);
    expect(find.text('Simpan Perubahan'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
  });

  testWidgets('HalamanAkun navigates correctly to all 7 subpages',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanAkun(),
      ),
    );
    await tester.pump();

    // 1. Riwayat Transaksi
    await tester.scrollUntilVisible(find.text('Riwayat Transaksi'), 150);
    await tester.tap(find.text('Riwayat Transaksi'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanRiwayatTransaksi), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 2. Riwayat Setor Sampah
    await tester.scrollUntilVisible(find.text('Riwayat Setor Sampah'), 150);
    await tester.tap(find.text('Riwayat Setor Sampah'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanRiwayatSetor), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 3. Poin & Hadiah
    await tester.scrollUntilVisible(find.text('Poin & Hadiah'), 150);
    await tester.tap(find.text('Poin & Hadiah'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanPoinHadiah), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 4. Alamat Pengiriman
    await tester.scrollUntilVisible(find.text('Alamat Pengiriman'), 150);
    await tester.tap(find.text('Alamat Pengiriman'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanAlamatPengiriman), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 5. Notifikasi
    await tester.scrollUntilVisible(find.text('Notifikasi'), 150);
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanNotifikasi), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 6. Bantuan & FAQ
    await tester.scrollUntilVisible(find.text('Bantuan & FAQ'), 150);
    await tester.tap(find.text('Bantuan & FAQ'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanBantuanFaq), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 7. Pengaturan Akun
    await tester.scrollUntilVisible(find.text('Pengaturan Akun'), 150);
    await tester.tap(find.text('Pengaturan Akun'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanPengaturanAkun), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
  });
}
