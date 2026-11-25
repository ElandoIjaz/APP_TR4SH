import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class TrackingHelper {
  TrackingHelper._();

  static String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Baru saja';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute WIB';
    } catch (_) {
      return rawDate;
    }
  }

  static IconData getKategoriIcon(String kategoriName) {
    final name = kategoriName.toLowerCase();
    if (name.contains('plastik')) return Icons.water_drop_outlined;
    if (name.contains('kertas')) return Icons.inventory_2_outlined;
    if (name.contains('logam') ||
        name.contains('besi') ||
        name.contains('kaleng')) {
      return Icons.hardware_rounded;
    }
    if (name.contains('kaca') || name.contains('beling')) {
      return Icons.wine_bar_rounded;
    }
    if (name.contains('organik')) return Icons.eco_rounded;
    return Icons.category_rounded;
  }

  static Color getKategoriColor(String kategoriName) {
    final name = kategoriName.toLowerCase();
    if (name.contains('plastik')) return const Color(0xFF1E8850);
    if (name.contains('kertas')) return const Color(0xFFE65100);
    if (name.contains('logam') ||
        name.contains('besi') ||
        name.contains('kaleng')) {
      return const Color(0xFF0D47A1);
    }
    if (name.contains('kaca') || name.contains('beling')) {
      return const Color(0xFF7B1FA2);
    }
    if (name.contains('organik')) return const Color(0xFFEF6C00);
    return AppColors.darkGreen;
  }
}