/// Validator dan Helper untuk input, parsing, dan form Konten / Video Edukasi TR4SH.
/// Memisahkan logic if-else agar kode UI tetap bersih, teratur, dan modular.
class KontenValidator {
  KontenValidator._();

  /// Regex pola YouTube short URL (youtu.be/ID)
  static final RegExp _regShort = RegExp(r'youtu\.be\/([a-zA-Z0-9_\-]{11})');

  /// Regex pola YouTube watch URL (youtube.com/watch?v=ID atau watch?...&v=ID)
  static final RegExp _regWatch = RegExp(r'[?&]v=([a-zA-Z0-9_\-]{11})');

  /// Regex pola YouTube Shorts (youtube.com/shorts/ID)
  static final RegExp _regShorts = RegExp(r'youtube\.com\/shorts\/([a-zA-Z0-9_\-]{11})');

  /// Regex pola YouTube Embed, Live, atau Video path (youtube.com/embed/ID, /live/ID, /v/ID)
  static final RegExp _regEmbedOrLive = RegExp(r'youtube\.com\/(?:embed|live|v)\/([a-zA-Z0-9_\-]{11})');

  /// Regex pola 11 digit ID video YouTube murni
  static final RegExp _regPureId = RegExp(r'^[a-zA-Z0-9_\-]{11}$');

  /// Mengekstrak ID YouTube dari berbagai macam format URL
  static String? extractYoutubeId(String? rawUrl) {
    if (rawUrl == null) return null;
    final cleanUrl = rawUrl.trim();
    if (cleanUrl.isEmpty) return null;

    // 1. Pola youtu.be/ID
    final matchShort = _regShort.firstMatch(cleanUrl);
    if (matchShort != null) return matchShort.group(1);

    // 2. Pola youtube.com/watch?v=ID
    final matchWatch = _regWatch.firstMatch(cleanUrl);
    if (matchWatch != null) return matchWatch.group(1);

    // 3. Pola youtube.com/shorts/ID
    final matchShorts = _regShorts.firstMatch(cleanUrl);
    if (matchShorts != null) return matchShorts.group(1);

    // 4. Pola youtube.com/embed/ID, live/ID, v/ID
    final matchEmbed = _regEmbedOrLive.firstMatch(cleanUrl);
    if (matchEmbed != null) return matchEmbed.group(1);

    // 5. Pola jika user langsung memasukkan 11 karakter ID YouTube
    if (_regPureId.hasMatch(cleanUrl)) {
      return cleanUrl;
    }

    return null;
  }

  /// Memeriksa apakah URL YouTube valid
  static bool isValidYoutubeUrl(String? rawUrl) {
    return extractYoutubeId(rawUrl) != null;
  }

  /// Menormalisasi URL YouTube ke format standar canonical watch URL
  static String? normalizeYoutubeUrl(String? rawUrl) {
    final videoId = extractYoutubeId(rawUrl);
    if (videoId == null) return null;
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// Menghasilkan URL thumbnail YouTube berkualitas tinggi (HQ),
  /// atau URL gambar asli jika sudah berupa tautan gambar/CDN.
  static String? getYoutubeThumbnail(String? rawUrl) {
    final ytId = extractYoutubeId(rawUrl);
    if (ytId != null && ytId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    }
    if (rawUrl != null && (rawUrl.startsWith('http://') || rawUrl.startsWith('https://'))) {
      return rawUrl;
    }
    return null;
  }

  /// Validasi menyeluruh form upload konten edukasi.
  /// Mengembalikan pesan error jika tidak valid, atau `null` jika valid.
  static String? validateUploadForm({
    required String rawUrl,
    required String? detectedYoutubeId,
    required String title,
    required String description,
  }) {
    final cleanUrl = rawUrl.trim();
    final cleanTitle = title.trim();
    final cleanDesc = description.trim();

    if (cleanUrl.isEmpty) {
      return 'Link video YouTube wajib diisi!';
    }

    if (detectedYoutubeId == null || detectedYoutubeId.isEmpty) {
      return 'Format link YouTube tidak valid. Mohon periksa kembali!';
    }

    if (cleanTitle.isEmpty) {
      return 'Judul konten tidak boleh kosong!';
    }

    if (cleanTitle.length < 3) {
      return 'Judul konten minimal 3 karakter!';
    }

    if (cleanDesc.isEmpty) {
      return 'Deskripsi konten tidak boleh kosong!';
    }

    if (cleanDesc.length < 5) {
      return 'Deskripsi konten minimal 5 karakter!';
    }

    return null; // Valid
  }
}
