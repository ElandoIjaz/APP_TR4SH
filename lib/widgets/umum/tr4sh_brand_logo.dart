import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class Tr4shBrandLogo extends StatelessWidget {
  final String? subtitle;

  const Tr4shBrandLogo({
    super.key,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo_sampah.png',
          width: 38,
          height: 38,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20, //tinggi layout
              child: Transform.scale(
                scale: 2, //bisa diubah buat atur besar tulisan
                alignment: Alignment.centerLeft,
                child: Image.asset(
              'assets/images/logo_trash.png',
              height: 20,
              fit: BoxFit.contain,
            ),
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 0),
              Transform.translate(
                offset: const Offset(6.0, 0.0),
                child: Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}