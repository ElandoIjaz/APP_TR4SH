import 'package:flutter/material.dart';

class TombolKeluar extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const TombolKeluar({super.key, required this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onLogoutTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text(
                'Keluar',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
