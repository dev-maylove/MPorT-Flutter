import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final u = auth.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                  child: Text(
                    (u?.name.isNotEmpty == true ? u!.name[0] : '?').toUpperCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.cyan),
                  ),
                ),
                const SizedBox(height: 12),
                Text(u?.name ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(u?.email ?? '-', style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (u?.role ?? 'user').toUpperCase(),
                    style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (u?.phone != null)
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined, color: AppColors.muted),
                title: const Text('Telepon'),
                subtitle: Text(u?.phone ?? ''),
              ),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
