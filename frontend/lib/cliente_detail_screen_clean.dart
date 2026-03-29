/// Cliente Detail Screen - Pantalla de detalle y registro de lectura
/// Permite registrar la lectura del medidor de un cliente

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/cliente.dart';

class ClienteDetailScreen extends StatefulWidget {
  final Cliente cliente;

  const ClienteDetailScreen({super.key, required this.cliente});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  // Controller para lectura actual
  final TextEditingController _lecturaController = TextEditingController();
  
  // Controller para observaciones
  final TextEditingController _observacionesController = TextEditingController();
  
  // Key para validación del formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Tipo de lectura seleccionado
  String _tipoLectura = 'Lectura Normal';
  
  // Opciones de tipo de lectura
  final List<String> _tiposLectura = [
    'Lectura Normal',
    'Casa Cerrada',
    'Medidor Dañado',
    'Sin Acceso',
  ];

  @override
  void initState() {
    super.initState();
    // Si ya tiene lectura registrada, mostrarla
    if (widget.cliente.lecturaActual != null) {
      _lecturaController.text = widget.cliente.lecturaActual.toString();
    }
    if (widget.cliente.tipoLectura != null) {
      _tipoLectura = widget.cliente.tipoLectura!;
    }
    if (widget.cliente.observaciones != null) {
      _observacionesController.text = widget.cliente.observaciones!;
    }
  }

  @override
  void dispose() {
    _lecturaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  /// Obtiene el ícono según la categoría
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

  /// Valida y muestra el diálogo de confirmación
  void _calcularYRegistrar() {
    if (!_formKey.currentState!.validate()) return;

    final int lecturaActual = int.parse(_lecturaController.text);
    final int consumo = lecturaActual - widget.cliente.lecturaAnterior;
    final double monto = consumo * 0.85; // Tarifa placeholder

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Resumen de Lectura',
          style: GoogleFonts.inter(
            color: const Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResumenItem(label: 'Cliente', valor: widget.cliente.nombre),
            _ResumenItem(label: 'Código', valor: widget.cliente.codCliente),
            const Divider(),
            _ResumenItem(
              label: 'Lectura Anterior',
              valor: '${widget.cliente.lecturaAnterior} kWh',
            ),
            _ResumenItem(label: 'Lectura Actual', valor: '$lecturaActual kWh'),
            const Divider(),
            _ResumenItem(
              label: 'Consumo',
              valor: '$consumo kWh',
              destacado: true,
            ),
            _ResumenItem(
              label: 'Monto Estimado',
              valor: 'Bs. ${monto.toStringAsFixed(2)}',
              destacado: true,
            ),
            const Divider(),
            _ResumenItem(label: 'Tipo', valor: _tipoLectura),
            if (_observacionesController.text.isNotEmpty)
              _ResumenItem(
                label: 'Observaciones',
                valor: _observacionesController.text,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Registrar la lectura en el objeto cliente
              widget.cliente.lecturaActual = lecturaActual;
              widget.cliente.tipoLectura = _tipoLectura;
              widget.cliente.observaciones = _observacionesController.text.isEmpty
                  ? null
                  : _observacionesController.text;

              // Cerrar diálogo
              Navigator.pop(context);

              // Mostrar SnackBar de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Lectura registrada correctamente',
                        style: GoogleFonts.inter(),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              // Regresar a la lista
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0E000),
              foregroundColor: const Color(0xFF2E7D32),
            ),
            child: Text(
              'Confirmar e Imprimir',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar verde oscuro con nombre del cliente
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        title: Text(
          widget.cliente.nombre,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card con datos del cliente con sombra mejorada
              Card(
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Código del cliente
                      _DatoCliente(
                        icono: Icons.qr_code,
                        etiqueta: 'Cod. Cliente',
                        valor: widget.cliente.codCliente,
                      ),
                      const Divider(),
                      // Dirección
                      _DatoCliente(
                        icono: Icons.location_on,
                        etiqueta: 'Dirección',
                        valor: widget.cliente.direccion,
                      ),
                      const Divider(),
                      // Categoría
                      _DatoCliente(
                        icono: _iconoCategoria(widget.cliente.categoria),
                        etiqueta: 'Categoría',
                        valor: widget.cliente.categoria,
                      ),
                      const Divider(),
                      // Lectura anterior
                      _DatoCliente(
                        icono: Icons.speed,
                        etiqueta: 'Lectura Anterior',
                        valor: '${widget.cliente.lecturaAnterior} kWh',
                        destacado: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título sección registro
              Text(
                'Registrar Lectura',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2E7D32),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Campo Lectura Actual
              TextFormField(
                controller: _lecturaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Lectura Actual (kWh)',
                  labelStyle: GoogleFonts.inter(),
                  prefixIcon: const Icon(
                    Icons.speed,
                    color: Color(0xFF2E7D32),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la lectura actual';
                  }
                  final lectura = int.tryParse(value);
                  if (lectura == null) {
                    return 'Ingrese un número válido';
                  }
                  if (lectura < widget.cliente.lecturaAnterior) {
                    return 'La lectura debe ser mayor o igual a ${widget.cliente.lecturaAnterior}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selector Tipo de Lectura
              DropdownButtonFormField<String>(
                value: _tipoLectura,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Tipo de Lectura',
                  labelStyle: GoogleFonts.inter(),
                  prefixIcon: const Icon(
                    Icons.category,
                    color: Color(0xFF2E7D32),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                ),
                items: _tiposLectura.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo, style: GoogleFonts.inter()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoLectura = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campo Observaciones
              TextFormField(
                controller: _observacionesController,
                maxLines: 3,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  labelStyle: GoogleFonts.inter(),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(
                      Icons.note,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Botón Calcular y Registrar con sombra mejorada
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _calcularYRegistrar,
                  icon: const Icon(Icons.calculate, size: 24),
                  label: Text(
                    'CALCULAR Y REGISTRAR',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0E000),
                    foregroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar un dato del cliente
class _DatoCliente extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final bool destacado;

  const _DatoCliente({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icono,
            size: 20,
            color: destacado ? const Color(0xFF2E7D32) : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                Text(
                  valor,
                  style: GoogleFonts.inter(
                    color: destacado ? const Color(0xFF2E7D32) : Colors.black87,
                    fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
                    fontSize: destacado ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar item en el resumen
class _ResumenItem extends StatelessWidget {
  final String label;
  final String valor;
  final bool destacado;

  const _ResumenItem({
    required this.label,
    required this.valor,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              valor,
              style: GoogleFonts.inter(
                fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
                color: destacado ? const Color(0xFF2E7D32) : Colors.black87,
                fontSize: destacado ? 15 : 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
