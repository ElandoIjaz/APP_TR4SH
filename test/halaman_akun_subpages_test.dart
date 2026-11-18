import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/akun/halaman_bantuan_faq.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/akun/halaman_pengaturan_akun.dart';
import 'package:test23/pages/akun/halaman_riwayat_setor.dart';
import 'package:test23/pages/akun/halaman_riwayat_transaksi.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserAccountData.isGuest = false;
    UserAccountData.isNewAccount = false;
    UserAccountData.currentUserId = null;
    UserAccountData.currentNama = 'Bintang Pratama';
    UserAccountData.currentUsername = 'bintang_eco';
    UserAccountData.totalSampahKg = 0.0;
    UserAccountData.totalSetoran = 0;
    UserAccountData.listRiwayatSetor = [];
    UserAccountData.listTransaksi = [];
  });

  testWidgets('HalamanRiwayatTransaksi renders header and status filters', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HalamanRiwayatTransaksi()));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Menunggu Pembayaran'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('Dibatalkan'), findsOneWidget);
  });

  testWidgets('HalamanRiwayatSetor renders metrics and empty state cleanly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HalamanRiwayatSetor()));
    await tester.pump();

    expect(find.text('Riwayat Setor Sampah'), findsOneWidget);
    expect(find.text('14.8 kg'), findsOneWidget);
    expect(find.text('+1.900'), findsOneWidget);
    expect(find.text('23.0 kg'), findsOneWidget);
    expect(find.text('Belum ada riwayat setoran sampah'), findsOneWidget);
    expect(find.text('Setor Sampah Sekarang'), findsOneWidget);
  });

  testWidgets(
    'HalamanNotifikasi renders filter tabs and handles empty offline state',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: HalamanNotifikasi()));
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.text('Setor Sampah'), findsOneWidget);
      expect(find.text('Info & Promo'), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    },
  );

  testWidgets('HalamanBantuanFaq renders search and expandable FAQs', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HalamanBantuanFaq()));
    await tester.pump();

    expect(find.text('Bantuan & FAQ'), findsOneWidget);
    expect(find.text('Cari pertanyaan atau kendala Anda...'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Setor Sampah'), findsOneWidget);

    // Expand FAQ
    expect(
      find.text('Bagaimana cara menyetor sampah di TR4SH!?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Bagaimana cara menyetor sampah di TR4SH!?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Setor Mandiri'), findsOneWidget);
  });

  testWidgets('HalamanPengaturanAkun toggles settings and opens modal', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HalamanPengaturanAkun()));
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

  testWidgets('HalamanAkun navigates correctly to all 6 subpages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HalamanAkun()));
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

    // 3. Konten Edukasi Saya
    await tester.scrollUntilVisible(find.text('Konten Edukasi Saya'), 150);
    await tester.tap(find.text('Konten Edukasi Saya'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanUploadKonten), findsOneWidget);
    Navigator.of(tester.element(find.byType(HalamanUploadKonten))).pop();
    await tester.pumpAndSettle();

    // 4. Notifikasi
    await tester.scrollUntilVisible(find.text('Notifikasi'), 150);
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanNotifikasi), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 5. Bantuan & FAQ
    await tester.scrollUntilVisible(find.text('Bantuan & FAQ'), 150);
    await tester.tap(find.text('Bantuan & FAQ'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanBantuanFaq), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 6. Pengaturan Akun
    await tester.scrollUntilVisible(find.text('Pengaturan Akun'), 150);
    await tester.tap(find.text('Pengaturan Akun'));
    await tester.pumpAndSettle();
    expect(find.byType(HalamanPengaturanAkun), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
  });
}
