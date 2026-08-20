import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
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
      final res = await auth.client.get(ApiConfig.tickets, auth: true);
      if (!mounted) {
        return;
      }
      if (!res.isOk) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final raw = res.json?['data'] ?? res.json?['tickets'] ?? [];
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
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _createTicket() async {
    final subject = TextEditingController();
    final description = TextEditingController();
    String priority = 'normal';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Ticket baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subject,
                  decoration: const InputDecoration(labelText: 'Subjek *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi *',
                    hintText: 'Jelaskan gangguan / permintaan Anda',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Prioritas'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (v) => setLocal(() => priority = v ?? 'normal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kirim')),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) {
      return;
    }

    final sub = subject.text.trim();
    final desc = description.text.trim();
    if (sub.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subjek dan deskripsi wajib diisi.')),
      );
      return;
    }

    final auth = context.read<AuthService>();
    final res = await auth.client.post(
      ApiConfig.tickets,
      auth: true,
      body: {
        'subject': sub,
        'description': desc,
        'priority': priority,
      },
    );
    if (!mounted) {
      return;
    }
    if (res.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket terkirim')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Ticket Support')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTicket,
        icon: const Icon(Icons.add),
        label: const Text('Baru'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.cyan,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  )
                : _items.isEmpty
                    ? ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Belum ada ticket.', style: TextStyle(color: AppColors.muted)),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final t = _items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (t['subject'] ?? t['title'] ?? 'Ticket #${t['id']}').toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (t['status'] ?? '-').toString().toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.cyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (t['created_at'] != null)
                                    Text(
                                      t['created_at'].toString(),
                                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
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
