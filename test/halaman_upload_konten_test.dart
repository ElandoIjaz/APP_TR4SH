import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HalamanUploadKonten renders form, preview, and tabs properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HalamanUploadKonten(),
      ),
    );
    await tester.pump();

    // Verify Title and Tabs
    expect(find.text('Unggah Konten Edukasi'), findsOneWidget);
    expect(find.text('Formulir Konten'), findsOneWidget);
    expect(find.text('Konten Saya'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Link Video YouTube *'), findsOneWidget);
    expect(find.text('Judul Konten Edukasi *'), findsOneWidget);
    expect(find.text('Kategori Edukasi *'), findsOneWidget);
    expect(find.text('Deskripsi Konten *'), findsOneWidget);
    expect(find.text('Kirim Konten'), findsOneWidget);

    // Initial placeholder for YouTube preview
    expect(find.text('Pratinjau video YouTube akan muncul di sini'), findsOneWidget);

    // Enter YouTube URL
    final urlField = find.widgetWithText(TextField, 'https://www.youtube.com/watch?v=... atau youtu.be/...');
    await tester.enterText(urlField, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    await tester.pump();

    // Live preview detected
    expect(find.textContaining('Video YouTube Terdeteksi'), findsOneWidget);

    // Enter title & description
    final titleField = find.widgetWithText(TextField, 'Contoh: Membuat Pot Hias dari Limbah Galon Air');
    await tester.enterText(titleField, 'Tutorial Pot Bunga Estetik');

    final descField = find.widgetWithText(TextField, 'Tuliskan ringkasan video, alat/bahan yang dibutuhkan, atau poin penting yang bisa dipelajari penonton...');
    await tester.enterText(descField, 'Berikut panduan mendaur ulang galon plastik menjadi pot tanaman.');
    await tester.pump();

    // Switch to Tab 2: Konten Saya
    await tester.tap(find.text('Konten Saya'));
    await tester.pumpAndSettle();

    // Empty state or history
    expect(find.byType(HalamanUploadKonten), findsOneWidget);
  });
}
