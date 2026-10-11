import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/widgets/beranda/card_video_tutorial.dart';

void main() {
  group('Edukasi Approved Integration Tests', () {
    testWidgets(
      'CardVideoTutorial supports approved content dynamic properties',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CardVideoTutorial(
                sectionTitle: 'Konten Edukasi Baru Terupload',
                title: 'Kreasi Daur Ulang Botol Minyak',
                subtitle: 'Video edukasi dari komunitas TR4SH yang telah disetujui admin.',
                author: 'Bintang Pratama',
                badgeText: 'BARU DISETUJUI',
                onPlayTap: () {},
                onSeeAllTap: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Konten Edukasi Baru Terupload'), findsOneWidget);
        expect(find.text('Kreasi Daur Ulang Botol Minyak'), findsOneWidget);
        expect(
          find.text(
            'Video edukasi dari komunitas TR4SH yang telah disetujui admin.',
          ),
          findsOneWidget,
        );
        expect(find.text('BARU DISETUJUI'), findsOneWidget);
        expect(find.text('Oleh: Bintang Pratama'), findsOneWidget);
      },
    );

    testWidgets(
      'HalamanBeranda renders RefreshIndicator and Video section properly',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: HalamanBeranda()));
        await tester.pump();

        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.text('Cara Menabung Sampah'), findsOneWidget);
        expect(find.text('Panduan Pilah Sampah Rumah Tangga'), findsOneWidget);
      },
    );

    testWidgets(
      'HalamanKonten renders RefreshIndicator, Filter and Content sections',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: HalamanKonten()));
        await tester.pump();

        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.text('Konten Baru Terupload'), findsOneWidget);
        expect(find.text('Konten Terbaru'), findsOneWidget);
        expect(find.text('SOROTAN UTAMA'), findsOneWidget);
      },
    );
  });
}
