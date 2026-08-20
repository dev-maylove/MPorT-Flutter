import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final res = await auth.client.get(ApiConfig.customers, auth: true);
      if (!mounted) return;
      if (!res.isOk) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final raw = res.json?['data'] ?? res.json?['customers'] ?? [];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Pelanggan')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.admin,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.admin))
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: AppColors.danger)))])
                : _items.isEmpty
                    ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Tidak ada data pelanggan.', style: TextStyle(color: AppColors.muted)))])
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final c = _items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (c['name'] ?? c['customer_name'] ?? 'Customer #${c['id']}').toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  if (c['email'] != null) Text(c['email'].toString(), style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                  if (c['status'] != null)
                                    Text('Status: ${c['status']}', style: const TextStyle(color: AppColors.admin, fontSize: 12)),
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
