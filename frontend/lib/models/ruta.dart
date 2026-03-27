/// Modelo Ruta - Representa una ruta de lectura asignada
/// Contiene la lista de clientes a visitar

import 'cliente.dart';

class Ruta {
  final String id;              // Identificador único de la ruta
  final String nombre;          // Nombre de la ruta (ej: "Ruta Norte")
  final List<Cliente> clientes; // Lista de clientes en esta ruta

  Ruta({
    required this.id,
    required this.nombre,
    required this.clientes,
  });

  /// Cantidad total de clientes en la ruta
  int get cantidadClientes => clientes.length;

  /// Cantidad de clientes con lectura ya registrada
  int get clientesLeidos => clientes.where((c) => c.lecturaActual != null).length;

  /// Porcentaje de avance en la ruta
  double get porcentajeAvance {
    if (cantidadClientes == 0) return 0;
    return (clientesLeidos / cantidadClientes) * 100;
  }

  /// Clientes pendientes de lectura
  List<Cliente> get clientesPendientes =>
      clientes.where((c) => c.lecturaActual == null).toList();
}
