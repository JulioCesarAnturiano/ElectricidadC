/// Modelo Usuario - Representa un lector/operador del sistema
/// Contiene las rutas asignadas al usuario

import 'ruta.dart';

class Usuario {
  final String id;              // Identificador único
  final String username;        // Nombre de usuario para login
  final String password;        // Contraseña (en producción sería hash)
  final String nombreCompleto;  // Nombre para mostrar
  final List<Ruta> rutasAsignadas; // Rutas de trabajo asignadas

  Usuario({
    required this.id,
    required this.username,
    required this.password,
    required this.nombreCompleto,
    required this.rutasAsignadas,
  });

  /// Total de clientes en todas las rutas
  int get totalClientes {
    return rutasAsignadas.fold(0, (sum, ruta) => sum + ruta.cantidadClientes);
  }

  /// Verifica si las credenciales son correctas
  bool verificarCredenciales(String user, String pass) {
    return username == user && password == pass;
  }
}
