import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'providers.dart';
import 'models.dart';
import 'reading_form_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openReadingForm(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingFormScreen(client: client),
      ),
    ).then((_) {
      setState(() {}); // Refrescar al volver
    });
  }

  LatLng _getCenterPosition() {
    final clients = context.read<RouteProvider>().pendingClients;
    if (clients.isEmpty) {
      return const LatLng(-12.0769, -77.0822); // Lima por defecto
    }

    double sumLat = 0, sumLng = 0;
    for (var client in clients) {
      sumLat += client.latitud;
      sumLng += client.longitud;
    }
    return LatLng(sumLat / clients.length, sumLng / clients.length);
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final pendingClients = routeProvider.pendingClients;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.nombre),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Mapa'),
            Tab(icon: Icon(Icons.list), text: 'Lista'),
          ],
        ),
      ),
      body: routeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab de Mapa
                _buildMapTab(pendingClients),
                // Tab de Lista
                _buildListTab(pendingClients),
              ],
            ),
    );
  }

  Widget _buildMapTab(List<Client> pendingClients) {
    final routeProvider = context.watch<RouteProvider>();
    final allClients = routeProvider.currentClients;
    final registeredCount = allClients.where((c) => c.registrado).length;

    return Column(
      children: [
        // Info de progreso
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: pendingClients.isEmpty ? Colors.green.shade50 : Colors.orange.shade50,
          child: Row(
            children: [
              Icon(
                pendingClients.isEmpty ? Icons.check_circle : Icons.pending_actions,
                color: pendingClients.isEmpty ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                pendingClients.isEmpty 
                    ? '¡Todos los clientes han sido registrados!'
                    : '${pendingClients.length} pendientes • $registeredCount registrados',
                style: TextStyle(
                  color: pendingClients.isEmpty ? Colors.green.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Mapa con OpenStreetMap
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _getCenterPosition(),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lecturas_electricas',
              ),
              MarkerLayer(
                markers: allClients.map((client) {
                  final isRegistered = client.registrado;
                  return Marker(
                    point: LatLng(client.latitud, client.longitud),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showClientDialog(client),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRegistered ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isRegistered ? Icons.check : Icons.home,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Leyenda
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 4),
              const Text('Pendiente', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 4),
              const Text('Registrado', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  void _showClientDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.badge, 'Código: ${client.codCliente}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, client.direccion),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category, 'Categoría: ${client.categoria}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openReadingForm(client);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Registrar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildListTab(List<Client> pendingClients) {
    if (pendingClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Todos los clientes han sido registrados!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Info de pendientes
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.shade50,
          child: Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                '${pendingClients.length} clientes pendientes por registrar',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingClients.length,
            itemBuilder: (context, index) {
              final client = pendingClients[index];
              return _buildClientCard(client);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openReadingForm(client),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Código: ${client.codCliente}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(client.categoria).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      client.categoria,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getCategoryColor(client.categoria),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      client.direccion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openReadingForm(client),
                  icon: const Icon(Icons.edit),
                  label: const Text('Registrar Lectura'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'residencial':
        return const Color(0xFF2E7D32);
      case 'comercial':
        return Colors.purple;
      case 'industrial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
