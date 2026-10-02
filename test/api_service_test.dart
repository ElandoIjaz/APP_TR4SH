import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/data/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiConfig Tests', () {
    test('BaseUrl and endpoints format properly', () {
      expect(ApiConfig.baseUrl, contains(':8000/api'));
      expect(ApiConfig.login, equals('${ApiConfig.baseUrl}/auth/login'));
      expect(ApiConfig.register, equals('${ApiConfig.baseUrl}/auth/register'));
      expect(ApiConfig.logout, equals('${ApiConfig.baseUrl}/auth/logout'));
      expect(ApiConfig.setorSampah, equals('${ApiConfig.baseUrl}/sampah/setor'));
      expect(ApiConfig.riwayatSetor, equals('${ApiConfig.baseUrl}/sampah/riwayat'));
      expect(ApiConfig.listPrakarya, equals('${ApiConfig.baseUrl}/prakarya'));
      expect(ApiConfig.listProduk, equals('${ApiConfig.baseUrl}/prakarya'));
      expect(ApiConfig.uploadEdukasi, equals('${ApiConfig.baseUrl}/edukasi/upload'));
      expect(ApiConfig.userKonten(1), equals('${ApiConfig.baseUrl}/edukasi/user/1'));
    });
  });

  group('ApiService Session Tests', () {
    test('saveSession, getToken, getUserSession, and clearSession work correctly', () async {
      expect(await ApiService.getToken(), isNull);
      expect(await ApiService.getUserSession(), isNull);

      const dummyToken = '1|laravel_sanctum_mock_token_abc123';
      const dummyUser = {
        'id': 1,
        'name': 'Bintang Pratama',
        'email': 'bintang@gmail.com',
      };

      await ApiService.saveSession(token: dummyToken, user: dummyUser);

      expect(await ApiService.getToken(), equals(dummyToken));
      final user = await ApiService.getUserSession();
      expect(user, isNotNull);
      expect(user?['name'], equals('Bintang Pratama'));
      expect(user?['email'], equals('bintang@gmail.com'));

      await ApiService.clearSession();
      expect(await ApiService.getToken(), isNull);
      expect(await ApiService.getUserSession(), isNull);
    });

    test('login handles server unreachable gracefully without crashing', () async {
      final res = await ApiService.login(email: 'test@gmail.com', password: 'password123');
      expect(res.success, isFalse);
      expect(res.message, isNotEmpty);
    });

    test('kirimSetorSampah handles offline server gracefully', () async {
      final res = await ApiService.kirimSetorSampah(
        kategori: 'Plastik',
        jumlahItem: 5,
        beratKg: 0.5,
        latitude: -6.907482,
        longitude: 107.618954,
        alamatJemput: 'Jl. Riau No. 45',
      );
      expect(res.success, isFalse);
    });

    test('uploadKonten handles offline server gracefully', () async {
      final res = await ApiService.uploadKonten(
        title: 'Tutorial Daur Ulang Galon Bekas',
        mediaUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        description: 'Langkah mudah memotong dan mengecat galon bekas.',
      );
      expect(res.success, isFalse);
      expect(res.message, isNotEmpty);
    });
  });
}
