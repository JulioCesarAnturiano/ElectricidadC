import 'models.dart';

/// Datos de prueba - Usando coordenadas de Lima, Perú como ejemplo
class MockData {
  /// Usuario de prueba para login
  static User mockUser = User(
    id: 'USR001',
    username: 'electricista1',
    nombre: 'Juan Pérez García',
    token: 'mock-jwt-token-12345',
  );

  /// Rutas asignadas al electricista
  static List<RouteModel> mockRoutes = [
    RouteModel(
      id: 'RUT001',
      nombre: 'Ruta San Miguel - Zona A',
      totalClientes: 15,
      clientesPendientes: 10,
      clientesRegistrados: 5,
    ),
    RouteModel(
      id: 'RUT002',
      nombre: 'Ruta San Miguel - Zona B',
      totalClientes: 12,
      clientesPendientes: 12,
      clientesRegistrados: 0,
    ),
    RouteModel(
      id: 'RUT003',
      nombre: 'Ruta Magdalena',
      totalClientes: 20,
      clientesPendientes: 8,
      clientesRegistrados: 12,
    ),
  ];

  /// Clientes de la Ruta 1 (San Miguel - Zona A)
  static List<Client> mockClientsRuta1 = [
    Client(
      codCliente: 'CLI001',
      nombre: 'María García López',
      categoria: 'Residencial',
      direccion: 'Av. La Marina 2450',
      latitud: -12.0769,
      longitud: -77.0822,
      registrado: true,
      ultimaLectura: '15420',
      fechaUltimaLectura: '2026-02-15',
    ),
    Client(
      codCliente: 'CLI002',
      nombre: 'Carlos Rodríguez',
      categoria: 'Residencial',
      direccion: 'Jr. Paruro 180',
      latitud: -12.0785,
      longitud: -77.0810,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI003',
      nombre: 'Ana Torres Vega',
      categoria: 'Comercial',
      direccion: 'Av. Universitaria 1540',
      latitud: -12.0752,
      longitud: -77.0835,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI004',
      nombre: 'Restaurant El Buen Sabor',
      categoria: 'Comercial',
      direccion: 'Av. La Marina 2890',
      latitud: -12.0790,
      longitud: -77.0800,
      registrado: true,
      ultimaLectura: '45680',
      fechaUltimaLectura: '2026-02-15',
    ),
    Client(
      codCliente: 'CLI005',
      nombre: 'Pedro Sánchez',
      categoria: 'Residencial',
      direccion: 'Calle Los Olivos 450',
      latitud: -12.0810,
      longitud: -77.0790,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI006',
      nombre: 'Farmacia Santa Rosa',
      categoria: 'Comercial',
      direccion: 'Av. Elmer Faucett 1200',
      latitud: -12.0730,
      longitud: -77.0850,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI007',
      nombre: 'Luis Fernández',
      categoria: 'Residencial',
      direccion: 'Jr. Huancayo 890',
      latitud: -12.0765,
      longitud: -77.0780,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI008',
      nombre: 'Minimarket Don José',
      categoria: 'Comercial',
      direccion: 'Av. Venezuela 2340',
      latitud: -12.0745,
      longitud: -77.0860,
      registrado: true,
      ultimaLectura: '28900',
      fechaUltimaLectura: '2026-02-15',
    ),
    Client(
      codCliente: 'CLI009',
      nombre: 'Rosa Martínez',
      categoria: 'Residencial',
      direccion: 'Calle Los Pinos 120',
      latitud: -12.0800,
      longitud: -77.0770,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI010',
      nombre: 'Jorge Castillo',
      categoria: 'Residencial',
      direccion: 'Av. Costanera 560',
      latitud: -12.0720,
      longitud: -77.0830,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI011',
      nombre: 'Panadería El Trigal',
      categoria: 'Comercial',
      direccion: 'Jr. Callao 234',
      latitud: -12.0775,
      longitud: -77.0815,
      registrado: true,
      ultimaLectura: '35200',
      fechaUltimaLectura: '2026-02-15',
    ),
    Client(
      codCliente: 'CLI012',
      nombre: 'Elena Vargas',
      categoria: 'Residencial',
      direccion: 'Calle San José 890',
      latitud: -12.0755,
      longitud: -77.0795,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI013',
      nombre: 'Taller Mecánico Cruz',
      categoria: 'Industrial',
      direccion: 'Av. Argentina 4500',
      latitud: -12.0735,
      longitud: -77.0870,
      registrado: true,
      ultimaLectura: '89450',
      fechaUltimaLectura: '2026-02-15',
    ),
    Client(
      codCliente: 'CLI014',
      nombre: 'Patricia Núñez',
      categoria: 'Residencial',
      direccion: 'Jr. Tacna 678',
      latitud: -12.0795,
      longitud: -77.0805,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI015',
      nombre: 'Librería El Estudiante',
      categoria: 'Comercial',
      direccion: 'Av. Universitaria 2100',
      latitud: -12.0760,
      longitud: -77.0840,
      registrado: false,
    ),
  ];

