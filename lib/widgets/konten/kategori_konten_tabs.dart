import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class KategoriKontenTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final List<String> categories;

  const KategoriKontenTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    this.categories = const [
      'Konten Terbaru',
      'Event',
      'Profil',
      'Kategori Daur Ulang',
      'Komunitas',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;
          final String title = categories[index];

          return GestureDetector(
            onTap: () => onSelectIndex(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.darkGreen
                      : AppColors.cardBorder,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.darkGreen.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.limeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.limeAccent
                          : const Color(0xFF4C6656),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
