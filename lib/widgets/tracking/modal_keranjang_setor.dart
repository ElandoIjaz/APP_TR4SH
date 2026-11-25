import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/models/tracking_setor_model.dart';

class ModalKeranjangSetor {
  ModalKeranjangSetor._();

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
    final double roundedWeight = double.parse(initialWeight.toStringAsFixed(1));
    final List<KeranjangSetorItemModel> keranjangSetor = [
      KeranjangSetorItemModel(
        idKategori: initialIdKategori,
        namaKategori: initialCategory,
        jumlah: roundedWeight,
        hargaPerKg: hargaPerKg,
      ),
    ];
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
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
                      'Multi-Kategori',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
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
                            child: Text(
                              item.namaKategori,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setModalState(() {
                                    if (item.jumlah > 0.1) {
                                      item.updateBerat(item.jumlah - 0.1);
                                    }
                                  });
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
                                onTap: () async {
                                  final editCtrl = TextEditingController(
                                    text: item.jumlah.toStringAsFixed(1),
                                  );
                                  await showDialog(
                                    context: modalContext,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                        'Edit Berat (${item.namaKategori})',
                                      ),
                                      content: TextField(
                                        controller: editCtrl,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: const InputDecoration(
                                          suffixText: 'kg',
                                          hintText: 'Contoh: 1.5',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.darkGreen,
                                          ),
                                          onPressed: () {
                                            final normalized = editCtrl.text
                                                .trim()
                                                .replaceAll(',', '.');
                                            final double? val =
                                                double.tryParse(normalized);
                                            if (val != null && val > 0) {
                                              setModalState(() {
                                                item.updateBerat(val);
                                              });
                                            }
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
                                onTap: () {
                                  setModalState(() {
                                    item.updateBerat(item.jumlah + 0.1);
                                  });
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
                                  onTap: () {
                                    setModalState(() {
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
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    side: const BorderSide(color: AppColors.darkGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: () {
                    _showPilihKategoriDialog(
                      modalContext: modalContext,
                      parentContext: context,
                      daftarKategoriDatabase: daftarKategoriDatabase,
                      keranjangSetor: keranjangSetor,
                      onAdded: () => setModalState(() {}),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Tambah Kategori Sampah Lain',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      setModalState(() {
                        pickedImage = pickedFile;
                      });
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
                    onPressed: () async {
                      if (pickedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Harap lampirkan foto bukti fisik gabungan sampah terlebih dahulu!',
                            ),
                          ),
                        );
                        return;
                      }

                      bool isLoadingDialogOpen = true;
                      showDialog(
                        context: modalContext,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ).then((_) => isLoadingDialogOpen = false);

                      final itemsPayload = keranjangSetor
                          .map((item) => item.toApiPayload())
                          .toList();

                      final res = await ApiService.kirimSetorSampahMultipart(
                        idUser: activeUserId,
                        items: itemsPayload,
                        sumber: 'Pengantaran Mandiri ke Bank Sampah',
                        fotoFile: pickedImage,
                      );

                      if (!context.mounted) return;
                      if (isLoadingDialogOpen && modalContext.mounted) {
                        Navigator.of(modalContext).pop();
                      }

                      if (res.success) {
                        if (modalContext.mounted) {
                          Navigator.of(modalContext).pop();
                        }
                        onSuccess();
                        _showSuccessBottomSheet(context, keranjangSetor.length);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal mengirim: ${res.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Kirim Pengajuan ke Admin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showPilihKategoriDialog({
    required BuildContext modalContext,
    required BuildContext parentContext,
    required List<KategoriSampahModel> daftarKategoriDatabase,
    required List<KeranjangSetorItemModel> keranjangSetor,
    required VoidCallback onAdded,
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
                                        'Rp ${cat.hargaPerKg.toStringAsFixed(0)} / kg',
                                      ),
                                      onTap: () {
                                        Navigator.pop(dialogContext);

                                        final bool alreadyExists =
                                            keranjangSetor.any(
                                          (element) =>
                                              element.namaKategori
                                                  .toLowerCase() ==
                                              cat.namaKategori.toLowerCase(),
                                        );

                                        if (alreadyExists) {
                                          if (parentContext.mounted) {
                                            ScaffoldMessenger.of(parentContext)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Kategori "${cat.namaKategori}" sudah ada di keranjang!',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          keranjangSetor.add(
                                            KeranjangSetorItemModel(
                                              idKategori: cat.idKategori,
                                              namaKategori: cat.namaKategori,
                                              jumlah: 1.0,
                                              hargaPerKg: cat.hargaPerKg,
                                            ),
                                          );
                                          onAdded();
                                        }
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