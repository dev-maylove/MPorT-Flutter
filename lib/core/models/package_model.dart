class PackageModel {
  final int id;
  final String name;
  final String? speed;
  final String? speedDown;
  final String? speedUp;
  final double price;
  final String? priceFormatted;
  final String? description;
  final bool isActive;
  final List<String> features;

  const PackageModel({
    required this.id,
    required this.name,
    this.speed,
    this.speedDown,
    this.speedUp,
    required this.price,
    this.priceFormatted,
    this.description,
    this.isActive = true,
    this.features = const [],
  });

  String get displaySpeed {
    if (speed != null && speed!.isNotEmpty) return speed!;
    if (speedDown != null) {
      if (speedUp != null) return '$speedDown / $speedUp';
      return speedDown!;
    }
    return '-';
  }

  String get displayPrice {
    if (priceFormatted != null && priceFormatted!.isNotEmpty) {
      return priceFormatted!;
    }
    return 'Rp ${_format(price)}';
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final feats = <String>[];
    final raw = json['features'];
    if (raw is List) {
      for (final e in raw) {
        if (e is String) {
          feats.add(e);
        } else if (e is Map) {
          feats.add((e['name'] ?? e['label'] ?? e.toString()).toString());
        }
      }
    }
    return PackageModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      speed: json['speed']?.toString(),
      speedDown: (json['speed_down'] ?? json['bandwidth'])?.toString(),
      speedUp: json['speed_up']?.toString(),
      price: _asDouble(json['price']),
      priceFormatted: json['price_formatted']?.toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] == null ? true : json['is_active'] == true,
      features: feats,
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return 0;
  }

  static String _format(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
