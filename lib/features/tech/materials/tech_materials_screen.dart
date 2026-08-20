import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class TechMaterialsScreen extends StatefulWidget {
  const TechMaterialsScreen({super.key});

  @override
  State<TechMaterialsScreen> createState() => _TechMaterialsScreenState();
}

class _TechMaterialsScreenState extends State<TechMaterialsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _stock = [];
  List<Map<String, dynamic>> _usages = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _catalog = [];
  List<Map<String, dynamic>> _lowStock = [];
  int _lowThreshold = 2;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    try {
      final res = await auth.client.get(ApiConfig.techMaterials, auth: true);
      if (!mounted) return;
      if (!res.isOk || res.json == null) {
        var msg = res.message;
        if (res.statusCode == 404 || msg.toLowerCase().contains('could not be found')) {
          msg = 'API /api/tech/materials belum terpasang di server.\n'
              'Pasang MPorT-API-mobile-patch lalu: php artisan route:clear';
        }
        setState(() {
          _error = msg;
          _loading = false;
        });
        return;
      }
      final root = res.json!['data'] is Map
          ? Map<String, dynamic>.from(res.json!['data'] as Map)
          : res.json!;
      setState(() {
        _stock = _list(root['stock']);
        _usages = _list(root['usages']);
        _requests = _list(root['requests']);
        _catalog = _list(root['catalog']);
        _lowStock = _list(root['low_stock']);
        _lowThreshold = (root['low_threshold'] is int)
            ? root['low_threshold'] as int
            : 2;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _list(dynamic raw) {
    final out = <Map<String, dynamic>>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) out.add(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> _showRequestForm() async {
    final qtyCtrl = TextEditingController(text: '1');
    final notesCtrl = TextEditingController();
    int? materialId;
    String? materialName;
    String priority = 'normal';

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Request Material',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Material'),
                    items: _catalog
                        .map((m) {
                          final id = _asInt(m['id']);
                          return MapEntry(id, m);
                        })
                        .where((e) => e.key > 0)
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text('${e.value['name']} (stok ${e.value['stock']})'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      materialId = v;
                      final found = _catalog.where((m) => _asInt(m['id']) == v);
                      if (found.isNotEmpty) {
                        materialName = found.first['name']?.toString();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Prioritas'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    ],
                    onChanged: (v) => setLocal(() => priority = v ?? 'normal'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Catatan'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Kirim request'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (ok != true || !mounted) return;
    final auth = context.read<AuthService>();
    final res = await auth.client.post(
      ApiConfig.techMaterialRequest,
      auth: true,
      body: {
        if (materialId != null) 'material_id': materialId,
        if (materialName != null) 'material_name': materialName,
        'qty': int.tryParse(qtyCtrl.text) ?? 1,
        'priority': priority,
        'notes': notesCtrl.text.trim(),
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isOk ? 'Request terkirim' : res.message)),
    );
    if (res.isOk) _load();
  }

  Future<void> _showUsageForm() async {
    final qtyCtrl = TextEditingController(text: '1');
    final notesCtrl = TextEditingController();
    int? materialId;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Catat Pemakaian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Material'),
                items: _stock
                    .map((m) {
                      final id = _asInt(m['id']);
                      return MapEntry(id, m);
                    })
                    .where((e) => e.key > 0)
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.value['name']} (stok ${e.value['stock']})'),
                        ))
                    .toList(),
                onChanged: (v) => materialId = v,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true || materialId == null || !mounted) {
      qtyCtrl.dispose();
      notesCtrl.dispose();
      return;
    }
    final auth = context.read<AuthService>();
    final body = {
      'material_id': materialId,
      'qty': int.tryParse(qtyCtrl.text) ?? 1,
      'notes': notesCtrl.text.trim(),
    };
    qtyCtrl.dispose();
    notesCtrl.dispose();
    final res = await auth.client.post(
      ApiConfig.techMaterialUsage,
      auth: true,
      body: body,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isOk ? 'Pemakaian tercatat' : res.message)),
    );
    if (res.isOk) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Material & Stok'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: AppColors.tech,
          labelColor: AppColors.tech,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(text: 'Stok Saya'),
            Tab(text: 'Pemakaian'),
            Tab(text: 'Request'),
            Tab(text: 'Low Stock'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tab.index == 1) {
            _showUsageForm();
          } else {
            _showRequestForm();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tab.index == 1 ? 'Catat' : 'Request'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.tech))
          : _error != null
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                    ),
                  ],
                )
              : TabBarView(
                  controller: _tab,
                  children: [
                    _stockList(_stock),
                    _usageList(_usages),
                    _requestList(_requests),
                    _stockList(_lowStock.isEmpty
                        ? _stock
                            .where((m) => (m['stock'] as int? ?? 0) <= _lowThreshold)
                            .toList()
                        : _lowStock),
                  ],
                ),
    );
  }

  Widget _stockList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Kosong', style: TextStyle(color: AppColors.muted)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.tech,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final m = items[i];
          final stock = m['stock'] as int? ?? 0;
          final low = stock <= _lowThreshold;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (m['sku'] != null)
                          Text('SKU: ${m['sku']}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$stock ${m['unit'] ?? 'pcs'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: low ? AppColors.danger : AppColors.tech,
                        ),
                      ),
                      if (low)
                        const Text('LOW', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _usageList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada pemakaian', style: TextStyle(color: AppColors.muted)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.tech,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final u = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${u['material_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    '${u['qty']} ${u['unit'] ?? 'pcs'}',
                    style: const TextStyle(color: AppColors.tech),
                  ),
                  if (u['ticket_number'] != null)
                    Text('Ticket: ${u['ticket_number']}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  if (u['created_at'] != null)
                    Text('${u['created_at']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _requestList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada request', style: TextStyle(color: AppColors.muted)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.tech,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final r = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r['material_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    '${r['qty']} ${r['unit'] ?? 'pcs'} · ${r['priority'] ?? 'normal'}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (r['status'] ?? 'pending').toString().toUpperCase(),
                    style: const TextStyle(color: AppColors.tech, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
