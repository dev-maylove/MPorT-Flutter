import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  DashboardSummary? _summary;
  String? _error;
  bool _loading = true;

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
      await auth.fetchMe();
      final res = await auth.client.get(ApiConfig.dashboard, auth: true);
      if (!mounted) {
        return;
      }
      if (res.isOk && res.json != null) {
        setState(() {
          _summary = DashboardSummary.fromJson(res.json!);
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.isOk ? 'Data kosong' : res.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final s = _summary;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.cyan,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('MPorT'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _load,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '${_greet()}, ${user?.name ?? 'Pelanggan'}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ringkasan layanan MandalaNet Anda',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.cyan),
                    ),
                  )
                else if (_error != null)
                  AppCard(
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                  )
                else ...[
                  Row(
                    children: [
                      StatChip(
                        label: 'Belum bayar',
                        value: '${s?.unpaidCount ?? 0}',
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      StatChip(
                        label: 'Jatuh tempo',
                        value: '${s?.overdueCount ?? 0}',
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 10),
                      StatChip(
                        label: 'Lunas',
                        value: '${s?.paidCount ?? 0}',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total tunggakan', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          s?.totalUnpaidFormatted ?? 'Rp 0',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/app/invoices'),
                                icon: const Icon(Icons.receipt_long, size: 18),
                                label: const Text('Tagihan'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.go('/app/packages'),
                                icon: const Icon(Icons.wifi, size: 18),
                                label: const Text('Paket'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (s != null && s.recentInvoices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Tagihan terbaru',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ...s.recentInvoices.take(5).map(
                      (inv) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          onTap: () => context.go('/app/invoices'),
                          child: Row(
                            children: [
                              Icon(
                                inv.isPaid
                                    ? Icons.check_circle_rounded
                                    : inv.isOverdue
                                        ? Icons.warning_amber_rounded
                                        : Icons.schedule_rounded,
                                color: inv.isPaid
                                    ? AppColors.success
                                    : inv.isOverdue
                                        ? AppColors.danger
                                        : AppColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text(
                                      inv.packageName ?? inv.period ?? inv.status,
                                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                inv.displayAmount,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.cyan),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
