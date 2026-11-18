import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/beranda/halaman_peta_cabang.dart';

/// 1x1 transparent PNG so flutter_map TileLayer resolves cleanly in offline widget tests.
final Uint8List _transparentPng = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _MockMapHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final Uri url;
  _MockHttpClientRequest(this.url);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  int contentLength = -1;

  @override
  Future<HttpClientResponse> close() async {
    if (url.host.contains('tile.openstreetmap.org')) {
      return _MockHttpClientResponse(200, _transparentPng);
    }
    return _MockHttpClientResponse(404, Uint8List(0));
  }

  @override
  void add(List<int> data) {}

  @override
  Future addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void forEach(void Function(String name, List<String> values) action) {}

  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final Uint8List _bytes;

  _MockHttpClientResponse(this.statusCode, this._bytes);

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => statusCode == 200 ? 'OK' : 'Not Found';

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserAccountData.isGuest = false;
    UserAccountData.isNewAccount = false;
  });

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

  group('HalamanPetaCabang Tests', () {
    testWidgets(
      'HalamanPetaCabang renders map title, fallback branches, and navigation CTA',
      (WidgetTester tester) async {
        await HttpOverrides.runZoned(() async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(
            const MaterialApp(home: HalamanPetaCabang()),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 4));
          await tester.pump(const Duration(milliseconds: 500));

          expect(
            find.text('Lokasi Cabang & Rute Bank Sampah'),
            findsOneWidget,
          );
          expect(find.text('Pilih Cabang Bank Sampah'), findsOneWidget);
          expect(
            find.textContaining('Rekomendasi Terdekat:'),
            findsOneWidget,
          );
          expect(
            find.text('Bank Sampah Pusat Sahabat Ibu'),
            findsWidgets,
          );
          expect(
            find.text('Buka Navigasi Turn-by-Turn'),
            findsOneWidget,
          );
        }, createHttpClient: (_) => _MockMapHttpOverrides().createHttpClient(null));
      },
    );
  });

  group('HalamanBeranda Map Navigation Tests', () {
    testWidgets('Beranda Cari Cabang button opens HalamanPetaCabang', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: HalamanBeranda()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Cari Cabang'), findsOneWidget);
        await tester.tap(find.text('Cari Cabang'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(HalamanPetaCabang), findsOneWidget);
      }, createHttpClient: (_) => _MockMapHttpOverrides().createHttpClient(null));
    });
  });
}
