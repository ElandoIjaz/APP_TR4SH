import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/konten_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';
import 'package:test23/widgets/konten/banner_kontributor_konten.dart';
import 'package:test23/widgets/konten/header_konten.dart';
import 'package:test23/widgets/konten/kategori_konten_tabs.dart';
import 'package:test23/widgets/konten/search_konten_bar.dart';
import 'package:test23/widgets/konten/section_wawasan_komunitas.dart';
import 'package:test23/widgets/konten/youtube_player_section.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';

class HalamanKonten extends StatefulWidget {
  final Map<String, dynamic>? initialSelectedKonten;

  const HalamanKonten({super.key, this.initialSelectedKonten});

  @override
  State<HalamanKonten> createState() => _HalamanKontenState();
}

class _HalamanKontenState extends State<HalamanKonten> {
  static const int _itemsPerPage = 10;

  int _selectedCategoryIndex = 0;
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _listEdukasiPublik = [];
  bool _isLoadingEdukasi = true;
  String _searchQuery = '';
  bool _hasOpenedInitialContent = false;

  final Set<String> _savedContentKeys = {};
  final Map<String, int> _commentCounts = {};

  final List<String> _categories = [
    'Terbaru',
    'Semua',
    'Recycle',
    'Reuse',
    'Reduce',
    'Resell',
    'Disimpan',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedContents();
    _loadEdukasiPublik();
  }

  int? _resolveActiveUserId() {
    if (!UserAccountData.isLoggedIn || UserAccountData.isGuest) return null;
    return UserAccountData.currentUserId;
  }

  String _getUserBookmarkPrefsKey() {
    final userId = _resolveActiveUserId();
    if (userId != null && userId > 0) {
      return 'tr4sh_saved_konten_user_$userId';
    }
    if (UserAccountData.isGuest || !UserAccountData.isLoggedIn) {
      return 'tr4sh_saved_konten_guest';
    }
    final uname = UserAccountData.currentUsername.trim();
    return uname.isNotEmpty
        ? 'tr4sh_saved_konten_$uname'
        : 'tr4sh_saved_konten_default';
  }

  String _getItemSumber(Map<String, dynamic> itemMap) {
    final sumberRaw =
        (itemMap['sumber_konten'] ?? itemMap['sumber'])
            ?.toString()
            .toLowerCase() ??
        '';
    if (sumberRaw.isNotEmpty) {
      return sumberRaw.contains('user') ? 'user' : 'edukasi';
    }
    if (itemMap['id_edukasi'] != null) {
      return 'edukasi';
    }
    if (itemMap['id_konten'] != null) {
      return 'user';
    }
    if (itemMap['id_user'] != null) {
      return 'user';
    }
    final penulis = itemMap['penulis']?.toString().toLowerCase() ?? '';
    if (penulis.isNotEmpty && !penulis.contains('admin')) {
      return 'user';
    }
    return 'edukasi';
  }

  int? _getItemNumericId(Map<String, dynamic> itemMap) {
    final raw = itemMap['id_edukasi'] ?? itemMap['id_konten'] ?? itemMap['id'];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }

  String _getItemKey(Map<String, dynamic> itemMap) {
    final sumber = _getItemSumber(itemMap);
    final id = _getItemNumericId(itemMap);
    if (id != null) {
      return '${sumber}_$id';
    }
    return '${sumber}_${itemMap['title']?.toString() ?? '1'}';
  }

  bool _isItemSaved(Map<String, dynamic> itemMap) {
    final key = _getItemKey(itemMap);
    if (_savedContentKeys.contains(key)) return true;
    final numericId = _getItemNumericId(itemMap);
    if (numericId != null && _savedContentKeys.contains(numericId.toString())) {
      return true;
    }
    return false;
  }

