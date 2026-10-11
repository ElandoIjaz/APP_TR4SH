import 'package:flutter/material.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/pages/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.initConfig();
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  final Widget? initialHome;

  const MyApp({super.key, this.initialHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TR4SH! - Bank Sampah Digital',
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgScreen,
      ),
      // Gerbang autentikasi: sebelum masuk ke aplikasi harus login atau daftar akun
      home: initialHome ?? const AuthGate(),
    );
  }
}
