import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/widgets/akun/card_profil_user.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';

void main() {
  setUp(() {
    UserAccountData.initNewUser(
      nama: 'Rian Perdana',
      username: 'rian_peduli',
      phone: '081234567890',
      userId: 99,
    );
  });

  tearDown(() {
    UserAccountData.isGuest = false;
    UserAccountData.isNewAccount = false;
    UserAccountData.currentNama = 'Bintang Pratama';
    UserAccountData.currentUsername = 'bintang_eco';
    UserAccountData.userPoints = 500;
  });

  test('UserAccountData.initNewUser initializes all stats to zero', () {
    expect(UserAccountData.isNewAccount, isTrue);
    expect(UserAccountData.userPoints, equals(0));
    expect(UserAccountData.totalSampahKg, equals(0.0));
    expect(UserAccountData.totalSetoran, equals(0));
    expect(UserAccountData.totalMisiSelesai, equals(0));
    expect(UserAccountData.listRiwayatSetor, isEmpty);
    expect(UserAccountData.listKontenSaya, isEmpty);
    expect(UserAccountData.listTransaksi, isEmpty);
    expect(UserAccountData.currentNama, equals('Rian Perdana'));
    expect(UserAccountData.currentUsername, equals('rian_peduli'));
  });

  testWidgets(
    'CardTrackingChart renders 0.0 kg and zero categories for new user account',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CardTrackingChart(
                totalDisetor: '0.0 kg',
                trendPercent: '+0 setoran',
                rawData: [],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 0.0 kg total and badge is rendered
      expect(find.text('0.0 kg'), findsWidgets);
      expect(find.text('+0 setoran'), findsOneWidget);

      // Verify all 4 category breakdown chips exist
      expect(find.text('Botol Plastik'), findsOneWidget);
      expect(find.text('Kertas Bekas'), findsOneWidget);
      expect(find.text('Baterai (B3)'), findsOneWidget);
      expect(find.text('Bungkus Kaleng'), findsOneWidget);

      // Verify summary cards show +0 setor
      expect(find.text('+0 setor'), findsWidgets);
    },
  );

  testWidgets('HalamanAkun displays zero stats for newly registered account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HalamanAkun()));
    await tester.pumpAndSettle();

    // Verify user profile
    expect(find.text('Rian Perdana'), findsOneWidget);
    expect(find.text('@rian_peduli'), findsOneWidget);

    // Verify Stats (all 0)
    expect(find.text('0.0 kg'), findsOneWidget);
    expect(find.text('0 Poin'), findsOneWidget);
    expect(find.text('0 Misi'), findsOneWidget);

    // Verify Dampak Positif banner (0.0 kg and 0.0 CO2e)
    expect(
      find.text('Total 0.0 kg sampah berhasil dikurangi dari TPA'),
      findsOneWidget,
    );
    expect(find.text('Setara 0.0 kg reduksi CO2e'), findsOneWidget);

    // Verify Poin & Hadiah badge is 0 Pts
    expect(find.text('0 Pts'), findsOneWidget);
  });

  testWidgets(
    'CardProfilUser renders empty profile avatar icon and no verified badge for guest',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardProfilUser(
              name: 'Tamu',
              username: '@tamu_eco',
              status: 'Mode Eksplorasi',
              isGuest: true,
              isVerified: false,
              onEditTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tamu'), findsOneWidget);
      expect(find.text('@tamu_eco'), findsOneWidget);
      expect(find.text('Mode Eksplorasi'), findsOneWidget);
      // Profile avatar should be the default person_rounded icon (profil kosongan)
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      // Verified check badge should not be present
      expect(find.byIcon(Icons.check), findsNothing);
    },
  );

  testWidgets(
    'CardTrackingChart renders 0.0 kg and zero categories for guest mode account',
    (WidgetTester tester) async {
      UserAccountData.setGuestMode();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CardTrackingChart(
                totalDisetor: '0.0 kg',
                trendPercent: '+0 setoran',
                rawData: [],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 0.0 kg total and badge is rendered
      expect(find.text('0.0 kg'), findsWidgets);
      expect(find.text('+0 setoran'), findsOneWidget);

      // Verify summary cards show +0 setor
      expect(find.text('+0 setor'), findsWidgets);
    },
  );

  testWidgets(
    'HalamanBeranda renders 0.0 kg and 0 setoran for Riwayat Setor Sampah in guest mode',
    (WidgetTester tester) async {
      UserAccountData.setGuestMode();

      await tester.pumpWidget(const MaterialApp(home: HalamanBeranda()));
      await tester.pumpAndSettle();

      // Verify Header shows Tamu
      expect(find.text('Halo, Tamu 👋'), findsOneWidget);

      // Verify Riwayat Setor Sampah shows 0.0 kg and +0 setoran
      expect(find.text('RIWAYAT SETOR SAMPAH'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
      expect(find.text('+0 setoran'), findsOneWidget);
    },
  );
}
