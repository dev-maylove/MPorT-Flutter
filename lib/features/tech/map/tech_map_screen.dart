import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class TechMapScreen extends StatefulWidget {
  const TechMapScreen({super.key});

  @override
  State<TechMapScreen> createState() => _TechMapScreenState();
}

class _TechMapScreenState extends State<TechMapScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _markers = [];
  LatLng _center = const LatLng(-6.7550, 111.0380);
  String _filter = 'all';
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    try {
      final res = await auth.client.get(
        '${ApiConfig.techMap}?filter=$_filter',
        auth: true,
      );
      if (!mounted) return;
      if (!res.isOk || res.json == null) {
        var msg = res.message;
        if (res.statusCode == 404 || msg.toLowerCase().contains('could not be found')) {
          msg = 'API /api/tech/map belum terpasang. Pasang MPorT-API-mobile-patch.';
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
      final list = <Map<String, dynamic>>[];
      final raw = root['markers'];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
        }
      }
      LatLng center = _center;
      final c = root['center'];
      if (c is List && c.length >= 2) {
        center = LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble());
      }
      setState(() {
        _markers = list;
        _center = center;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(_center, 12);
        } catch (_) {}
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

  List<Map<String, dynamic>> get _withGeo =>
      _markers.where((m) => m['lat'] != null && m['lng'] != null).toList();

  Future<void> _openExternal(Map<String, dynamic> m) async {
    final lat = m['lat'];
    final lng = m['lng'];
    if (lat == null || lng == null) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Peta Coverage'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filter,
            onSelected: (v) {
              setState(() => _filter = v);
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Semua')),
              PopupMenuItem(value: 'mine', child: Text('Milik saya')),
              PopupMenuItem(value: 'priority', child: Text('Prioritas tinggi')),
              PopupMenuItem(value: 'today', child: Text('Hari ini')),
              PopupMenuItem(value: 'open', child: Text('Open')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.tech))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))
              : Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'id.mandalanet.mport',
                          ),
                          MarkerLayer(
                            markers: _withGeo.map((m) {
                              final lat = (m['lat'] as num).toDouble();
                              final lng = (m['lng'] as num).toDouble();
                              final urgent = (m['priority'] == 'urgent' || m['priority'] == 'high');
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () => _showMarkerSheet(m),
                                  child: Icon(
                                    Icons.location_on,
                                    color: urgent ? AppColors.danger : AppColors.tech,
                                    size: 36,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _markers.isEmpty
                          ? const Center(
                              child: Text('Tidak ada marker', style: TextStyle(color: AppColors.muted)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _markers.length,
                              itemBuilder: (_, i) {
                                final m = _markers[i];
                                final hasGeo = m['lat'] != null && m['lng'] != null;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AppCard(
                                    onTap: () {
                                      if (hasGeo) {
                                        final lat = (m['lat'] as num).toDouble();
                                        final lng = (m['lng'] as num).toDouble();
                                        _mapController.move(LatLng(lat, lng), 15);
                                      }
                                      _showMarkerSheet(m);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          hasGeo ? Icons.place : Icons.place_outlined,
                                          color: hasGeo ? AppColors.tech : AppColors.muted,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${m['number'] ?? m['id']} · ${m['subject'] ?? '-'}',
                                                style: const TextStyle(fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${m['customer'] ?? '-'} · ${m['status'] ?? '-'}',
                                                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (hasGeo)
                                          IconButton(
                                            icon: const Icon(Icons.directions, color: AppColors.tech),
                                            onPressed: () => _openExternal(m),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  void _showMarkerSheet(Map<String, dynamic> m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m['number'] ?? ''} — ${m['subject'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Pelanggan: ${m['customer'] ?? '-'}'),
            Text('Status: ${m['status'] ?? '-'} · Prioritas: ${m['priority'] ?? '-'}'),
            if ((m['address'] ?? '').toString().isNotEmpty)
              Text('Alamat: ${m['address']}'),
            if ((m['phone'] ?? '').toString().isNotEmpty)
              Text('HP: ${m['phone']}'),
            const SizedBox(height: 12),
            if (m['lat'] != null && m['lng'] != null)
              ElevatedButton.icon(
                onPressed: () => _openExternal(m),
                icon: const Icon(Icons.directions),
                label: const Text('Buka di Google Maps'),
              ),
          ],
        ),
      ),
    );
  }
}
