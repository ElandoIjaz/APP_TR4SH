import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/main.dart';
import 'package:test23/pages/auth/auth_gate.dart';
import 'package:test23/pages/auth/halaman_daftar.dart';
import 'package:test23/pages/auth/halaman_login.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Aplikasi wajib login terlebih dahulu saat pertama kali dibuka (AuthGate -> HalamanLogin)', (WidgetTester tester) async {
    // Jalankan aplikasi default tanpa session
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Pastikan user melihat halaman Masuk Akun / Login
    expect(find.byType(HalamanLogin), findsOneWidget);
    expect(find.text('Masuk Akun'), findsAtLeast(1));
    expect(find.text('Username atau No. Telepon'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Belum punya akun?  '), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
  });

  testWidgets('Navigasi dari HalamanLogin ke HalamanDaftar dan sebaliknya berjalan lancar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi ada di halaman login
    expect(find.byType(HalamanLogin), findsOneWidget);

    // Tap 'Daftar Sekarang'
    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();

    // Verifikasi masuk ke HalamanDaftar
    expect(find.byType(HalamanDaftar), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('No. Telepon / WhatsApp'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Sudah punya akun?  '), findsOneWidget);

    // Tap back button pada AppBar halaman daftar untuk kembali ke login
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(HalamanLogin), findsOneWidget);
  });

  testWidgets('AuthGate otomatis masuk ke HalamanBeranda jika sudah memiliki token sesi aktif', (WidgetTester tester) async {
    // Siapkan mock shared preferences dengan token login tersimpan
    SharedPreferences.setMockInitialValues({
      'auth_token_sanctum': 'test_bearer_token_xyz',
      'auth_user_json': '{"id_user": 1, "username": "bintang_eco", "nama_lengkap": "Bintang Pratama"}',
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Karena sudah login, otomatis masuk ke Beranda
    expect(find.text('Halo, Bintang 👋'), findsOneWidget);
    expect(find.text('TR4SH!'), findsOneWidget);
  });
}
