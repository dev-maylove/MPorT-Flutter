import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mport_logo.png',
              height: 96,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.wifi_tethering_rounded,
                size: 72,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MPorT',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'MandalaNet Portal',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
