import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../user/packages/packages_screen.dart';
import '../../core/theme/app_theme.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mode Tamu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Masuk', style: TextStyle(color: AppColors.cyan)),
          ),
        ],
      ),
      body: const PackagesScreen(),
    );
  }
}
