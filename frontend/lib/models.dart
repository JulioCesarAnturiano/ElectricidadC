/// Modelo de Usuario
class User {
  final String id;
  final String username;
  final String nombre;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.nombre,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nombre': nombre,
      'token': token,
    };
  }
}

/// Modelo de Ruta asignada al electricista
class RouteModel {
  final String id;
  final String nombre;
  final int totalClientes;
  final int clientesPendientes;
  final int clientesRegistrados;

  RouteModel({
    required this.id,
    required this.nombre,
    required this.totalClientes,
    required this.clientesPendientes,
    required this.clientesRegistrados,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      totalClientes: json['total_clientes'] ?? 0,
      clientesPendientes: json['clientes_pendientes'] ?? 0,
      clientesRegistrados: json['clientes_registrados'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'total_clientes': totalClientes,
      'clientes_pendientes': clientesPendientes,
      'clientes_registrados': clientesRegistrados,
    };
  }
}

/// Modelo de Cliente/Casa a visitar
class Client {
  final String codCliente;
  final String nombre;
  final String categoria;
  final String direccion;
  final double latitud;
  final double longitud;
  final bool registrado;
  final String? ultimaLectura;
  final String? fechaUltimaLectura;
  final String? numeroMedidor;

  Client({
    required this.codCliente,
    required this.nombre,
    required this.categoria,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.registrado,
    this.ultimaLectura,
    this.fechaUltimaLectura,
    this.numeroMedidor,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      codCliente: json['cod_cliente'] ?? '',
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      direccion: json['direccion'] ?? '',
      latitud: (json['latitud'] ?? 0).toDouble(),
      longitud: (json['longitud'] ?? 0).toDouble(),
      registrado: json['registrado'] ?? false,
      ultimaLectura: json['ultima_lectura'],
      fechaUltimaLectura: json['fecha_ultima_lectura'],
      numeroMedidor: json['numero_medidor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod_cliente': codCliente,
      'nombre': nombre,
      'categoria': categoria,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'registrado': registrado,
      'ultima_lectura': ultimaLectura,
      'fecha_ultima_lectura': fechaUltimaLectura,
      'numero_medidor': numeroMedidor,
    };
  }
}

/// Tipos de lectura disponibles
enum TipoLectura {
  normal,
  casaCerrada,
  medidorDanado,
  sinAcceso,
  noExiste,
}

extension TipoLecturaExtension on TipoLectura {
  String get nombre {
    switch (this) {
      case TipoLectura.normal:
        return 'Lectura Normal';
      case TipoLectura.casaCerrada:
        return 'Casa Cerrada';
      case TipoLectura.medidorDanado:
        return 'Medidor Dañado';
      case TipoLectura.sinAcceso:
        return 'Sin Acceso';
      case TipoLectura.noExiste:
        return 'No Existe';
    }
  }

  String get codigo {
    switch (this) {
      case TipoLectura.normal:
        return 'NORMAL';
      case TipoLectura.casaCerrada:
        return 'CERRADA';
      case TipoLectura.medidorDanado:
        return 'DANADO';
      case TipoLectura.sinAcceso:
        return 'SIN_ACCESO';
      case TipoLectura.noExiste:
        return 'NO_EXISTE';
    }
  }

  static TipoLectura fromCodigo(String codigo) {
    switch (codigo) {
      case 'NORMAL':
        return TipoLectura.normal;
      case 'CERRADA':
        return TipoLectura.casaCerrada;
      case 'DANADO':
        return TipoLectura.medidorDanado;
      case 'SIN_ACCESO':
        return TipoLectura.sinAcceso;
      case 'NO_EXISTE':
        return TipoLectura.noExiste;
      default:
        return TipoLectura.normal;
    }
  }
}

/// Modelo de Lectura a registrar
class Reading {
  final String codCliente;
  final TipoLectura tipoLectura;
  final String? lecturaMedidor;
  final String? observaciones;
  final DateTime fechaRegistro;

  Reading({
    required this.codCliente,
    required this.tipoLectura,
    this.lecturaMedidor,
    this.observaciones,
    required this.fechaRegistro,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      codCliente: json['cod_cliente'] ?? '',
      tipoLectura: TipoLecturaExtension.fromCodigo(json['tipo_lectura'] ?? 'NORMAL'),
      lecturaMedidor: json['lectura_medidor'],
      observaciones: json['observaciones'],
      fechaRegistro: DateTime.parse(json['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod_cliente': codCliente,
      'tipo_lectura': tipoLectura.codigo,
      'lectura_medidor': lecturaMedidor,
      'observaciones': observaciones,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}

/// Modelo de Preaviso (respuesta del backend para imprimir)
class Preaviso {
  final String codCliente;
  final String nombreCliente;
  final String direccion;
  final String categoria;
  final String lecturaAnterior;
  final String lecturaActual;
  final String consumo;
  final String montoAPagar;
  final String fechaVencimiento;
  final String periodo;
  final String mensaje;
  final String? numeroMedidor;

  Preaviso({
    required this.codCliente,
    required this.nombreCliente,
    required this.direccion,
    required this.categoria,
    required this.lecturaAnterior,
    required this.lecturaActual,
    required this.consumo,
    required this.montoAPagar,
    required this.fechaVencimiento,
    required this.periodo,
    required this.mensaje,
    this.numeroMedidor,
  });

  factory Preaviso.fromJson(Map<String, dynamic> json) {
    return Preaviso(
      codCliente: json['cod_cliente'] ?? '',
      nombreCliente: json['nombre_cliente'] ?? '',
      direccion: json['direccion'] ?? '',
      categoria: json['categoria'] ?? '',
      lecturaAnterior: json['lectura_anterior'] ?? '0',
      lecturaActual: json['lectura_actual'] ?? '0',
      consumo: json['consumo'] ?? '0',
      montoAPagar: json['monto_a_pagar'] ?? '0.00',
      fechaVencimiento: json['fecha_vencimiento'] ?? '',
      periodo: json['periodo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      numeroMedidor: json['numero_medidor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod_cliente': codCliente,
      'nombre_cliente': nombreCliente,
      'direccion': direccion,
      'categoria': categoria,
      'lectura_anterior': lecturaAnterior,
      'lectura_actual': lecturaActual,
      'consumo': consumo,
      'monto_a_pagar': montoAPagar,
      'fecha_vencimiento': fechaVencimiento,
      'periodo': periodo,
      'mensaje': mensaje,
      'numero_medidor': numeroMedidor,
    };
  }

  /// Genera el texto para imprimir en la impresora térmica
  String toTicketText() {
    return '''
================================
      EMPRESA ELECTRICA
================================
PREAVISO DE CONSUMO

Cod. Cliente: $codCliente
Nombre: $nombreCliente
Direccion: $direccion
Categoria: $categoria

--------------------------------
DETALLE DE CONSUMO
--------------------------------
Lectura Anterior: $lecturaAnterior
Lectura Actual:   $lecturaActual
Consumo (kWh):    $consumo

--------------------------------
MONTO A PAGAR: S/. $montoAPagar
--------------------------------

Periodo: $periodo
Vence: $fechaVencimiento

$mensaje

================================
    Gracias por su pago
================================
''';
  }
}
