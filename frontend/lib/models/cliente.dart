/// Modelo Cliente - Representa un cliente/socio de la cooperativa
/// con su información de medidor y estado de cuenta

class Cliente {
  final String codCliente;      // Código único del cliente (ej: "NRT-001")
  final String nombre;          // Nombre completo del cliente
  final String direccion;       // Dirección del domicilio/negocio
  final String categoria;       // Residencial / Comercial / Industrial
  final int lecturaAnterior;    // Última lectura registrada del medidor
  final String estadoCuenta;    // Al día / Pendiente
  int? lecturaActual;           // Lectura actual (se registra en campo)
  String? tipoLectura;          // Tipo de lectura realizada
  String? observaciones;        // Observaciones del lector

  Cliente({
    required this.codCliente,
    required this.nombre,
    required this.direccion,
    required this.categoria,
    required this.lecturaAnterior,
    required this.estadoCuenta,
    this.lecturaActual,
    this.tipoLectura,
    this.observaciones,
  });

  /// Calcula el consumo en kWh (lectura actual - lectura anterior)
  int get consumo {
    if (lecturaActual == null) return 0;
    return lecturaActual! - lecturaAnterior;
  }

  /// Calcula el monto estimado (consumo * tarifa placeholder)
  double get montoEstimado {
    return consumo * 0.85; // Tarifa placeholder: 0.85 Bs por kWh
  }

  /// Verifica si el cliente tiene el pago al día
  bool get estaAlDia => estadoCuenta == 'Al día';

  /// Copia del cliente con campos actualizados
  Cliente copyWith({
    String? codCliente,
    String? nombre,
    String? direccion,
    String? categoria,
    int? lecturaAnterior,
    String? estadoCuenta,
    int? lecturaActual,
    String? tipoLectura,
    String? observaciones,
  }) {
    return Cliente(
      codCliente: codCliente ?? this.codCliente,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      categoria: categoria ?? this.categoria,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
      estadoCuenta: estadoCuenta ?? this.estadoCuenta,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      tipoLectura: tipoLectura ?? this.tipoLectura,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
