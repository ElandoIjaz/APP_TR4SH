import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/pages/konten/halaman_konten.dart';

void main() {
  testWidgets('HalamanKonten renders correctly with all elements from design', (WidgetTester tester) async {
    // Provide a standard phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanKonten(),
      ),
    );
    await tester.pump();

    // 1. Verify Header Branding & Icons
    expect(find.text('TR4SH!'), findsOneWidget);
    expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline_rounded), findsWidgets);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // 2. Verify Search Bar & Filter
    expect(find.text('Cari artikel, tips, atau komunitas...'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

    // 3. Verify Category Tabs
    expect(find.text('Konten Terbaru'), findsOneWidget);
    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Kategori Daur Ulang'), findsOneWidget);

    // 4. Verify Sorotan Utama Card
    expect(find.text('SOROTAN UTAMA'), findsOneWidget);
    expect(find.text('1 Menit Lalu'), findsOneWidget);
    expect(find.text('HD'), findsOneWidget);
    expect(find.text('1080p'), findsOneWidget);
    expect(find.text('04:12'), findsOneWidget);
    expect(find.text('12:45'), findsOneWidget);
    expect(find.text('Plastik • An-organik'), findsOneWidget);
    expect(find.text('by: Ibu Anin'), findsOneWidget);
    expect(find.text('Cara Mendaur Ulang Botol Plastik Minuman'), findsOneWidget);
    expect(find.text('1,4k'), findsOneWidget);
    expect(find.text('238'), findsOneWidget);
    expect(find.text('Bagikan'), findsOneWidget);

    // 5. Verify Wawasan Komunitas Section
    expect(find.text('Wawasan Komunitas'), findsOneWidget);
    expect(find.text('Semua >'), findsOneWidget);
    expect(find.text('Tanya Jawab'), findsOneWidget);
    expect(find.text('Jawaban Terverifikasi'), findsOneWidget);
    expect(find.text('Apakah sampah dapat berguna kembali?'), findsOneWidget);
    expect(find.text('Budi Prakoso • Komunitas Depok'), findsOneWidget);
    expect(find.text('45 balasan'), findsOneWidget);

    expect(find.text('Kreasi Daur Ulang'), findsOneWidget);
    expect(find.text('Daripada tidak digunakan kembali, ...'), findsOneWidget);
    expect(find.text('892 dilihat'), findsOneWidget);
    expect(find.text('DIY'), findsOneWidget);

    // 6. Verify Contributor CTA Banner
    expect(find.text('TERTARIK JADI KONTRIBUTOR?'), findsOneWidget);
    expect(find.text('KIRIM KONTEN ANDA'), findsOneWidget);
    expect(find.text('Mulai Berbagi Ide'), findsOneWidget);

    // 7. Verify Bottom Navigation
    expect(find.text('Konten'), findsOneWidget);
    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);

    // 8. Test Interaction: Tapping Filter button opens Filter Sheet
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filter Konten'), findsOneWidget);
    expect(find.text('Terapkan Filter'), findsOneWidget);
    await tester.tap(find.text('Terapkan Filter'));
    await tester.pumpAndSettle();

    // 9. Test Interaction: Tapping Comments opens Comments Sheet
    await tester.tap(find.text('238'));
    await tester.pumpAndSettle();
    expect(find.text('Komentar (238)'), findsOneWidget);
    expect(find.text('Farhan Rizky'), findsOneWidget);
    // Dismiss
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Mulai Berbagi Ide'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Mulai Berbagi Ide'));
    await tester.pumpAndSettle();
    expect(find.text('Unggah Konten Edukasi'), findsOneWidget);
    expect(find.text('Link Video YouTube *'), findsOneWidget);
    expect(find.text('Kirim Konten'), findsOneWidget);
  });
}
