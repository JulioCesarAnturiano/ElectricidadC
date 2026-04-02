import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'models.dart';
import 'mock_data.dart';

/// Servicio de autenticación
class AuthService {
  /// Intenta iniciar sesión con usuario y contraseña
  /// Retorna User si es exitoso, null si falla
  Future<User?> login(String username, String password) async {
    if (ApiConfig.useMockData) {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Validar credenciales mock
      if (username == 'electricista1' && password == '123456') {
        return MockData.mockUser;
      } else if (username == 'demo' && password == 'demo') {
        return MockData.mockUser;
      }
      return null;
    }

    // Código real para cuando el backend esté listo
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error en login: \$e');
      return null;
    }
  }

  /// Cierra la sesión actual
  Future<void> logout() async {
    // Limpiar token, shared preferences, etc.
    // Por implementar cuando haya backend
  }
}

/// Servicio para obtener rutas y clientes
class RouteService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Obtiene las rutas asignadas al electricista
  Future<List<RouteModel>> getRoutes() async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.mockRoutes;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.routesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$_authToken',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RouteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo rutas: \$e');
      return [];
    }
  }

  /// Obtiene los clientes de una ruta específica
  Future<List<Client>> getClientsByRoute(String routeId) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.getClientsByRoute(routeId);
    }

    try {
      final response = await http.get(
        Uri.parse('\${ApiConfig.clientsUrl}?route_id=\$routeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$_authToken',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Client.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo clientes: \$e');
      return [];
    }
  }
}

/// Servicio para registrar lecturas
class ReadingService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Envía una lectura al backend y retorna el preaviso para imprimir
  Future<Preaviso?> registrarLectura(Reading reading, Client client) async {
    if (ApiConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Si es lectura normal, generar preaviso
      if (reading.tipoLectura == TipoLectura.normal && reading.lecturaMedidor != null) {
        return MockData.generateMockPreaviso(client, reading.lecturaMedidor!);
      }
      
      // Para otros tipos de lectura, retornar preaviso básico
      return Preaviso(
        codCliente: client.codCliente,
        nombreCliente: client.nombre,
        direccion: client.direccion,
        categoria: client.categoria,
        lecturaAnterior: client.ultimaLectura ?? '0',
        lecturaActual: reading.lecturaMedidor ?? 'N/A',
        consumo: 'N/A',
        montoAPagar: 'PENDIENTE',
        fechaVencimiento: 'PENDIENTE',
        periodo: 'Marzo 2026',
        mensaje: 'Tipo de lectura: \${reading.tipoLectura.nombre}',
        numeroMedidor: client.numeroMedidor ?? client.codCliente,
      );
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.readingsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$_authToken',
        },
        body: jsonEncode(reading.toJson()),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Preaviso.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error registrando lectura: \$e');
      return null;
    }
  }
}
