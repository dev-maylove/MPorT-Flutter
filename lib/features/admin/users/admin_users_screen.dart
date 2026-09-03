import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  String? _roleFilter;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    final q = <String, String>{};
    if (_roleFilter != null) q['role'] = _roleFilter!;
    if (_search.text.trim().isNotEmpty) q['q'] = _search.text.trim();
    final path = q.isEmpty
        ? ApiConfig.adminUsers
        : '${ApiConfig.adminUsers}?${q.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    try {
      final res = await auth.client.get(path, auth: true);
      if (!mounted) return;
      if (!res.isOk) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final raw = res.json?['data'] ?? [];
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

  Future<void> _createOrEdit({Map<String, dynamic>? existing}) async {
    final name = TextEditingController(text: existing?['name']?.toString() ?? '');
    final email = TextEditingController(text: existing?['email']?.toString() ?? '');
    final phone = TextEditingController(text: existing?['phone']?.toString() ?? '');
    final pass = TextEditingController();
    String role = (existing?['role'] ?? 'user').toString();
    bool isActive = existing?['is_active'] != false;
    final isEdit = existing != null;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(isEdit ? 'Edit User' : 'User Baru',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
                    const SizedBox(height: 8),
                    TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 8),
                    TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telepon')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isEdit ? 'Password (kosongkan = tidak diubah)' : 'Password',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('user')),
                        DropdownMenuItem(value: 'technician', child: Text('technician')),
                        DropdownMenuItem(value: 'admin', child: Text('admin')),
                      ],
                      onChanged: (v) => setLocal(() => role = v ?? 'user'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Aktif'),
                      value: isActive,
                      activeThumbColor: AppColors.admin,
                      onChanged: (v) => setLocal(() => isActive = v),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(isEdit ? 'Simpan' : 'Tambah'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    final body = <String, dynamic>{
      'name': name.text.trim(),
      'email': email.text.trim(),
      'role': role,
      'phone': phone.text.trim(),
      'is_active': isActive,
    };
    if (pass.text.isNotEmpty) body['password'] = pass.text;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      name.dispose();
      email.dispose();
      phone.dispose();
      pass.dispose();
    });
    if (ok != true || !mounted) return;
    final auth = context.read<AuthService>();

    final res = isEdit
        ? await auth.client.put(
            '${ApiConfig.adminUsers}/${existing['id']}',
            auth: true,
            body: body,
          )
        : await auth.client.post(ApiConfig.adminUsers, auth: true, body: body);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.isOk
              ? (isEdit ? 'User diperbarui' : 'User ditambahkan')
              : res.message,
        ),
      ),
    );
    if (res.isOk) _load();
  }

  Future<void> _delete(Map<String, dynamic> user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Hapus user?'),
        content: Text('Hapus ${user['name']} (${user['email']})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final auth = context.read<AuthService>();
    final res = await auth.client.delete('${ApiConfig.adminUsers}/${user['id']}', auth: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isOk ? 'User dihapus' : res.message)),
    );
    if (res.isOk) _load();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.admin;
      case 'technician':
        return AppColors.tech;
      default:
        return AppColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Users & Roles'),
        actions: [
          PopupMenuButton<String?>(
            onSelected: (v) {
              setState(() => _roleFilter = v);
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Semua role')),
              PopupMenuItem(value: 'admin', child: Text('admin')),
              PopupMenuItem(value: 'technician', child: Text('technician')),
              PopupMenuItem(value: 'user', child: Text('user')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createOrEdit(),
        icon: const Icon(Icons.person_add),
        label: const Text('User'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Cari nama / email / HP',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _load,
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.admin))
                : _error != null
                    ? ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.admin,
                        child: _items.isEmpty
                            ? ListView(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text('Tidak ada user.', style: TextStyle(color: AppColors.muted)),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _items.length,
                                itemBuilder: (_, i) {
                                  final u = _items[i];
                                  final role = (u['role'] ?? 'user').toString();
                                  final c = _roleColor(role);
                                  final active = u['is_active'] != false;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: AppCard(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: c.withValues(alpha: 0.2),
                                            child: Text(
                                              (u['name']?.toString().isNotEmpty == true
                                                      ? u['name'].toString()[0]
                                                      : '?')
                                                  .toUpperCase(),
                                              style: TextStyle(color: c, fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${u['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                                Text('${u['email']}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 4),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: c.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(role, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      active ? 'aktif' : 'nonaktif',
                                                      style: TextStyle(
                                                        color: active ? AppColors.success : AppColors.danger,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 20),
                                            onPressed: () => _createOrEdit(existing: u),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                            onPressed: () => _delete(u),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}
