import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/main.dart';
import 'package:test23/pages/auth/halaman_daftar.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/konten/halaman_konten.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Pengguna bisa langsung menggunakan aplikasi tanpa login (langsung masuk ke HalamanBeranda)',
      (WidgetTester tester) async {
    // Jalankan aplikasi default tanpa session login
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Pastikan user langsung masuk ke Beranda (dapat langsung menggunakan aplikasi)
    expect(find.byType(HalamanBeranda), findsOneWidget);
    expect(find.text('TR4SH!'), findsOneWidget);
    expect(find.text('Bank Sampah Digital'), findsOneWidget);
    expect(find.text('Halo, Tamu 👋'), findsOneWidget);
    expect(UserAccountData.isGuest, isTrue);
  });

  testWidgets('Tamu tidak bisa melakukan tracking sampah (Mulai Setor & Bottom Nav Tracking terkunci)',
      (WidgetTester tester) async {
    UserAccountData.setGuestMode();

    await tester.pumpWidget(const MyApp(initialHome: HalamanBeranda()));
    await tester.pumpAndSettle();

    // 1. Coba tekan tombol "Mulai Setor" pada kartu Bank Sampah Digital
    await tester.tap(find.text('Mulai Setor'));
    await tester.pumpAndSettle();

    // Harus memunculkan modal peringatan bahwa setor sampah memerlukan akun
    expect(find.text('Fitur Setor Sampah Memerlukan Akun'), findsOneWidget);
    expect(find.text('Masuk / Daftar Akun'), findsOneWidget);

    // Tutup modal
    await tester.tap(find.text('Lanjutkan Jelajahi Aplikasi'));
    await tester.pumpAndSettle();

    // 2. Coba tekan tab 'Tracking' pada Bottom Navigation Bar
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();

    // Harus memunculkan modal peringatan bahwa tracking memerlukan akun
    expect(find.text('Fitur Tracking Sampah Memerlukan Akun'), findsOneWidget);
    expect(find.text('Masuk / Daftar Akun'), findsOneWidget);
  });

  testWidgets('Tamu tidak bisa upload konten edukasi (Upload Konten di HalamanKonten terkunci)',
      (WidgetTester tester) async {
    UserAccountData.setGuestMode();

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanKonten(),
      ),
    );
    await tester.pumpAndSettle();

    // Tekan tombol FloatingActionButton "Upload Konten"
    await tester.tap(find.text('Upload Konten'));
    await tester.pumpAndSettle();

    // Harus memunculkan modal bahwa upload konten memerlukan akun
    expect(find.text('Upload Konten Memerlukan Akun'), findsOneWidget);
    expect(find.text('Masuk / Daftar Akun'), findsOneWidget);
  });

  testWidgets('Navigasi ke HalamanLogin dan HalamanDaftar bekerja lancar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanLogin(),
      ),
    );
    await tester.pumpAndSettle();

    // Pastikan user melihat form login
    expect(find.text('Masuk Akun'), findsAtLeast(1));
    expect(find.text('Daftar Sekarang'), findsOneWidget);

    // Tap 'Daftar Sekarang'
    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();

    // Verifikasi masuk ke HalamanDaftar
    expect(find.byType(HalamanDaftar), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);

    // Tap back button pada AppBar halaman daftar untuk kembali ke login
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanLogin), findsOneWidget);
  });
}
