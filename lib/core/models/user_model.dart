class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // user | technician | admin
  final String? phone;
  final String? dutyStatus;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.dutyStatus,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';
  bool get isTechnician => role == 'technician';
  bool get isUser => role == 'user';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString().toLowerCase(),
      phone: json['phone']?.toString(),
      dutyStatus: json['duty_status']?.toString(),
      isActive: json['is_active'] == null ? true : json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'duty_status': dutyStatus,
        'is_active': isActive,
      };

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