  DateTime? _extractItemDate(Map<String, dynamic> map) {
    const dateKeys = [
      'created_at',
      'tanggal_upload',
      'tgl_upload',
      'tanggal',
      'published_at',
      'date',
      'updated_at',
    ];

    for (final key in dateKeys) {
      final raw = map[key]?.toString().trim();
      if (raw == null || raw.isEmpty || raw == 'null') continue;

      final parsedIso = DateTime.tryParse(raw);
      if (parsedIso != null) {
        return parsedIso.toLocal();
      }

      final normalized = raw.split(' ').first;
      final parts = normalized.contains('/')
          ? normalized.split('/')
          : normalized.split('-');
      if (parts.length == 3) {
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        final p2 = int.tryParse(parts[2]);
        if (p0 != null && p1 != null && p2 != null) {
          if (parts[0].length == 4) {
            return DateTime(p0, p1, p2);
          } else if (parts[2].length == 4) {
            return DateTime(p2, p1, p0);
          }
        }
      }
    }
    return null;
  }

  Future<void> _loadSavedContents() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsKey = _getUserBookmarkPrefsKey();
    final localKeys = prefs.getStringList(prefsKey) ?? [];

    if (mounted) {
      setState(() {
        _savedContentKeys
          ..clear()
          ..addAll(localKeys);
      });
    }