  /// Clientes de la Ruta 2 (San Miguel - Zona B)
  static List<Client> mockClientsRuta2 = [
    Client(
      codCliente: 'CLI016',
      nombre: 'Roberto Mendoza',
      categoria: 'Residencial',
      direccion: 'Av. Precursores 1890',
      latitud: -12.0850,
      longitud: -77.0750,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI017',
      nombre: 'Bodega La Esquina',
      categoria: 'Comercial',
      direccion: 'Jr. Cajamarca 456',
      latitud: -12.0870,
      longitud: -77.0730,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI018',
      nombre: 'Familia Quispe',
      categoria: 'Residencial',
      direccion: 'Calle Las Flores 234',
      latitud: -12.0830,
      longitud: -77.0760,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI019',
      nombre: 'Peluquería Estilo',
      categoria: 'Comercial',
      direccion: 'Av. La Paz 890',
      latitud: -12.0855,
      longitud: -77.0745,
      registrado: false,
    ),
    Client(
      codCliente: 'CLI020',
      nombre: 'Fernando Huamán',
      categoria: 'Residencial',
      direccion: 'Jr. Piura 123',
      latitud: -12.0840,
      longitud: -77.0770,
      registrado: false,
    ),
  ];

  /// Obtiene los clientes según la ruta
  static List<Client> getClientsByRoute(String routeId) {
    switch (routeId) {
      case 'RUT001':
        return mockClientsRuta1;
      case 'RUT002':
        return mockClientsRuta2;
      case 'RUT003':
        return mockClientsRuta1.take(8).toList(); // Simular otra ruta
      default:
        return [];
    }
  }

  /// Simula la respuesta del backend al registrar una lectura
  static Preaviso generateMockPreaviso(Client client, String lecturaActual) {
    final lecturaAnterior = client.ultimaLectura ?? '0';
    final consumo = int.tryParse(lecturaActual) ?? 0 - (int.tryParse(lecturaAnterior) ?? 0);
    
    // Simular cálculo de monto (ejemplo: S/. 0.50 por kWh)
    final monto = (consumo * 0.50).toStringAsFixed(2);
    
    return Preaviso(
      codCliente: client.codCliente,
      nombreCliente: client.nombre,
      direccion: client.direccion,
      categoria: client.categoria,
      lecturaAnterior: lecturaAnterior,
      lecturaActual: lecturaActual,
      consumo: consumo.toString(),
      montoAPagar: monto,
      fechaVencimiento: '2026-04-15',
      periodo: 'Marzo 2026',
      mensaje: 'Pague antes de la fecha de vencimiento para evitar cortes.',
      numeroMedidor: client.numeroMedidor ?? client.codCliente,
    );
  }
}
