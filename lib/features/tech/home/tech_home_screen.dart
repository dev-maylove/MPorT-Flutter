import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class TechHomeScreen extends StatelessWidget {
  const TechHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final duty = user?.dutyStatus ?? 'offline';
    final dutyLabel = switch (duty) {
      'online' || 'available' || 'on_duty' => 'On Duty',
      'busy' => 'Istirahat',
      _ => 'Off Duty',
    };
    final dutyColor = switch (duty) {
      'online' || 'available' || 'on_duty' => AppColors.success,
      'busy' => AppColors.warning,
      _ => AppColors.muted,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Teknisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthService>().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.tech.withValues(alpha: 0.2),
                  child: const Icon(Icons.engineering_rounded, color: AppColors.tech),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Teknisi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: dutyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(dutyLabel, style: TextStyle(color: dutyColor, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Menu cepat', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.work_rounded,
            title: 'Jobs / Work Order',
            subtitle: 'Tugas instalasi & gangguan',
            onTap: () => context.go('/tech/jobs'),
          ),
          _MenuTile(
            icon: Icons.inventory_2_rounded,
            title: 'Material & Stok',
            subtitle: 'Stok, pemakaian, request',
            onTap: () => context.go('/tech/materials'),
          ),
          _MenuTile(
            icon: Icons.map_rounded,
            title: 'Peta coverage',
            subtitle: 'Lokasi & area kerja',
            onTap: () => context.go('/tech/map'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.tech, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
