import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/models/package_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<PackageModel> _items = [];
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
    final client = context.read<AuthService>().client;
    try {
      final res = await client.get(ApiConfig.packages);
      if (!mounted) {
        return;
      }
      if (!res.isOk || res.json == null) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final raw = res.json!['data'] ?? res.json!['packages'] ?? [];
      final list = <PackageModel>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(PackageModel.fromJson(Map<String, dynamic>.from(e)));
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

  Future<void> _waCs(PackageModel p) async {
    final text = Uri.encodeComponent('Halo CS, saya tertarik paket ${p.name} (${p.displaySpeed}) - ${p.displayPrice}');
    final uri = Uri.parse('https://wa.me/628567900018?text=$text');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Paket Internet')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.cyan,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: AppColors.danger)))])
                : _items.isEmpty
                    ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Belum ada paket.', style: TextStyle(color: AppColors.muted)))])
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final p = _items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.cyan.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(p.displaySpeed, style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(p.displayPrice, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.cyan)),
                                  if (p.description != null && p.description!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(p.description!, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                  ],
                                  if (p.features.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    ...p.features.take(5).map(
                                      (f) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => _waCs(p),
                                    icon: const Icon(Icons.chat_rounded, size: 18),
                                    label: const Text('Hubungi CS WhatsApp'),
                                  ),
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
