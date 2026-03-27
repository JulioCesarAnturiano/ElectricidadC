/// Home Screen - Pantalla principal con lista de rutas
/// Muestra las rutas asignadas al usuario autenticado

import 'package:flutter/material.dart';
import 'models/usuario.dart';
import 'models/ruta.dart';
import 'login_screen.dart';
import 'ruta_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  /// Cierra sesión y regresa al login
  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar verde oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3D1C),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            width: 30,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.bolt,
                color: Color(0xFFF0E000),
                size: 30,
              );
            },
          ),
        ),
        title: const Text(
          'Mis Rutas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _cerrarSesion(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Tarjeta de bienvenida
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E000),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícono de usuario
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6B2F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Texto de bienvenida
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenido,',
                        style: TextStyle(
                          color: Color(0xFF1B6B2F),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        usuario.nombreCompleto,
                        style: const TextStyle(
                          color: Color(0xFF1B6B2F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${usuario.rutasAsignadas.length} rutas · ${usuario.totalClientes} clientes',
                        style: TextStyle(
                          color: const Color(0xFF1B6B2F).withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Título de sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.map,
                  color: Color(0xFF1B6B2F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rutas Asignadas',
                  style: TextStyle(
                    color: Color(0xFF1B6B2F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de rutas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: usuario.rutasAsignadas.length,
              itemBuilder: (context, index) {
                final ruta = usuario.rutasAsignadas[index];
                return _RutaCard(
                  ruta: ruta,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RutaDetailScreen(ruta: ruta),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de tarjeta para mostrar una ruta
class _RutaCard extends StatelessWidget {
  final Ruta ruta;
  final VoidCallback onTap;

  const _RutaCard({
    required this.ruta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono de mapa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6B2F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.map,
                  color: Color(0xFF1B6B2F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información de la ruta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ruta.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B6B2F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ruta.cantidadClientes} clientes',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Flecha derecha
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF1B6B2F),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
