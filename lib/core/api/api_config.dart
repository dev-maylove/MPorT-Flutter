/// Konfigurasi API — MPorT Laravel v2.0.1 (Sanctum).
class ApiConfig {
  ApiConfig._();

  /// Default: server LAN 192.168.1.102
  /// Override: flutter run --dart-define=API_BASE_URL=http://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.102:8000',
  );

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';

  // Resources
  static const String packages = '/api/v1/packages';
  static const String invoices = '/api/invoices';
  static const String dashboard = '/api/dashboard';
  static const String tickets = '/api/tickets';
  static const String payments = '/api/payments';
  static const String customers = '/api/customers';
  static const String oltOverview = '/api/olt/overview';
  static const String oltSignals = '/api/olt/signals';

  // Tech
  static const String techMaterials = '/api/tech/materials';
  static const String techMaterialRequest = '/api/tech/materials/request';
  static const String techMaterialUsage = '/api/tech/materials/usage';
  static const String techMap = '/api/tech/map';

  // Admin
  static const String adminUsers = '/api/admin/users';

  static const String keyToken = 'access_token';
  static const String keyTokenType = 'token_type';
  static const String keyRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserId = 'user_id';
  static const String keyOnboarded = 'onboarded';
}
