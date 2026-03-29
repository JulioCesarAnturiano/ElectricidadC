/// Configuración de APIs - Cambiar estas URLs cuando el backend esté listo
class ApiConfig {
  // Base URL del backend - CAMBIAR CUANDO ESTÉ LISTO
  static const String baseUrl = 'https://api.example.com';
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String routesEndpoint = '/routes';
  static const String clientsEndpoint = '/clients';
  static const String readingsEndpoint = '/readings';
  
  // URLs completas
  static String get loginUrl => '\$baseUrl\$loginEndpoint';
  static String get routesUrl => '\$baseUrl\$routesEndpoint';
  static String get clientsUrl => '\$baseUrl\$clientsEndpoint';
  static String get readingsUrl => '\$baseUrl\$readingsEndpoint';
  
  // Timeout para peticiones
  static const Duration timeout = Duration(seconds: 30);
  
  // Flag para usar datos mock (cambiar a false cuando el backend esté listo)
  static const bool useMockData = true;
}
