import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'models.dart';
import 'route_detail_screen.dart';
import 'login_screen.dart';
import 'printer_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar rutas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().loadRoutes();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _openPrinterConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrinterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final routeProvider = context.watch<RouteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutas'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón de impresora
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Configurar Impresora',
            onPressed: _openPrinterConfig,
          ),
          // Botón de cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con info del usuario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Bienvenido!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            authProvider.currentUser?.nombre ?? 'Usuario',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Resumen
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Rutas',
                      routeProvider.routes.length.toString(),
                      Icons.route,
                    ),
                    _buildSummaryItem(
                      'Pendientes',
                      routeProvider.routes
                          .fold<int>(0, (sum, r) => sum + r.clientesPendientes)
                          .toString(),
                      Icons.pending_actions,
                    ),
                    _buildSummaryItem(
                      'Registrados',
                      routeProvider.routes
                          .fold<int>(0, (sum, r) => sum + r.clientesRegistrados)
                          .toString(),
                      Icons.check_circle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Título de sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  'Rutas Asignadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Lista de rutas
          Expanded(
            child: routeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : routeProvider.routes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.route_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay rutas asignadas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => routeProvider.loadRoutes(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: routeProvider.routes.length,
                          itemBuilder: (context, index) {
                            final route = routeProvider.routes[index];
                            return _buildRouteCard(route);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    final progress = route.totalClientes > 0
        ? route.clientesRegistrados / route.totalClientes
        : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<RouteProvider>().selectRoute(route);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RouteDetailScreen(route: route),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.route,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${route.totalClientes} clientes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Barra de progreso
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        color: progress >= 1.0
                            ? Colors.green
                            : const Color(0xFF43A047),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${route.clientesRegistrados}/${route.totalClientes}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0
                          ? Colors.green
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Estadísticas
              Row(
                children: [
                  _buildStatChip(
                    Icons.pending,
                    '${route.clientesPendientes} pendientes',
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.check_circle,
                    '${route.clientesRegistrados} registrados',
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
