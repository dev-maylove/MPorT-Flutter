import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/models/invoice_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<InvoiceModel> _items = [];
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
      final res = await auth.client.get(ApiConfig.invoices, auth: true);
      if (!mounted) return;
      if (!res.isOk || res.json == null) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final raw = res.json!['data'] ?? res.json!['invoices'] ?? [];
      final list = <InvoiceModel>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(InvoiceModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(InvoiceModel inv) {
    if (inv.isPaid) return AppColors.success;
    if (inv.isOverdue) return AppColors.danger;
    return AppColors.warning;
  }

  Future<void> _confirmWa(InvoiceModel inv) async {
    final text = Uri.encodeComponent(
      'Konfirmasi pembayaran\nNo: ${inv.invoiceNumber}\nJumlah: ${inv.displayAmount}\nStatus: ${inv.status}',
    );
    final uri = Uri.parse('https://wa.me/628567900018?text=$text');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Tagihan')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.cyan,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: AppColors.danger)))])
                : _items.isEmpty
                    ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Tidak ada tagihan.', style: TextStyle(color: AppColors.muted)))])
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final inv = _items[i];
                          final c = _statusColor(inv);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: c.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: c.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(inv.status.toUpperCase(), style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(inv.displayAmount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.cyan)),
                                  if (inv.packageName != null) Text(inv.packageName!, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                  if (inv.dueDate != null) Text('Jatuh tempo: ${inv.dueDate}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  if (inv.isUnpaid) ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _confirmWa(inv),
                                      icon: const Icon(Icons.chat_rounded, size: 18),
                                      label: const Text('Konfirmasi via WhatsApp'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
