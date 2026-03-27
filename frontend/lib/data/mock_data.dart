/// Datos Mock - Datos de prueba para el sistema de lectura de medidores
/// Contiene usuarios, rutas y clientes con nombres bolivianos

import '../models/cliente.dart';
import '../models/ruta.dart';
import '../models/usuario.dart';

/// Lista maestra de todos los usuarios del sistema
List<Usuario> obtenerUsuarios() {
  return [
    // Usuario 1: Juan Pérez - Rutas Norte y Centro
    Usuario(
      id: 'USR001',
      username: 'jperez',
      password: 'pass123',
      nombreCompleto: 'Juan Pérez Mamani',
      rutasAsignadas: [_rutaNorte, _rutaCentro],
    ),
    // Usuario 2: María García - Rutas Sur y Este
    Usuario(
      id: 'USR002',
      username: 'mgarcia',
      password: 'pass456',
      nombreCompleto: 'María García Quispe',
      rutasAsignadas: [_rutaSur, _rutaEste],
    ),
    // Usuario 3: Roberto López - Rutas Oeste e Industrial
    Usuario(
      id: 'USR003',
      username: 'rlopez',
      password: 'pass789',
      nombreCompleto: 'Roberto López Condori',
      rutasAsignadas: [_rutaOeste, _rutaIndustrial],
    ),
    // Usuario Admin - Todas las rutas
    Usuario(
      id: 'ADM001',
      username: 'admin',
      password: 'admin123',
      nombreCompleto: 'Administrador Sistema',
      rutasAsignadas: [
        _rutaNorte, _rutaCentro, _rutaSur, _rutaEste, _rutaOeste, _rutaIndustrial
      ],
    ),
  ];
}

/// Verifica credenciales y retorna el usuario si es válido
Usuario? autenticarUsuario(String username, String password) {
  try {
    return obtenerUsuarios().firstWhere(
      (u) => u.verificarCredenciales(username, password),
    );
  } catch (e) {
    return null;
  }
}

// ==================== RUTAS ====================

