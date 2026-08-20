import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  DashboardSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    try {
      final res = await auth.client.get(ApiConfig.dashboard, auth: true);
      if (!mounted) return;
      if (res.isOk && res.json != null) {
        setState(() {
          _summary = DashboardSummary.fromJson(res.json!);
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final s = _summary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard Operasional'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthService>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.admin,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Halo, ${user?.name ?? 'Admin'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Pusat kendali MandalaNet / MPorT',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.admin)))
            else if (_error != null)
              AppCard(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))
            else ...[
              Row(
                children: [
                  StatChip(label: 'Unpaid', value: '${s?.unpaidCount ?? 0}', color: AppColors.warning),
                  const SizedBox(width: 8),
                  StatChip(label: 'Overdue', value: '${s?.overdueCount ?? 0}', color: AppColors.danger),
                  const SizedBox(width: 8),
                  StatChip(label: 'Paid', value: '${s?.paidCount ?? 0}', color: AppColors.success),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total tunggakan', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    Text(
                      s?.totalUnpaidFormatted ?? 'Rp 0',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.admin),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Modul', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            _AdminMenu(
              icon: Icons.people_rounded,
              title: 'Pelanggan',
              onTap: () => context.go('/admin/customers'),
            ),
            _AdminMenu(
              icon: Icons.receipt_long_rounded,
              title: 'Invoice & pembayaran',
              onTap: () => context.go('/admin/invoices'),
            ),
            _AdminMenu(
              icon: Icons.manage_accounts_rounded,
              title: 'Users & roles',
              onTap: () => context.go('/admin/users'),
            ),
            _AdminMenu(
              icon: Icons.engineering_rounded,
              title: 'Area teknisi',
              onTap: () => context.go('/tech'),
            ),
            _AdminMenu(
              icon: Icons.person_rounded,
              title: 'Portal pelanggan',
              onTap: () => context.go('/app'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _AdminMenu({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.admin),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
