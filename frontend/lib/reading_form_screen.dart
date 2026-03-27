import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'models.dart';
import 'print_service.dart';

class ReadingFormScreen extends StatefulWidget {
  final Client client;

  const ReadingFormScreen({super.key, required this.client});

  @override
  State<ReadingFormScreen> createState() => _ReadingFormScreenState();
}

class _ReadingFormScreenState extends State<ReadingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lecturaController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  TipoLectura _tipoLectura = TipoLectura.normal;
  bool _isSubmitting = false;
  Preaviso? _preaviso;
  bool _isPrinting = false;

  @override
  void dispose() {
    _lecturaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _submitReading() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final reading = Reading(
      codCliente: widget.client.codCliente,
      tipoLectura: _tipoLectura,
      lecturaMedidor: _tipoLectura == TipoLectura.normal 
          ? _lecturaController.text 
          : null,
      observaciones: _observacionesController.text.isNotEmpty 
          ? _observacionesController.text 
          : null,
      fechaRegistro: DateTime.now(),
    );

    final readingProvider = context.read<ReadingProvider>();
    final preaviso = await readingProvider.registrarLectura(reading, widget.client);

    setState(() {
      _isSubmitting = false;
      _preaviso = preaviso;
    });

    if (preaviso != null) {
      // Marcar cliente como registrado
      context.read<RouteProvider>().markClientAsRegistered(widget.client.codCliente);
      
      // Mostrar diálogo para imprimir
      _showPrintDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar la lectura'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text('Lectura Registrada'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '¡Lectura registrada correctamente!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Cliente:', _preaviso!.nombreCliente),
                    _buildInfoRow('Lectura:', _preaviso!.lecturaActual),
                    _buildInfoRow('Consumo:', '${_preaviso!.consumo} kWh'),
                    _buildInfoRow('Monto:', 'S/. ${_preaviso!.montoAPagar}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Botón continuar sin imprimir (para pruebas)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Continuar sin imprimir'),
            ),
            // Botón de imprimir
            ElevatedButton.icon(
              onPressed: _isPrinting ? null : () => _printPreaviso(dialogContext),
              icon: _isPrinting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.print),
              label: Text(_isPrinting ? 'Imprimiendo...' : 'Imprimir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printPreaviso(BuildContext dialogContext) async {
    setState(() {
      _isPrinting = true;
    });

    try {
      final printService = PrintService();
      
      // Verificar si hay impresora conectada
      if (!printService.isConnected) {
        // Mostrar mensaje para conectar impresora - NO CIERRA EL DIÁLOGO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No hay impresora conectada. Vaya a configurar impresora.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isPrinting = false;
        });
        return; // No continuar, debe imprimir
      }

      final success = await printService.printPreaviso(_preaviso!);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preaviso impreso correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Solo puede continuar si imprimió exitosamente
        Navigator.pop(dialogContext); // Cerrar diálogo
        Navigator.pop(context); // Volver a la lista
      } else {
        // Error al imprimir - NO CIERRA EL DIÁLOGO
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al imprimir. Intente de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isPrinting = false;
        });
        return; // No continuar, debe reintentar
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isPrinting = false;
      });
      // No continuar, debe reintentar
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Lectura'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info del cliente
              Card(
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
                              Icons.person,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.client.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Código: ${widget.client.codCliente}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildClientInfoRow(Icons.location_on, widget.client.direccion),
                      const SizedBox(height: 8),
                      _buildClientInfoRow(Icons.category, 'Categoría: ${widget.client.categoria}'),
                      // NOTA: No mostrar última lectura para evitar fraudes
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tipo de lectura
              Text(
                'Tipo de Lectura',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: TipoLectura.values.map((tipo) {
                    return RadioListTile<TipoLectura>(
                      title: Text(tipo.nombre),
                      value: tipo,
                      groupValue: _tipoLectura,
                      onChanged: (value) {
                        setState(() {
                          _tipoLectura = value!;
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Campo de lectura (solo si es lectura normal)
              if (_tipoLectura == TipoLectura.normal) ...[
                Text(
                  'Lectura del Medidor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lecturaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Valor del medidor (kWh)',
                    hintText: 'Ej: 15420',
                    prefixIcon: const Icon(Icons.speed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (value) {
                    if (_tipoLectura == TipoLectura.normal) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la lectura del medidor';
                      }
                      final lectura = int.tryParse(value);
                      if (lectura == null) {
                        return 'Ingrese un número válido';
                      }
                      // La validación contra lectura anterior se hace en el backend
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],
              
              // Observaciones
              Text(
                'Observaciones (Opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observacionesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ingrese observaciones si es necesario...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.note),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botón de enviar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReading,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSubmitting ? 'Registrando...' : 'Registrar Lectura',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildClientInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
