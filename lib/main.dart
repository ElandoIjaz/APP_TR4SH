import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TR4SH! - Bank Sampah Digital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgScreen,
      ),
      home: const HalamanBeranda(),
    );
  }
}