/// Ruta Norte - 25 clientes (generamos 12 representativos)
final Ruta _rutaNorte = Ruta(
  id: 'RUT-NRT',
  nombre: 'Ruta Norte',
  clientes: [
    Cliente(codCliente: 'NRT-001', nombre: 'Carlos Mamani Choque', direccion: 'Av. 6 de Agosto #234', categoria: 'Residencial', lecturaAnterior: 4523, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-002', nombre: 'Rosa Quispe de Flores', direccion: 'Calle Bolívar #567', categoria: 'Residencial', lecturaAnterior: 3217, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-003', nombre: 'Ferretería El Progreso', direccion: 'Av. Integración #890', categoria: 'Comercial', lecturaAnterior: 8934, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'NRT-004', nombre: 'Miguel Ángel Condori', direccion: 'Zona Norte, Mza. 5 #12', categoria: 'Residencial', lecturaAnterior: 2156, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-005', nombre: 'Panadería Santa Cruz', direccion: 'Calle Comercio #456', categoria: 'Comercial', lecturaAnterior: 6789, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-006', nombre: 'Juana Apaza Villca', direccion: 'Urbanización Los Pinos #78', categoria: 'Residencial', lecturaAnterior: 1876, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'NRT-007', nombre: 'Restaurant El Buen Sabor', direccion: 'Av. Principal #321', categoria: 'Comercial', lecturaAnterior: 7654, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-008', nombre: 'Pedro Huanca Mamani', direccion: 'Calle Los Álamos #54', categoria: 'Residencial', lecturaAnterior: 2987, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-009', nombre: 'Farmacia San Miguel', direccion: 'Zona Mercado #100', categoria: 'Comercial', lecturaAnterior: 4532, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-010', nombre: 'Elena Choque Poma', direccion: 'Barrio Nuevo #234', categoria: 'Residencial', lecturaAnterior: 1543, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'NRT-011', nombre: 'Tienda Doña María', direccion: 'Calle Sucre #789', categoria: 'Comercial', lecturaAnterior: 5678, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'NRT-012', nombre: 'Victor Hugo Ticona', direccion: 'Av. La Paz #432', categoria: 'Residencial', lecturaAnterior: 3456, estadoCuenta: 'Al día'),
  ],
);

/// Ruta Centro - 30 clientes (generamos 14 representativos)
final Ruta _rutaCentro = Ruta(
  id: 'RUT-CTR',
  nombre: 'Ruta Centro',
  clientes: [
    Cliente(codCliente: 'CTR-001', nombre: 'Banco Mercantil Santa Cruz', direccion: 'Plaza Principal #1', categoria: 'Comercial', lecturaAnterior: 9876, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-002', nombre: 'María Luisa Torrez', direccion: 'Calle Junín #234', categoria: 'Residencial', lecturaAnterior: 2345, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-003', nombre: 'Hotel Central', direccion: 'Av. Cívica #567', categoria: 'Comercial', lecturaAnterior: 8765, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-004', nombre: 'Alberto Flores Condori', direccion: 'Zona Central #89', categoria: 'Residencial', lecturaAnterior: 1987, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'CTR-005', nombre: 'Librería El Estudiante', direccion: 'Calle Comercio #123', categoria: 'Comercial', lecturaAnterior: 3456, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-006', nombre: 'Sandra Colque Limachi', direccion: 'Barrio Centro #456', categoria: 'Residencial', lecturaAnterior: 2654, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-007', nombre: 'Óptica Visión Clara', direccion: 'Galería Central #12', categoria: 'Comercial', lecturaAnterior: 4321, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-008', nombre: 'Felipe Mamani Quispe', direccion: 'Calle Ayacucho #78', categoria: 'Residencial', lecturaAnterior: 3876, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-009', nombre: 'Supermercado Norte', direccion: 'Av. del Mercado #200', categoria: 'Comercial', lecturaAnterior: 9543, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'CTR-010', nombre: 'Teresa Villca Apaza', direccion: 'Zona Residencial #34', categoria: 'Residencial', lecturaAnterior: 1765, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-011', nombre: 'Clínica San Juan', direccion: 'Av. Salud #500', categoria: 'Comercial', lecturaAnterior: 8900, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-012', nombre: 'Jorge Chura Nina', direccion: 'Calle Potosí #321', categoria: 'Residencial', lecturaAnterior: 2987, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-013', nombre: 'Gimnasio Fuerza Total', direccion: 'Centro Deportivo #45', categoria: 'Comercial', lecturaAnterior: 7654, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'CTR-014', nombre: 'Ana María Paco', direccion: 'Barrio San Pedro #67', categoria: 'Residencial', lecturaAnterior: 1432, estadoCuenta: 'Pendiente'),
  ],
);

/// Ruta Sur - 20 clientes (generamos 10 representativos)
final Ruta _rutaSur = Ruta(
  id: 'RUT-SUR',
  nombre: 'Ruta Sur',
  clientes: [
    Cliente(codCliente: 'SUR-001', nombre: 'José Luis Marca', direccion: 'Zona Sur #123', categoria: 'Residencial', lecturaAnterior: 3456, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-002', nombre: 'Mercado Campesino', direccion: 'Av. del Mercado Sur #45', categoria: 'Comercial', lecturaAnterior: 7890, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-003', nombre: 'Petrona Choque Mamani', direccion: 'Calle Los Sauces #78', categoria: 'Residencial', lecturaAnterior: 2134, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'SUR-004', nombre: 'Taller Mecánico El Veloz', direccion: 'Zona Industrial Sur #200', categoria: 'Comercial', lecturaAnterior: 5678, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-005', nombre: 'Ramiro Ticona Apaza', direccion: 'Urbanización Sur #34', categoria: 'Residencial', lecturaAnterior: 1876, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-006', nombre: 'Pollería Rico Pollo', direccion: 'Av. Principal Sur #567', categoria: 'Comercial', lecturaAnterior: 6543, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-007', nombre: 'Domitila Vargas', direccion: 'Barrio Sur #89', categoria: 'Residencial', lecturaAnterior: 2567, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-008', nombre: 'Carpintería San José', direccion: 'Zona Artesanal #12', categoria: 'Comercial', lecturaAnterior: 4321, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'SUR-009', nombre: 'Edwin Mamani Flores', direccion: 'Calle Nueva Sur #456', categoria: 'Residencial', lecturaAnterior: 3098, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'SUR-010', nombre: 'Peluquería Elegante', direccion: 'Centro Sur #78', categoria: 'Comercial', lecturaAnterior: 2345, estadoCuenta: 'Al día'),
  ],
);

/// Ruta Este - 28 clientes (generamos 12 representativos)
final Ruta _rutaEste = Ruta(
  id: 'RUT-EST',
  nombre: 'Ruta Este',
  clientes: [
    Cliente(codCliente: 'EST-001', nombre: 'Lucio Fernández Colque', direccion: 'Av. Este #234', categoria: 'Residencial', lecturaAnterior: 2876, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-002', nombre: 'Distribuidora Oriental', direccion: 'Zona Comercial Este #1', categoria: 'Comercial', lecturaAnterior: 8765, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-003', nombre: 'Martha Huanca de López', direccion: 'Calle Oriente #567', categoria: 'Residencial', lecturaAnterior: 1654, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-004', nombre: 'Carnicería La Popular', direccion: 'Mercado Este #23', categoria: 'Comercial', lecturaAnterior: 4567, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'EST-005', nombre: 'Simón Paco Quispe', direccion: 'Barrio Este #89', categoria: 'Residencial', lecturaAnterior: 3210, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-006', nombre: 'Lavandería Limpio', direccion: 'Av. Servicios #34', categoria: 'Comercial', lecturaAnterior: 5432, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-007', nombre: 'Gregoria Nina Marca', direccion: 'Zona Residencial Este #12', categoria: 'Residencial', lecturaAnterior: 1987, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-008', nombre: 'Papelería Don Bosco', direccion: 'Centro Este #456', categoria: 'Comercial', lecturaAnterior: 3456, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-009', nombre: 'Claudio Chura Mamani', direccion: 'Calle Nueva Este #78', categoria: 'Residencial', lecturaAnterior: 2543, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'EST-010', nombre: 'Zapatería El Paso', direccion: 'Galería Este #5', categoria: 'Comercial', lecturaAnterior: 2987, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-011', nombre: 'Benita Condori Apaza', direccion: 'Urbanización Este #34', categoria: 'Residencial', lecturaAnterior: 1432, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'EST-012', nombre: 'Cyber Mundo Net', direccion: 'Av. Tecnología #100', categoria: 'Comercial', lecturaAnterior: 6789, estadoCuenta: 'Al día'),
  ],
);

/// Ruta Oeste - 22 clientes (generamos 11 representativos)
final Ruta _rutaOeste = Ruta(
  id: 'RUT-OST',
  nombre: 'Ruta Oeste',
  clientes: [
    Cliente(codCliente: 'OST-001', nombre: 'Fortunato Vargas Mamani', direccion: 'Av. Oeste #123', categoria: 'Residencial', lecturaAnterior: 3654, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-002', nombre: 'Ferretería El Constructor', direccion: 'Zona Oeste #45', categoria: 'Comercial', lecturaAnterior: 7890, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-003', nombre: 'Sebastiana Limachi', direccion: 'Calle Poniente #234', categoria: 'Residencial', lecturaAnterior: 1876, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'OST-004', nombre: 'Heladería Delicia', direccion: 'Av. Principal Oeste #67', categoria: 'Comercial', lecturaAnterior: 4532, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-005', nombre: 'Máximo Ticona Flores', direccion: 'Barrio Oeste #89', categoria: 'Residencial', lecturaAnterior: 2765, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-006', nombre: 'Verdulería La Huerta', direccion: 'Mercado Oeste #12', categoria: 'Comercial', lecturaAnterior: 3456, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-007', nombre: 'Francisca Huanca Poma', direccion: 'Zona Residencial Oeste #34', categoria: 'Residencial', lecturaAnterior: 1543, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-008', nombre: 'Taller Electrónico Rayo', direccion: 'Centro Técnico #56', categoria: 'Comercial', lecturaAnterior: 5678, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'OST-009', nombre: 'Julio César Marca Nina', direccion: 'Calle Los Cedros #78', categoria: 'Residencial', lecturaAnterior: 2098, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-010', nombre: 'Librería Horizonte', direccion: 'Av. Educación #90', categoria: 'Comercial', lecturaAnterior: 2345, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'OST-011', nombre: 'Emiliana Apaza Choque', direccion: 'Urbanización Oeste #123', categoria: 'Residencial', lecturaAnterior: 1654, estadoCuenta: 'Al día'),
  ],
);

/// Ruta Industrial - 15 clientes (generamos 10 representativos)
final Ruta _rutaIndustrial = Ruta(
  id: 'RUT-IND',
  nombre: 'Ruta Industrial',
  clientes: [
    Cliente(codCliente: 'IND-001', nombre: 'Fábrica de Muebles Roble', direccion: 'Parque Industrial Lote 1', categoria: 'Industrial', lecturaAnterior: 9876, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-002', nombre: 'Procesadora de Alimentos Sol', direccion: 'Zona Industrial #23', categoria: 'Industrial', lecturaAnterior: 8765, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-003', nombre: 'Metalúrgica Andes', direccion: 'Parque Industrial Lote 5', categoria: 'Industrial', lecturaAnterior: 9543, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'IND-004', nombre: 'Textiles Bolivia', direccion: 'Zona Industrial #45', categoria: 'Industrial', lecturaAnterior: 7654, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-005', nombre: 'Plásticos del Oriente', direccion: 'Parque Industrial Lote 8', categoria: 'Industrial', lecturaAnterior: 8900, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-006', nombre: 'Cervecería Regional', direccion: 'Zona Industrial #67', categoria: 'Industrial', lecturaAnterior: 9999, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-007', nombre: 'Curtiembre San Francisco', direccion: 'Parque Industrial Lote 12', categoria: 'Industrial', lecturaAnterior: 7890, estadoCuenta: 'Pendiente'),
    Cliente(codCliente: 'IND-008', nombre: 'Imprenta Moderna', direccion: 'Zona Industrial #89', categoria: 'Comercial', lecturaAnterior: 5432, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-009', nombre: 'Almacén Central Distribuciones', direccion: 'Centro Logístico #1', categoria: 'Comercial', lecturaAnterior: 6789, estadoCuenta: 'Al día'),
    Cliente(codCliente: 'IND-010', nombre: 'Productos Lácteos La Vaquita', direccion: 'Parque Industrial Lote 15', categoria: 'Industrial', lecturaAnterior: 8234, estadoCuenta: 'Al día'),
  ],
);
