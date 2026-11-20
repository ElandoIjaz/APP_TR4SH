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
  int _selectedCategoryIndex = 0;
  bool _isHeaderBookmarked = false;
  final TextEditingController _searchController = TextEditingController();
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
    if (UserAccountData.isGuest) return null;
    return UserAccountData.currentUserId;
  }

  String _getUserBookmarkPrefsKey() {
    final userId = _resolveActiveUserId();
    if (userId != null && userId > 0) {
      return 'tr4sh_saved_konten_user_$userId';
    }
    if (UserAccountData.isGuest) {
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
    if (itemMap['id_konten'] != null && itemMap['id_edukasi'] == null) {
      return 'user';
    }
    if (itemMap['id_user'] != null && itemMap['id_edukasi'] == null) {
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
        final uri = Uri.parse(
          '${ApiConfig.baseUrl}/simpan-konten?id_user=$userId',
        );
        final res = await http.get(
          uri,
          headers: {'Accept': 'application/json'},
        );
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
    final bool willSave = !_savedContentKeys.contains(itemKey);

    setState(() {
      if (willSave) {
        _savedContentKeys.add(itemKey);
      } else {
        _savedContentKeys.remove(itemKey);
      }
    });
    onStateChanged?.call();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _getUserBookmarkPrefsKey(),
      _savedContentKeys.toList(),
    );

    final userId = _resolveActiveUserId();
    final kontenId = _getItemNumericId(itemMap);
    final sumber = _getItemSumber(itemMap);

    if (userId != null && userId > 0 && kontenId != null) {
      try {
        final uri = Uri.parse('${ApiConfig.baseUrl}/simpan-konten/toggle');
        final res = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'id_user': userId,
            'sumber_konten': sumber,
            'konten_id': kontenId,
          }),
        );
        if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map && decoded['saved'] is bool) {
            final serverSaved = decoded['saved'] as bool;
            setState(() {
              if (serverSaved) {
                _savedContentKeys.add(itemKey);
              } else {
                _savedContentKeys.remove(itemKey);
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

    if (_selectedCategoryIndex == 6) {
      list = list.where((item) {
        final map = item is Map
            ? Map<String, dynamic>.from(item)
            : <String, dynamic>{};
        return _savedContentKeys.contains(_getItemKey(map));
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

  @override
  void dispose() {
    _searchController.dispose();
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
                    setState(() => _selectedCategoryIndex = idx);
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
          final isSaved = _savedContentKeys.contains(itemKey);

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

  Widget _buildSectionKontenBaruEdukasi() {
    final list = _filteredEdukasi;

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
                    child: const Icon(
                      Icons.new_releases_rounded,
                      size: 16,
                      color: Color(0xFF1B6B44),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
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
              if (list.isNotEmpty)
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
                    '${list.length} Topik',
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Text(
                  _selectedCategoryIndex == 6
                      ? 'Belum ada konten yang disimpan.'
                      : 'Tidak ada konten untuk kategori atau pencarian ini.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
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
                final isSaved = _savedContentKeys.contains(itemKey);
                final commentsCount = _commentCounts[itemKey] ?? 0;

                return InkWell(
                  onTap: () => _showContentDetailModal(itemMap),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
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
                                  Container(
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
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1B6B44),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _toggleSaveContent(itemMap),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 18,
                                        color: AppColors.darkGreen,
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
            await Future.wait([_loadSavedContents(), _loadEdukasiPublik()]);
          },
          color: AppColors.darkGreen,
          backgroundColor: AppColors.limeAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeaderKonten(
                  isBookmarked: _isHeaderBookmarked,
                  hasUnreadNotification: true,
                  onBookmarkTap: () => setState(
                    () => _isHeaderBookmarked = !_isHeaderBookmarked,
                  ),
                  onNotificationTap: _navigateToNotifikasi,
                ),
                const SizedBox(height: 6),
                SearchKontenBar(
                  controller: _searchController,
                  onFilterTap: _showFilterSheet,
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
                const SizedBox(height: 12),
                KategoriKontenTabs(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelectIndex: (idx) =>
                      setState(() => _selectedCategoryIndex = idx),
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