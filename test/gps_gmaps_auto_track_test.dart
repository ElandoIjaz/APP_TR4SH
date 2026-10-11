import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/akun/halaman_pilih_lokasi_akurat.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/widgets/tracking/card_auto_track_lokasi.dart';

void main() {
  group('LokasiTrackingService Tests', () {
    test('Initial coordinates and defaults are valid', () {
      expect(LokasiTrackingService.currentLatitude, isNonZero);
      expect(LokasiTrackingService.currentLongitude, isNonZero);
      expect(LokasiTrackingService.currentAccuracy, contains('meter'));
      expect(LokasiTrackingService.currentAddress, isNotEmpty);
      final url = LokasiTrackingService.getGoogleMapsUrl(
        LokasiTrackingService.currentLatitude,
        LokasiTrackingService.currentLongitude,
      );
      expect(url, contains('https://www.google.com/maps/search/?api=1&query='));
    });

    test('updateTrackedLocation updates coordinates and address properly', () {
      const testPlace = LokasiGmapsItem(
        namaTempat: 'Test Place',
        alamatLengkap: 'Jl. Riau No. 99, Bandung',
        kota: 'Bandung',
        kodePos: '40115',
        latitude: -6.908000,
        longitude: 107.619000,
        patokan: 'Depan kafe',
      );

      LokasiTrackingService.updateTrackedLocation(
        lat: testPlace.latitude,
        lng: testPlace.longitude,
        address: testPlace.alamatLengkap,
        city: testPlace.kota,
        postalCode: testPlace.kodePos,
        patokan: testPlace.patokan,
      );

      expect(LokasiTrackingService.currentLatitude, testPlace.latitude);
      expect(LokasiTrackingService.currentLongitude, testPlace.longitude);
      expect(LokasiTrackingService.currentAddress, testPlace.alamatLengkap);
      expect(LokasiTrackingService.currentPatokan, testPlace.patokan);
    });
  });

  group('CardAutoTrackLokasi Widget Tests', () {
    testWidgets(
      'CardAutoTrackLokasi renders and handles GMaps modal and Refresh',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: CardAutoTrackLokasi())),
        );
        await tester.pump();

        // Verify Auto-Track badge and coordinates
        expect(find.text('AUTO-TRACK LOKASI PENJEMPUTAN'), findsOneWidget);
        expect(find.textContaining('Koordinat:'), findsOneWidget);
        expect(find.textContaining('meter'), findsOneWidget);

        // Tap Refresh GPS
        expect(find.text('Refresh GPS'), findsOneWidget);
        await tester.tap(find.text('Refresh GPS'));
        await tester.pump(const Duration(milliseconds: 600));

        // Tap Buka di GMaps modal
        expect(find.text('Buka di GMaps'), findsOneWidget);
        await tester.tap(find.text('Buka di GMaps'));
        await tester.pumpAndSettle();

        // Verify Google Maps modal content
        expect(find.text('Terkoneksi Google Maps'), findsOneWidget);
        expect(find.text('Buka di Google Maps'), findsOneWidget);

        // Close modal
        await tester.tap(find.text('Buka di Google Maps'));
        await tester.pumpAndSettle();
      },
    );
  });

  group('HalamanPilihLokasiAkurat GMaps and GPS Tests', () {
    testWidgets(
      'Place search autocomplete, layer switch, and GPS lock work smoothly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(home: HalamanPilihLokasiAkurat()),
        );
        await tester.pumpAndSettle();

        // Verify Header & Map Controls
        expect(find.text('Tentukan Lokasi Akurat'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('Peta'), findsOneWidget);
        expect(find.text('Satelit'), findsOneWidget);
        expect(find.text('Hybrid'), findsOneWidget);

        // Switch map mode to Satelit
        await tester.tap(find.text('Satelit'));
        await tester.pumpAndSettle();

        // Switch to Hybrid
        await tester.tap(find.text('Hybrid'));
        await tester.pumpAndSettle();

        // Search via Google Maps autocomplete in first textfield
        await tester.enterText(find.byType(TextField).first, 'Dago');
        await tester.pumpAndSettle();

        // Verify dropdown suggestion appears and tap it
        expect(find.textContaining('Eco Hub Dago'), findsOneWidget);
        await tester.tap(find.textContaining('Eco Hub Dago'));
        await tester.pumpAndSettle();

        // Tap Buka GMaps action icon in AppBar
        await tester.tap(find.byIcon(Icons.map_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Navigasi Google Maps'), findsOneWidget);
        expect(find.text('Buka Aplikasi Google Maps'), findsOneWidget);
        await tester.tap(find.text('Buka Aplikasi Google Maps'));
        await tester.pumpAndSettle();

        // Kunci GPS
        await tester.tap(find.text('Kunci GPS Saya'));
        await tester.pumpAndSettle();

        // Choose chip
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Kantor'));
        await tester.pumpAndSettle();

        // Simpan Lokasi Akurat
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -600),
        );
        await tester.pumpAndSettle();
        expect(find.text('Simpan Lokasi Akurat'), findsOneWidget);
        await tester.tap(find.text('Simpan Lokasi Akurat'));
        await tester.pumpAndSettle();
      },
    );
  });

  group('HalamanTracking with Auto-Track GPS Tests', () {
    testWidgets(
      'Live auto-track card is embedded and used during waste input',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: HalamanTracking()));
        await tester.pumpAndSettle();

        // Verify Auto-Track GPS card is present on Tracking dashboard
        expect(find.text('AUTO-TRACK LOKASI PENJEMPUTAN'), findsOneWidget);
        expect(find.text('+ Input Sampah'), findsOneWidget);

        // Tap + Input Sampah
        await tester.tap(find.text('+ Input Sampah'));
        await tester.pumpAndSettle();

        // Verify popup contains Auto-Tracked pickup address
        expect(find.text('Sampah Berhasil Diinput!'), findsOneWidget);
        expect(find.textContaining('Auto-Track Titik Jemput:'), findsOneWidget);
        expect(find.text('Selesai'), findsOneWidget);

        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle();
      },
    );
  });

  group('HalamanBeranda Auto-Track in Waste Pickup Flow', () {
    testWidgets('Beranda deposit sheet displays auto-track GPS info', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: HalamanBeranda()));
      await tester.pumpAndSettle();

      // Tap Mulai Setor
      await tester.tap(find.text('Mulai Setor'));
      await tester.pumpAndSettle();

      // Verify auto-track GPS info in sheet
      expect(find.text('Setor Sampah Mandiri'), findsOneWidget);
      expect(find.textContaining('Auto-Track GPS:'), findsOneWidget);
      expect(find.text('GMaps >'), findsOneWidget);

      // Confirm deposit pickup
      await tester.tap(find.text('Buat Jadwal Penjemputan'));
      await tester.pumpAndSettle();
    });
  });
}
