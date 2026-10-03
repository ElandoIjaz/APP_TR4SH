import 'package:flutter_test/flutter_test.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/core/validators/konten_validator.dart';

void main() {
  group('KontenValidator Tests', () {
    test('extractYoutubeId extracts video IDs correctly from various formats', () {
      expect(
        KontenValidator.extractYoutubeId('https://youtu.be/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.extractYoutubeId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.extractYoutubeId('https://www.youtube.com/shorts/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.extractYoutubeId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.extractYoutubeId('https://www.youtube.com/live/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.extractYoutubeId('dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.extractYoutubeId('https://google.com/video'),
        isNull,
      );
      expect(
        KontenValidator.extractYoutubeId(''),
        isNull,
      );
      expect(
        KontenValidator.extractYoutubeId(null),
        isNull,
      );
    });

    test('isValidYoutubeUrl and normalizeYoutubeUrl function properly', () {
      expect(
        KontenValidator.isValidYoutubeUrl('https://youtu.be/dQw4w9WgXcQ'),
        isTrue,
      );
      expect(
        KontenValidator.isValidYoutubeUrl('invalid_link'),
        isFalse,
      );
      expect(
        KontenValidator.normalizeYoutubeUrl('https://youtu.be/dQw4w9WgXcQ'),
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(
        KontenValidator.normalizeYoutubeUrl('invalid'),
        isNull,
      );
    });

    test('getYoutubeThumbnail returns HQ thumbnail URL or raw image url', () {
      expect(
        KontenValidator.getYoutubeThumbnail('https://youtu.be/dQw4w9WgXcQ'),
        'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      );
      expect(
        KontenValidator.getYoutubeThumbnail('https://example.com/photo.png'),
        'https://example.com/photo.png',
      );
      expect(
        KontenValidator.getYoutubeThumbnail(null),
        isNull,
      );
    });

    test('validateUploadForm validates all fields and provides clear messages', () {
      // Empty URL
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: '',
          detectedYoutubeId: null,
          title: 'Cara Membuat Kompos',
          description: 'Tutorial lengkap daur ulang organik.',
        ),
        'Link video YouTube wajib diisi!',
      );

      // Invalid YouTube URL format
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: 'https://invalid-video.com/123',
          detectedYoutubeId: null,
          title: 'Cara Membuat Kompos',
          description: 'Tutorial lengkap daur ulang organik.',
        ),
        'Format link YouTube tidak valid. Mohon periksa kembali!',
      );

      // Empty title
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: 'https://youtu.be/dQw4w9WgXcQ',
          detectedYoutubeId: 'dQw4w9WgXcQ',
          title: '  ',
          description: 'Tutorial lengkap daur ulang organik.',
        ),
        'Judul konten tidak boleh kosong!',
      );

      // Title too short
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: 'https://youtu.be/dQw4w9WgXcQ',
          detectedYoutubeId: 'dQw4w9WgXcQ',
          title: 'Ab',
          description: 'Tutorial lengkap daur ulang organik.',
        ),
        'Judul konten minimal 3 karakter!',
      );

      // Empty description
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: 'https://youtu.be/dQw4w9WgXcQ',
          detectedYoutubeId: 'dQw4w9WgXcQ',
          title: 'Cara Membuat Kompos',
          description: '',
        ),
        'Deskripsi konten tidak boleh kosong!',
      );

      // Description too short
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: 'https://youtu.be/dQw4w9WgXcQ',
          detectedYoutubeId: 'dQw4w9WgXcQ',
          title: 'Cara Membuat Kompos',
          description: 'Tips',
        ),
        'Deskripsi konten minimal 5 karakter!',
      );

      // Completely valid form
      expect(
        KontenValidator.validateUploadForm(
          rawUrl: 'https://youtu.be/dQw4w9WgXcQ',
          detectedYoutubeId: 'dQw4w9WgXcQ',
          title: 'Cara Membuat Kompos',
          description: 'Tutorial lengkap daur ulang organik.',
        ),
        isNull,
      );
    });
  });

  group('AuthValidator Tests', () {
    test('validateLogin checks for empty inputs', () {
      expect(
        AuthValidator.validateLogin(username: '', password: ''),
        'Username dan kata sandi tidak boleh kosong!',
      );
      expect(
        AuthValidator.validateLogin(username: 'elando', password: ''),
        'Username dan kata sandi tidak boleh kosong!',
      );
      expect(
        AuthValidator.validateLogin(username: 'elando', password: 'password123'),
        isNull,
      );
    });

    test('validateRegister checks required fields, lengths, and terms agreement', () {
      expect(
        AuthValidator.validateRegister(
          nama: '',
          username: 'user',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: true,
        ),
        'Semua kolom harus diisi!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'Jo',
          username: 'user',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: true,
        ),
        'Nama lengkap minimal 3 karakter!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'jd',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: true,
        ),
        'Username minimal 3 karakter!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'john@gmail.com',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: true,
        ),
        'Username tidak boleh menggunakan simbol "@" (bukan email/gmail)!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'john doe',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: true,
        ),
        'Username tidak boleh mengandung spasi!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123456789',
          password: '123',
          setuju: true,
        ),
        'Kata sandi minimal 6 karakter!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: false,
        ),
        'Anda harus menyetujui Syarat & Ketentuan!',
      );

      // Testing batasan No. HP yang masuk akal
      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123abc789',
          password: 'secretpassword',
          setuju: true,
        ),
        'Nomor telepon hanya boleh berisi angka!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '081234',
          password: 'secretpassword',
          setuju: true,
        ),
        'Nomor telepon minimal 10 digit!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123456789012345',
          password: 'secretpassword',
          setuju: true,
        ),
        'Nomor telepon maksimal 15 digit!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '1234567890',
          password: 'secretpassword',
          setuju: true,
        ),
        'Format nomor HP tidak valid (harus diawali 08, 628, atau 8)!',
      );

      // Testing batasan Kata Sandi yang masuk akal
      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123456789',
          password: 'passwordyangsangatpanjangmelebihitigapuluhduakarakter',
          setuju: true,
        ),
        'Kata sandi maksimal 32 karakter!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123456789',
          password: 'pass word123',
          setuju: true,
        ),
        'Kata sandi tidak boleh mengandung spasi!',
      );

      expect(
        AuthValidator.validateRegister(
          nama: 'John Doe',
          username: 'johndoe',
          telepon: '08123456789',
          password: 'secretpassword',
          setuju: true,
        ),
        isNull,
      );
    });

    test('AuthValidator validateNomorHp and validatePassword standalone helpers', () {
      expect(AuthValidator.validateNomorHp('081234567890'), isNull);
      expect(AuthValidator.validateNomorHp('6281234567890'), isNull);
      expect(AuthValidator.validateNomorHp('81234567890'), isNull);
      expect(AuthValidator.validateNomorHp('08123'), 'Nomor telepon minimal 10 digit!');
      expect(AuthValidator.validateNomorHp('08123456789012345'), 'Nomor telepon maksimal 15 digit!');
      expect(AuthValidator.validateNomorHp('0812abc456'), 'Nomor telepon hanya boleh berisi angka!');

      expect(AuthValidator.validatePassword('password123'), isNull);
      expect(AuthValidator.validatePassword('12345'), 'Kata sandi minimal 6 karakter!');
      expect(AuthValidator.validatePassword('a' * 33), 'Kata sandi maksimal 32 karakter!');
      expect(AuthValidator.validatePassword('pass word'), 'Kata sandi tidak boleh mengandung spasi!');
    });
  });
}
