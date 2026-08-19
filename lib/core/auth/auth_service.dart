import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  AuthService() {
    _client = ApiClient(tokenProvider: () async => _token);
    _restore();
  }

  late final ApiClient _client;
  String? _token;
  UserModel? _user;
  bool _loading = true;
  bool _onboarded = false;

  ApiClient get client => _client;
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isLoading => _loading;
  bool get onboarded => _onboarded;
  String get role => _user?.role ?? 'user';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConfig.keyToken);
    _onboarded = prefs.getBool(ApiConfig.keyOnboarded) ?? false;
    final id = prefs.getInt(ApiConfig.keyUserId) ?? 0;
    final name = prefs.getString(ApiConfig.keyUserName) ?? '';
    final email = prefs.getString(ApiConfig.keyUserEmail) ?? '';
    final role = prefs.getString(ApiConfig.keyRole) ?? 'user';
    if (id > 0) {
      _user = UserModel(id: id, name: name, email: email, role: role);
    }
    _loading = false;
    notifyListeners();
    if (isLoggedIn) {
      // refresh profile silently
      try {
        await fetchMe();
      } catch (_) {}
    }
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ApiConfig.keyOnboarded, true);
    _onboarded = true;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    final res = await _client.post(ApiConfig.login, body: {
      'email': email,
      'password': password,
      'device_name': 'mport-flutter',
    });
    if (!res.isOk) return res.message;
    return _saveAuthFromResponse(res.json);
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': 'mport-flutter',
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    final res = await _client.post(ApiConfig.register, body: body);
    if (!res.isOk) return res.message;
    return _saveAuthFromResponse(res.json);
  }

  Future<String?> _saveAuthFromResponse(Map<String, dynamic>? json) async {
    if (json == null) return 'Response kosong';
    // Support envelope { data: { token, user } }
    var root = json;
    if (json['data'] is Map &&
        ((json['data'] as Map).containsKey('token') ||
            (json['data'] as Map).containsKey('access_token'))) {
      root = Map<String, dynamic>.from(json['data'] as Map);
    }

    final token = (root['token'] ?? root['access_token'] ?? '').toString();
    if (token.isEmpty) return 'Token tidak ditemukan';

    UserModel? user;
    if (root['user'] is Map) {
      user = UserModel.fromJson(Map<String, dynamic>.from(root['user'] as Map));
    }

    await _persist(token, user);
    return null;
  }

  Future<void> fetchMe() async {
    final res = await _client.get(ApiConfig.me, auth: true);
    if (res.statusCode == 401) {
      await logout();
      return;
    }
    if (!res.isOk || res.json == null) return;

    Map<String, dynamic> data = res.json!;
    // Laravel UserResource root wrap: { data: {...} }
    if (data['data'] is Map) {
      data = Map<String, dynamic>.from(data['data'] as Map);
    } else if (data['user'] is Map) {
      data = Map<String, dynamic>.from(data['user'] as Map);
    }
    final user = UserModel.fromJson(data);
    await _persist(_token!, user);
  }

  Future<void> _persist(String token, UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    await prefs.setString(ApiConfig.keyToken, token);
    await prefs.setString(ApiConfig.keyTokenType, 'Bearer');
    if (user != null) {
      _user = user;
      await prefs.setInt(ApiConfig.keyUserId, user.id);
      await prefs.setString(ApiConfig.keyUserName, user.name);
      await prefs.setString(ApiConfig.keyUserEmail, user.email);
      await prefs.setString(ApiConfig.keyRole, user.role);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (isLoggedIn) {
        await _client.post(ApiConfig.logout, auth: true);
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.keyToken);
    await prefs.remove(ApiConfig.keyTokenType);
    await prefs.remove(ApiConfig.keyUserId);
    await prefs.remove(ApiConfig.keyUserName);
    await prefs.remove(ApiConfig.keyUserEmail);
    await prefs.remove(ApiConfig.keyRole);
    _token = null;
    _user = null;
    notifyListeners();
  }
}
