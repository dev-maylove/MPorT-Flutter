import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_tethering_rounded, size: 72, color: AppColors.cyan),
            SizedBox(height: 16),
            Text(
              'MPorT',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'MandalaNet Portal',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            SizedBox(height: 32),
            SizedBox(
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