    final userId = _resolveActiveUserId();
    if (userId != null && userId > 0) {
      try {
        final token = await ApiService.getToken();
        final uri = Uri.parse(
          '${ApiConfig.baseUrl}/simpan-konten?id_user=$userId',
        );
        final res = await http
            .get(
              uri,
              headers: {
                'Accept': 'application/json',
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 10));
        if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map &&
              decoded['success'] == true &&
              decoded['data'] is List) {
            final apiKeys = <String>[];
            for (final raw in (decoded['data'] as List)) {
              if (raw is Map) {
                final key = raw['item_key']?.toString();
                if (key != null && key.isNotEmpty) {
                  apiKeys.add(key);
                } else {
                  final sumber = raw['sumber_konten']?.toString() == 'user'
                      ? 'user'
                      : 'edukasi';
                  final kId = raw['konten_id']?.toString();
                  if (kId != null && kId.isNotEmpty) {
                    apiKeys.add('${sumber}_$kId');
                  }
                }
              }
            }
            setState(() {
              _savedContentKeys
                ..clear()
                ..addAll(apiKeys);
            });
            await prefs.setStringList(prefsKey, apiKeys);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _toggleSaveContent(
    Map<String, dynamic> itemMap, {
    VoidCallback? onStateChanged,
  }) async {
    final itemKey = _getItemKey(itemMap);
    final numericId = _getItemNumericId(itemMap);
    final bool willSave = !_isItemSaved(itemMap);

    setState(() {
      if (willSave) {
        _savedContentKeys.add(itemKey);
      } else {
        _savedContentKeys.remove(itemKey);
        if (numericId != null) {
          _savedContentKeys.remove(numericId.toString());
        }
      }
    });
    onStateChanged?.call();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _getUserBookmarkPrefsKey(),
      _savedContentKeys.toList(),
    );

    final userId = _resolveActiveUserId();
    final sumber = _getItemSumber(itemMap);

    if (userId != null && userId > 0 && numericId != null) {
      try {
        final token = await ApiService.getToken();
        final uri = Uri.parse('${ApiConfig.baseUrl}/simpan-konten/toggle');
        final res = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'id_user': userId,
                'sumber_konten': sumber,
                'konten_id': numericId,
              }),
            )
            .timeout(const Duration(seconds: 10));
        if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map && decoded['saved'] is bool) {
            final serverSaved = decoded['saved'] as bool;
            setState(() {
              if (serverSaved) {
                _savedContentKeys.add(itemKey);
              } else {
                _savedContentKeys.remove(itemKey);
                _savedContentKeys.remove(numericId.toString());
              }
            });
            onStateChanged?.call();
            await prefs.setStringList(
              _getUserBookmarkPrefsKey(),
              _savedContentKeys.toList(),
            );
          }
        }
      } catch (_) {}
    }
  }

  Map<String, dynamic>? _findInitialContentMatch() {
    final target = widget.initialSelectedKonten;
    if (target == null) return null;

    final targetId =
        target['id']?.toString() ??
        target['id_konten']?.toString() ??
        target['id_edukasi']?.toString();
    final targetUrl = target['media_url']?.toString().trim();
    final targetTitle = target['title']?.toString().trim();

    for (final raw in _listEdukasiPublik) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final itemId =
          map['id']?.toString() ??
          map['id_konten']?.toString() ??
          map['id_edukasi']?.toString();
      if (targetId != null && targetId.isNotEmpty && itemId == targetId) {
        return map;
      }
      if (targetUrl != null &&
          targetUrl.isNotEmpty &&
          map['media_url']?.toString().trim() == targetUrl) {
        return map;
      }
      if (targetTitle != null &&
          targetTitle.isNotEmpty &&
          map['title']?.toString().trim() == targetTitle) {
        return map;
      }
    }

    return Map<String, dynamic>.from(target);
  }

  void _openInitialContentIfNeeded() {
    if (_hasOpenedInitialContent ||
        widget.initialSelectedKonten == null ||
        !mounted) {
      return;
    }
    final matched = _findInitialContentMatch();
    if (matched == null) return;

    _hasOpenedInitialContent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showContentDetailModal(matched);
      }
    });
  }

  Future<void> _loadEdukasiPublik() async {
    try {
      final res = await ApiService.fetchEdukasi();
      if (res.success && res.data is List && mounted) {
        setState(() {
          _listEdukasiPublik = res.data as List;
          _isLoadingEdukasi = false;
        });
        for (var item in _listEdukasiPublik) {
          final map = item is Map
              ? Map<String, dynamic>.from(item)
              : <String, dynamic>{};
          final key = _getItemKey(map);
          final numericId = _getItemNumericId(map);
          if (numericId != null) {
            _loadCommentCount(key, numericId.toString());
          }
        }
        _openInitialContentIfNeeded();
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingEdukasi = false);
      _openInitialContentIfNeeded();
    }
  }

  Future<void> _loadCommentCount(String itemKey, String kontenId) async {
    try {
      final res = await ApiService.fetchComments(kontenId);
      if (res.success && res.data is List && mounted) {
        setState(() {
          _commentCounts[itemKey] = (res.data as List).length;
        });
      }
    } catch (_) {}
  }

  String? _getYoutubeThumbnail(String? url) =>
      KontenValidator.getYoutubeThumbnail(url);

  List<dynamic> get _filteredEdukasi {
    if (_listEdukasiPublik.isEmpty) return [];
    var list = List.from(_listEdukasiPublik);

    if (_selectedCategoryIndex == 0) {
      final now = DateTime.now();
      final oneMonthAgo = DateTime(
        now.year,
        now.month - 1,
        now.day,
        now.hour,
        now.minute,
        now.second,
      );

      list = list.where((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : <String, dynamic>{};
        final releaseDate = _extractItemDate(map);
        if (releaseDate == null) return false;
        return !releaseDate.isBefore(oneMonthAgo);
      }).toList();

      list.sort((a, b) {
        final mapA = a is Map
            ? Map<String, dynamic>.from(a)
            : <String, dynamic>{};
        final mapB = b is Map
            ? Map<String, dynamic>.from(b)
            : <String, dynamic>{};
        final dateA = _extractItemDate(mapA) ?? DateTime(1970);
        final dateB = _extractItemDate(mapB) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    } else if (_selectedCategoryIndex == 6) {
      list = list.where((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : <String, dynamic>{};
        return _isItemSaved(map);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : <String, dynamic>{};
        final title = (map['title'] ?? '').toString().toLowerCase();
        final desc = (map['description'] ?? '').toString().toLowerCase();
        final penulis = (map['penulis'] ?? '').toString().toLowerCase();
        final jenis = (map['jenis_edukasi'] ?? '').toString().toLowerCase();
        return title.contains(q) ||
            desc.contains(q) ||
            penulis.contains(q) ||
            jenis.contains(q);
      }).toList();
    }

    if (_selectedCategoryIndex == 2) {
      list = list
          .where(
            (item) => (item['jenis_edukasi'] ?? '')
                .toString()
                .toLowerCase()
                .contains('recycle'),
          )
          .toList();
    } else if (_selectedCategoryIndex == 3) {
      list = list
          .where(
            (item) => (item['jenis_edukasi'] ?? '')
                .toString()
                .toLowerCase()
                .contains('reuse'),
          )
          .toList();
    } else if (_selectedCategoryIndex == 4) {
      list = list
          .where(
            (item) => (item['jenis_edukasi'] ?? '')
                .toString()
                .toLowerCase()
                .contains('reduce'),
          )
          .toList();
    } else if (_selectedCategoryIndex == 5) {
      list = list
          .where(
            (item) => (item['jenis_edukasi'] ?? '')
                .toString()
                .toLowerCase()
                .contains('resell'),
          )
          .toList();
    }

    return list;
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _currentPage = 1;
    });
  }

  void _changePage(int newPage, int totalPages) {
    if (newPage < 1 || newPage > totalPages || newPage == _currentPage) return;
    setState(() {
      _currentPage = newPage;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToNotifikasi() {
    if (!UserAccountData.isLoggedIn) {
      AuthRequiredModal.show(
        context,
        title: 'Notifikasi Memerlukan Akun',
        message: 'Silakan masuk terlebih dahulu untuk melihat notifikasi Anda.',
      );
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const HalamanNotifikasi()));
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Kategori Konten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((label) {
                final int idx = _categories.indexOf(label);
                final bool isSelected = _selectedCategoryIndex == idx;
                return ChoiceChip(
                  selected: isSelected,
                  selectedColor: AppColors.darkGreen,
                  backgroundColor: const Color(0xFFE8F5EE),
                  label: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.limeAccent
                          : AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onSelected: (selected) {
                    _selectCategory(idx);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showContentDetailModal(Map<String, dynamic> itemMap) {
    final title = itemMap['title']?.toString() ?? 'Edukasi TR4SH';
    final desc =
        itemMap['description']?.toString() ?? 'Tidak ada deskripsi tersedia.';
    final author = itemMap['penulis']?.toString() ?? 'Komunitas TR4SH';
    final jenis = itemMap['jenis_edukasi']?.toString() ?? 'Edukasi Lingkungan';
    final mediaUrl = itemMap['media_url']?.toString() ?? '';
    final tipeMedia = itemMap['tipe_media']?.toString() ?? 'Video YouTube';

    final bool isVideo =
        tipeMedia.toLowerCase().contains('video') ||
        mediaUrl.contains('youtube.com') ||
        mediaUrl.contains('youtu.be');

    final itemKey = _getItemKey(itemMap);
    final commentKontenId = (_getItemNumericId(itemMap) ?? 0).toString();
    final TextEditingController commentController = TextEditingController();
    Future<ApiResponse> commentsFuture =
        ApiService.fetchComments(commentKontenId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final isSaved = _isItemSaved(itemMap);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(sheetContext).size.height * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8F4E4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          jenis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B6B44),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.darkGreen,
                        ),
                        onPressed: () {
                          _toggleSaveContent(
                            itemMap,
                            onStateChanged: () {
                              if (modalContext.mounted) {
                                setModalState(() {});
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: FutureBuilder<ApiResponse>(
                      future: commentsFuture,
                      builder: (context, snapshot) {
                        List<dynamic> commentsList = [];
                        bool isLoading =
                            snapshot.connectionState == ConnectionState.waiting;

                        if (snapshot.hasData &&
                            snapshot.data!.success &&
                            snapshot.data!.data is List) {
                          commentsList = snapshot.data!.data as List;
                        }

                        return ListView(
                          physics: const ClampingScrollPhysics(),
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isVideo)
                              YoutubePlayerSection(mediaUrl: mediaUrl)
                            else if (mediaUrl.isNotEmpty &&
                                mediaUrl.startsWith('http'))
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  mediaUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 170,
                                        color: AppColors.darkGreen,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Oleh: $author',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF1E8850),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Deskripsi Konten:',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF465A50),
                                height: 1.4,
                              ),
                            ),
                            const Divider(height: 30),
                            Text(
                              'Komentar & Diskusi (${commentsList.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 10),
                            isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  )
                                : commentsList.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Belum ada komentar. Jadilah yang pertama berkomentar!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: commentsList.map((comm) {
                                      final cMap = comm is Map
                                          ? Map<String, dynamic>.from(comm)
                                          : <String, dynamic>{};
                                      final idKomentar =
                                          cMap['id_komentar']?.toString() ??
                                          '0';
                                      final authorName =
                                          cMap['author']?.toString() ??
                                          'Pengguna';
                                      final commentText =
                                          cMap['comment']?.toString() ?? '';
                                      return _buildCommentItem(
                                        idKomentar,
                                        authorName,
                                        commentText,
                                        setModalState,
                                      );
                                    }).toList(),
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!UserAccountData.isLoggedIn)
                    InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        AuthRequiredModal.show(
                          context,
                          title: 'Komentar Memerlukan Akun',
                          message:
                              'Silakan masuk atau daftar akun terlebih dahulu untuk menuliskan komentar pada konten edukasi ini.',
                          icon: Icons.chat_bubble_outline_rounded,
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgScreen,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Masuk ke akun untuk menulis komentar...',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.login_rounded,
                              color: AppColors.darkGreen,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: 'Tulis komentar Anda...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: AppColors.darkGreen,
                              size: 20,
                            ),
                            onPressed: () async {
                              final text = commentController.text.trim();
                              if (text.isEmpty) return;

                              final res = await ApiService.postComment(
                                commentKontenId,
                                text,
                              );
                              if (res.success) {
                                commentController.clear();
                                _loadCommentCount(itemKey, commentKontenId);
                                if (modalContext.mounted) {
                                  setModalState(() {
                                    commentsFuture = ApiService.fetchComments(
                                      commentKontenId,
                                    );
                                  });
                                }
                                if (mounted) {
                                  setState(() {});
                                }
                              } else {
                                if (modalContext.mounted) {
                                  ScaffoldMessenger.of(modalContext)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            res.message.isNotEmpty
                                                ? res.message
                                                : 'Gagal mengirim komentar',
                                          ),
                                        ),
                                      );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        commentController.dispose();
      });
    });
  }

  Widget _buildCommentItem(
    String idKomentar,
    String author,
    String comment,
    StateSetter setModalState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.mintSoft,
            child: Text(
              author.isNotEmpty ? author.substring(0, 1).toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showReportDialog(idKomentar),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.flag_outlined,
                          size: 13,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF465A50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(String idKomentar) {
    final List<String> alasanList = [
      'Spam atau Promosi',
      'Bahasa Kasar / Menyinggung',
      'Informasi Palsu',
      'Lainnya',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Laporkan Komentar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih alasan mengapa komentar ini dilaporkan:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            ...alasanList.map(
              (alasan) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  alasan,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF465A50),
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final res = await ApiService.reportComment(
                    idKomentar,
                    alasan,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          res.message.isNotEmpty
                              ? res.message
                              : 'Laporan terkirim',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWawasanDetail(String title, String desc, String author) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              author,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF465A50),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContributorModal() async {
    if (!UserAccountData.isLoggedIn) {
      AuthRequiredModal.show(
        context,
        title: 'Upload Konten Memerlukan Akun',
        message:
            'Silakan masuk atau daftar akun terlebih dahulu untuk mengunggah edukasi dan tips ke komunitas TR4SH!',
        icon: Icons.video_collection_rounded,
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HalamanUploadKonten()),
    );
    _loadEdukasiPublik();
  }

  List<int> _buildVisiblePageNumbers(int currentPage, int totalPages) {
    if (totalPages <= 5) {
      return List.generate(totalPages, (index) => index + 1);
    }
    final pages = <int>{1, totalPages, currentPage};
    if (currentPage - 1 > 1) pages.add(currentPage - 1);
    if (currentPage + 1 < totalPages) pages.add(currentPage + 1);
    final sorted = pages.toList()..sort();
    return sorted;
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int startIndex,
    required int endIndex,
  }) {
    final visiblePages = _buildVisiblePageNumbers(currentPage, totalPages);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menampilkan ${startIndex + 1}–$endIndex dari $totalItems konten',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Hal. $currentPage / $totalPages',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (totalPages > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: currentPage > 1
                      ? () => _changePage(currentPage - 1, totalPages)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: currentPage > 1
                          ? const Color(0xFFE8F5EE)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: currentPage > 1
                          ? AppColors.darkGreen
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                for (int i = 0; i < visiblePages.length; i++) ...[
                  if (i > 0 && visiblePages[i] - visiblePages[i - 1] > 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => _changePage(visiblePages[i], totalPages),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: visiblePages[i] == currentPage
                              ? AppColors.darkGreen
                              : const Color(0xFFF1F8F4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: visiblePages[i] == currentPage
                                ? AppColors.darkGreen
                                : const Color(0xFFDCEFE3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${visiblePages[i]}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: visiblePages[i] == currentPage
                                ? AppColors.limeAccent
                                : AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                InkWell(
                  onTap: currentPage < totalPages
                      ? () => _changePage(currentPage + 1, totalPages)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: currentPage < totalPages
                          ? const Color(0xFFE8F5EE)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: currentPage < totalPages
                          ? AppColors.darkGreen
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionKontenBaruEdukasi() {
    final fullList = _filteredEdukasi;
    final bool isNewestTab = _selectedCategoryIndex == 0;
    final bool isSavedTab = _selectedCategoryIndex == 6;

    final int totalItems = fullList.length;
    final int totalPages =
        totalItems == 0 ? 1 : (totalItems / _itemsPerPage).ceil();
    final int safePage = _currentPage.clamp(1, totalPages);
    final int startIndex = (safePage - 1) * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final List<dynamic> list =
        totalItems == 0 ? [] : fullList.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8F4E4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isSavedTab
                          ? Icons.bookmark_rounded
                          : Icons.new_releases_rounded,
                      size: 16,
                      color: const Color(0xFF1B6B44),
                    ),
                  ),
                  const SizedBox(width: 8),
                  isSavedTab
                      ? const Text(
                          'Konten Disimpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        )
                      : RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                            ),
                            children: [
                              TextSpan(text: 'Konten T'),
                              TextSpan(
                                text: 'R4',
                                style: TextStyle(color: Colors.blue),
                              ),
                              TextSpan(text: 'SH'),
                            ],
                          ),
                        ),
                ],
              ),
              if (totalItems > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.limeAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isSavedTab
                        ? '$totalItems Tersimpan'
                        : isNewestTab
                        ? '$totalItems Terbaru'
                        : '$totalItems Topik',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingEdukasi)
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            )
          else if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5EE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSavedTab
                          ? Icons.bookmark_border_rounded
                          : isNewestTab
                          ? Icons.schedule_rounded
                          : Icons.search_off_rounded,
                      size: 24,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isSavedTab
                        ? 'Belum ada konten yang disimpan'
                        : isNewestTab
                        ? 'Belum ada konten terbaru dalam 1 bulan terakhir'
                        : 'Tidak ada konten ditemukan',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSavedTab
                        ? 'Tekan ikon bookmark pada konten edukasi untuk menyimpannya di sini.'
                        : isNewestTab
                        ? 'Pilih tab Semua untuk melihat seluruh arsip konten edukasi TR4SH.'
                        : 'Coba ubah kata kunci pencarian atau pilih kategori lainnya.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                  if (isSavedTab || isNewestTab) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _selectCategory(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.explore_outlined, size: 16),
                      label: const Text(
                        'Lihat Semua Konten',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = list[index];
                final itemMap = item is Map
                    ? Map<String, dynamic>.from(item)
                    : <String, dynamic>{};
                final title = itemMap['title']?.toString() ?? 'Edukasi TR4SH';
                final author =
                    itemMap['penulis']?.toString() ?? 'Komunitas TR4SH';
                final jenis =
                    itemMap['jenis_edukasi']?.toString() ??
                    'Edukasi Lingkungan';
                final mediaUrl = itemMap['media_url']?.toString() ?? '';
                final tipeMedia =
                    itemMap['tipe_media']?.toString() ?? 'Video YouTube';

                final bool isVideo =
                    tipeMedia.toLowerCase().contains('video') ||
                    mediaUrl.contains('youtube.com') ||
                    mediaUrl.contains('youtu.be');

                final thumb = isVideo
                    ? _getYoutubeThumbnail(mediaUrl)
                    : mediaUrl;
                final itemKey = _getItemKey(itemMap);
                final isSaved = _isItemSaved(itemMap);
                final commentsCount = _commentCounts[itemKey] ?? 0;

                return InkWell(
                  onTap: () => _showContentDetailModal(itemMap),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSavedTab
                            ? const Color(0xFFB7E4C7)
                            : AppColors.cardBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (thumb != null && thumb.startsWith('http'))
                                Image.network(
                                  thumb,
                                  width: 100,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      Container(
                                        width: 100,
                                        height: 75,
                                        color: AppColors.darkGreen,
                                        child: Icon(
                                          isVideo
                                              ? Icons.videocam_rounded
                                              : Icons.image_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                )
                              else
                                Container(
                                  width: 100,
                                  height: 75,
                                  color: AppColors.darkGreen,
                                  child: Icon(
                                    isVideo
                                        ? Icons.videocam_rounded
                                        : Icons.image_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              if (isVideo) ...[
                                Container(
                                  width: 100,
                                  height: 75,
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.limeAccent,
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.darkGreen,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD8F4E4),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        jenis,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1B6B44),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _toggleSaveContent(itemMap),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSaved
                                            ? const Color(0xFFE8F5EE)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            size: 17,
                                            color: AppColors.darkGreen,
                                          ),
                                          if (isSavedTab) ...[
                                            const SizedBox(width: 3),
                                            const Text(
                                              'Tersimpan',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.darkGreen,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Oleh: $author',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF1E8850),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showContentDetailModal(itemMap),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F8F4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDCEFE3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 13,
                                        color: AppColors.darkGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Komentar ($commentsCount)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildPaginationControls(
              currentPage: safePage,
              totalPages: totalPages,
              totalItems: totalItems,
              startIndex: startIndex,
              endIndex: endIndex,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => _currentPage = 1);
            await Future.wait([_loadSavedContents(), _loadEdukasiPublik()]);
          },
          color: AppColors.darkGreen,
          backgroundColor: AppColors.limeAccent,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeaderKonten(
                  isBookmarked: _selectedCategoryIndex == 6,
                  hasUnreadNotification: true,
                  onBookmarkTap: () =>
                      _selectCategory(_selectedCategoryIndex == 6 ? 0 : 6),
                  onNotificationTap: _navigateToNotifikasi,
                ),
                const SizedBox(height: 6),
                SearchKontenBar(
                  controller: _searchController,
                  onFilterTap: _showFilterSheet,
                  onChanged: (q) => setState(() {
                    _searchQuery = q;
                    _currentPage = 1;
                  }),
                ),
                const SizedBox(height: 12),
                KategoriKontenTabs(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelectIndex: _selectCategory,
                ),
                const SizedBox(height: 16),
                _buildSectionKontenBaruEdukasi(),
                const SizedBox(height: 20),
                SectionWawasanKomunitas(
                  onSeeAllTap: () {},
                  onCardQnATap: () => _showWawasanDetail(
                    'Apakah sampah dapat berguna kembali?',
                    'Tentu! Lebih dari 78% sampah an-organik rumah tangga dapat dikonversi menjadi produk bernilai guna.',
                    'Oleh: Budi Prakoso • Komunitas TR4SH',
                  ),
                  onCardKreasiTap: () => _showWawasanDetail(
                    'Kreasi Daur Ulang: Tatakan Gelas Marmer HDPE',
                    'Ide sulap tutup botol plastik menjadi tatakan gelas minimalis yang tahan panas dan bernilai ekonomis.',
                    'Dilihat 892 kali • Terverifikasi Komunitas',
                  ),
                ),
                const SizedBox(height: 20),
                BannerKontributorKonten(onBerbagiIdeTap: _showContributorModal),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showContributorModal,
        backgroundColor: AppColors.limeAccent,
        foregroundColor: AppColors.darkGreen,
        icon: const Icon(Icons.video_call_rounded, size: 22),
        label: const Text(
          'Upload Konten',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
    );
  }
}