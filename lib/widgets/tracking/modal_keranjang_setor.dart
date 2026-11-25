import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/models/tracking_setor_model.dart';

class ModalKeranjangSetor {
  ModalKeranjangSetor._();

  static const double _minBeratItem = 0.1;
  static const double _maxTotalBerat = 50.0;

  static String _formatRupiah(double nilai) {
    final formatted = nilai.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  static void show({
    required BuildContext context,
    required int activeUserId,
    required int initialIdKategori,
    required String initialCategory,
    required double initialWeight,
    required double hargaPerKg,
    required List<KategoriSampahModel> daftarKategoriDatabase,
    required VoidCallback onSuccess,
  }) {
    final double clampedInitial = double.parse(
      initialWeight.clamp(_minBeratItem, _maxTotalBerat).toStringAsFixed(1),
    );
    final List<KeranjangSetorItemModel> keranjangSetor = [
      KeranjangSetorItemModel(
        idKategori: initialIdKategori,
        namaKategori: initialCategory,
        jumlah: clampedInitial,
        hargaPerKg: hargaPerKg,
      ),
    ];

    XFile? pickedImage;
    bool isSubmitting = false;
    String? errorMessage;

    double hitungTotalBerat() {
      final sum = keranjangSetor.fold<double>(
        0.0,
        (acc, item) => acc + item.jumlah,
      );
      return double.parse(sum.toStringAsFixed(1));
    }

    double hitungTotalRupiah() {
      return keranjangSetor.fold<double>(
        0.0,
        (acc, item) => acc + (item.jumlah * item.hargaPerKg),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final double totalBerat = hitungTotalBerat();
          final double totalEstimasiRupiah = hitungTotalRupiah();

          return PopScope(
            canPop: !isSubmitting,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Keranjang Jual Sampah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        Text(
                          'Maks. 50 kg',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Daftar Sampah Ramah Lingkungan yang Akan Disetor:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: keranjangSetor.length,
                      itemBuilder: (_, idx) {
                        final item = keranjangSetor[idx];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgScreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaKategori,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreen,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatRupiah(
                                        item.jumlah * item.hargaPerKg,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E8850),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: isSubmitting
                                        ? null
                                        : () {
                                            if (item.jumlah > _minBeratItem) {
                                              setModalState(() {
                                                errorMessage = null;
                                                final next = (item.jumlah - 0.1)
                                                    .clamp(
                                                      _minBeratItem,
                                                      _maxTotalBerat,
                                                    );
                                                item.updateBerat(next);
                                              });
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: isSubmitting
                                        ? null
                                        : () async {
                                            final editCtrl =
                                                TextEditingController(
                                              text: item.jumlah
                                                  .toStringAsFixed(1),
                                            );
                                            final double beratItemLain =
                                                double.parse(
                                              (hitungTotalBerat() - item.jumlah)
                                                  .toStringAsFixed(1),
                                            );
                                            final double maxItemIni =
                                                double.parse(
                                              (_maxTotalBerat - beratItemLain)
                                                  .clamp(
                                                    _minBeratItem,
                                                    _maxTotalBerat,
                                                  )
                                                  .toStringAsFixed(1),
                                            );
                                            String? dialogError;

                                            await showDialog(
                                              context: modalContext,
                                              builder: (ctx) => StatefulBuilder(
                                                builder: (
                                                  ctx,
                                                  setDialogState,
                                                ) =>
                                                    AlertDialog(
                                                  title: Text(
                                                    'Edit Berat (${item.namaKategori})',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextField(
                                                        controller: editCtrl,
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(
                                                          decimal: true,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          suffixText: 'kg',
                                                          hintText:
                                                              '0.1 – ${maxItemIni.toStringAsFixed(1)}',
                                                          errorText:
                                                              dialogError,
                                                          border:
                                                              const OutlineInputBorder(),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        'Batas maksimal item ini: ${maxItemIni.toStringAsFixed(1)} kg (maks. 50 kg per penjualan).',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            AppColors.darkGreen,
                                                      ),
                                                      onPressed: () {
                                                        final normalized =
                                                            editCtrl.text
                                                                .trim()
                                                                .replaceAll(
                                                                  ',',
                                                                  '.',
                                                                );
                                                        final double? val =
                                                            double.tryParse(
                                                          normalized,
                                                        );
                                                        if (val == null) {
                                                          setDialogState(() {
                                                            dialogError =
                                                                'Masukkan angka yang valid.';
                                                          });
                                                          return;
                                                        }
                                                        final double rounded =
                                                            double.parse(
                                                          val.toStringAsFixed(
                                                            1,
                                                          ),
                                                        );
                                                        if (rounded <
                                                            _minBeratItem) {
                                                          setDialogState(() {
                                                            dialogError =
                                                                'Berat minimal 0.1 kg.';
                                                          });
                                                          return;
                                                        }
                                                        if (rounded >
                                                            maxItemIni) {
                                                          setDialogState(() {
                                                            dialogError =
                                                                'Maksimal ${maxItemIni.toStringAsFixed(1)} kg (total maks. 50 kg).';
                                                          });
                                                          return;
                                                        }
                                                        setModalState(() {
                                                          errorMessage = null;
                                                          item.updateBerat(
                                                            rounded,
                                                          );
                                                        });
                                                        Navigator.pop(ctx);
                                                      },
                                                      child: const Text(
                                                        'Simpan',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                            Future.delayed(
                                              const Duration(milliseconds: 300),
                                              editCtrl.dispose,
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        '${item.jumlah.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: isSubmitting
                                        ? null
                                        : () {
                                            final nextTotal = double.parse(
                                              (hitungTotalBerat() + 0.1)
                                                  .toStringAsFixed(1),
                                            );
                                            if (nextTotal <= _maxTotalBerat) {
                                              setModalState(() {
                                                errorMessage = null;
                                                item.updateBerat(
                                                  item.jumlah + 0.1,
                                                );
                                              });
                                            } else {
                                              setModalState(() {
                                                errorMessage =
                                                    'Total berat dalam satu penjualan maksimal 50.0 kg.';
                                              });
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: const Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                  if (keranjangSetor.length > 1) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: isSubmitting
                                          ? null
                                          : () {
                                              setModalState(() {
                                                errorMessage = null;
                                                keranjangSetor.removeAt(idx);
                                              });
                                            },
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGreen,
                        side: const BorderSide(color: AppColors.darkGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 42),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              if (hitungTotalBerat() >= _maxTotalBerat) {
                                setModalState(() {
                                  errorMessage =
                                      'Total berat sudah mencapai batas maksimal 50.0 kg. Kurangi berat kategori lain untuk menambah kategori baru.';
                                });
                                return;
                              }
                              _showPilihKategoriDialog(
                                modalContext: modalContext,
                                daftarKategoriDatabase: daftarKategoriDatabase,
                                keranjangSetor: keranjangSetor,
                                hitungTotalBerat: hitungTotalBerat,
                                onAdded: () => setModalState(() {
                                  errorMessage = null;
                                }),
                                onError: (msg) => setModalState(() {
                                  errorMessage = msg;
                                }),
                              );
                            },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Tambah Kategori Sampah Lain',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Ringkasan total berat & estimasi rupiah
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF98CCA8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Berat Penjualan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1E8850),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${totalBerat.toStringAsFixed(1)} / 50.0 kg',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Estimasi Pendapatan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1E8850),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatRupiah(totalEstimasiRupiah),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bukti Foto Fisik Sampah Gabungan (Wajib):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: isSubmitting
                          ? null
                          : () async {
                              try {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 80,
                                );
                                if (pickedFile != null &&
                                    modalContext.mounted) {
                                  setModalState(() {
                                    pickedImage = pickedFile;
                                    errorMessage = null;
                                  });
                                }
                              } catch (_) {
                                if (modalContext.mounted) {
                                  setModalState(() {
                                    errorMessage =
                                        'Gagal membuka kamera. Pastikan izin kamera telah diaktifkan.';
                                  });
                                }
                              }
                            },
                      child: Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.bgScreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: pickedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.network(
                                        pickedImage!.path,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.file(
                                        File(pickedImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppColors.darkGreen,
                                    size: 26,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Ketuk untuk Ambil 1 Foto Gabungan Semua Sampah',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFC62828),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (hitungTotalBerat() > _maxTotalBerat) {
                                  setModalState(() {
                                    errorMessage =
                                        'Total berat dalam satu penjualan maksimal 50.0 kg.';
                                  });
                                  return;
                                }

                                if (pickedImage == null) {
                                  setModalState(() {
                                    errorMessage =
                                        'Harap lampirkan foto bukti fisik gabungan sampah terlebih dahulu!';
                                  });
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                  errorMessage = null;
                                });

                                final itemsPayload = keranjangSetor
                                    .map((item) => item.toApiPayload())
                                    .toList();

                                final res =
                                    await ApiService.kirimSetorSampahMultipart(
                                  idUser: activeUserId,
                                  items: itemsPayload,
                                  sumber: 'Pengantaran Mandiri ke Bank Sampah',
                                  fotoFile: pickedImage,
                                );

                                if (res.success) {
                                  if (modalContext.mounted) {
                                    Navigator.of(modalContext).pop();
                                  }
                                  onSuccess();
                                  if (context.mounted) {
                                    _showSuccessBottomSheet(
                                      context,
                                      keranjangSetor.length,
                                    );
                                  }
                                } else if (modalContext.mounted) {
                                  setModalState(() {
                                    isSubmitting = false;
                                    errorMessage =
                                        'Gagal mengirim: ${res.message}';
                                  });
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Kirim Pengajuan ke Admin',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static void _showPilihKategoriDialog({
    required BuildContext modalContext,
    required List<KategoriSampahModel> daftarKategoriDatabase,
    required List<KeranjangSetorItemModel> keranjangSetor,
    required double Function() hitungTotalBerat,
    required VoidCallback onAdded,
    required ValueChanged<String> onError,
  }) {
    showDialog(
      context: modalContext,
      builder: (dialogContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final filteredCategories = daftarKategoriDatabase.where((cat) {
              return cat.namaKategori
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
            }).toList();

            return AlertDialog(
              title: const Text(
                'Pilih Kategori Ramah Lingkungan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: false,
                      onChanged: (value) {
                        setStateDialog(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari kategori sampah...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.darkGreen,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.darkGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: daftarKategoriDatabase.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            )
                          : filteredCategories.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Kategori tidak ditemukan',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredCategories.length,
                                  itemBuilder: (_, index) {
                                    final cat = filteredCategories[index];
                                    return ListTile(
                                      title: Text(
                                        cat.namaKategori,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${_formatRupiah(cat.hargaPerKg)} / kg',
                                      ),
                                      onTap: () {
                                        Navigator.pop(dialogContext);

                                        final bool alreadyExists =
                                            keranjangSetor.any(
                                          (element) =>
                                              element.idKategori ==
                                              cat.idKategori,
                                        );

                                        if (alreadyExists) {
                                          onError(
                                            'Kategori "${cat.namaKategori}" sudah ada di keranjang!',
                                          );
                                          return;
                                        }

                                        final double sisaKapasitas =
                                            double.parse(
                                          (_maxTotalBerat - hitungTotalBerat())
                                              .toStringAsFixed(1),
                                        );
                                        if (sisaKapasitas < _minBeratItem) {
                                          onError(
                                            'Total berat sudah mencapai batas maksimal 50.0 kg.',
                                          );
                                          return;
                                        }

                                        final double beratAwal =
                                            sisaKapasitas >= 1.0
                                                ? 1.0
                                                : sisaKapasitas;
                                        keranjangSetor.add(
                                          KeranjangSetorItemModel(
                                            idKategori: cat.idKategori,
                                            namaKategori: cat.namaKategori,
                                            jumlah: beratAwal,
                                            hargaPerKg: cat.hargaPerKg,
                                          ),
                                        );
                                        onAdded();
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void _showSuccessBottomSheet(
    BuildContext context,
    int totalCategories,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (successContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFD6F5E1),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pengajuan Berhasil Dikirim!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Total $totalCategories kategori sampah telah berhasil dikirim ke sistem dengan status "Pending". Silakan tunggu verifikasi admin sebelum mengantar ke cabang.',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(successContext),
                child: const Text(
                  'Mengerti & Lihat Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}