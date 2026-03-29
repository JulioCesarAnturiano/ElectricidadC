/// Ruta Detail Screen - Pantalla de detalle de una ruta
/// Muestra la lista de clientes con buscador y filtros

import 'package:flutter/material.dart';
import 'models/ruta.dart';
import 'models/cliente.dart';
import 'cliente_detail_screen_clean.dart';

class RutaDetailScreen extends StatefulWidget {
  final Ruta ruta;

  const RutaDetailScreen({super.key, required this.ruta});

  @override
  State<RutaDetailScreen> createState() => _RutaDetailScreenState();
}

class _RutaDetailScreenState extends State<RutaDetailScreen> {
  // Controller para el buscador
  final TextEditingController _busquedaController = TextEditingController();
  
  // Lista filtrada de clientes
  List<Cliente> _clientesFiltrados = [];

  @override
  void initState() {
    super.initState();
    _clientesFiltrados = widget.ruta.clientes;
    _busquedaController.addListener(_filtrarClientes);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  /// Filtra clientes por nombre o código
  void _filtrarClientes() {
    final query = _busquedaController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _clientesFiltrados = widget.ruta.clientes;
      } else {
        _clientesFiltrados = widget.ruta.clientes.where((cliente) {
          return cliente.nombre.toLowerCase().contains(query) ||
                 cliente.codCliente.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  /// Obtiene el ícono según la categoría del cliente
  IconData _iconoCategoria(String categoria) {
    switch (categoria) {
      case 'Residencial':
        return Icons.home;
      case 'Comercial':
        return Icons.store;
      case 'Industrial':
        return Icons.factory;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar verde oscuro con nombre de la ruta
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        title: Text(
          widget.ruta.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Buscador
          Container(
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _busquedaController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.7),
                ),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        onPressed: () {
                          _busquedaController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Info de resultados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '${_clientesFiltrados.length} cliente${_clientesFiltrados.length != 1 ? 's' : ''} encontrado${_clientesFiltrados.length != 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),

          // Lista de clientes
          Expanded(
            child: _clientesFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron clientes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = _clientesFiltrados[index];
                      return _ClienteListItem(
                        cliente: cliente,
                        iconoCategoria: _iconoCategoria(cliente.categoria),
                        onTap: () async {
                          // Navegar a detalle y esperar resultado
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClienteDetailScreen(cliente: cliente),
                            ),
                          );
                          // Actualizar lista al regresar
                          setState(() {});
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

/// Widget de item de lista para un cliente
class _ClienteListItem extends StatelessWidget {
  final Cliente cliente;
  final IconData iconoCategoria;
  final VoidCallback onTap;

  const _ClienteListItem({
    required this.cliente,
    required this.iconoCategoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Código del cliente en chip amarillo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  cliente.codCliente,
                  style: const TextStyle(
                    color: Color(0xFF1B6B2F),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Información del cliente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      cliente.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Dirección
                    Text(
                      cliente.direccion,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Categoría con ícono
                    Row(
                      children: [
                        Icon(
                          iconoCategoria,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cliente.categoria,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cliente.estaAlDia
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  cliente.estadoCuenta,
                  style: TextStyle(
                    color: cliente.estaAlDia ? Colors.green[700] : Colors.orange[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Indicador de lectura registrada
              if (cliente.lecturaActual != null)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
