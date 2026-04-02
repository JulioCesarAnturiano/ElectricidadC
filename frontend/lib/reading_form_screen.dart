import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers.dart';
import 'models.dart';
import 'print_service.dart';
import 'pdf_service.dart';

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

  // Colores profesionales
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkerGreen = Color(0xFF1B5E20);
  static const Color accentYellow = Color(0xFFF0E000);

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
      lecturaMedidor:
          _tipoLectura == TipoLectura.normal ? _lecturaController.text : null,
      observaciones: _observacionesController.text.isNotEmpty
          ? _observacionesController.text
          : null,
      fechaRegistro: DateTime.now(),
    );

    final readingProvider = context.read<ReadingProvider>();
    final preaviso =
        await readingProvider.registrarLectura(reading, widget.client);

    setState(() {
      _isSubmitting = false;
      _preaviso = preaviso;
    });

    if (preaviso != null) {
      // Marcar cliente como registrado
      context
          .read<RouteProvider>()
          .markClientAsRegistered(widget.client.codCliente);

      // Mostrar diálogo para imprimir
      _showPrintDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Error al registrar la lectura',
                style: GoogleFonts.inter(),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.check_circle, color: Colors.green.shade600),
              ),
              const SizedBox(width: 12),
              Text(
                'Lectura Registrada',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡Lectura registrada correctamente!',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Cliente:', _preaviso!.nombreCliente),
                    const SizedBox(height: 8),
                    _buildInfoRow('Lectura:', _preaviso!.lecturaActual),
                    const SizedBox(height: 8),
                    _buildInfoRow('Consumo:', '${_preaviso!.consumo} kWh'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentYellow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monto:',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          Text(
                            'S/. ${_preaviso!.montoAPagar}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              child: Text(
                'Continuar sin imprimir',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            // Botón de imprimir
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryGreen, darkerGreen],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed:
                    _isPrinting ? null : () => _printPreaviso(dialogContext),
                icon: _isPrinting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.print, size: 20),
                label: Text(
                  _isPrinting ? 'Imprimiendo...' : 'Imprimir',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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

      // SOLO generar PDF (sin imprimir por ahora)
      final pdfPath = await printService.generatePdfPreaviso(_preaviso!);

      if (pdfPath.isNotEmpty) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'PDF generado exitosamente',
                    style: GoogleFonts.inter(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );

        // Cerrar diálogos y volver a la lista
        Navigator.pop(dialogContext); // Cerrar diálogo
        Navigator.pop(context); // Volver a la lista
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Registrar Lectura',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info del cliente con sombras profesionales
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryGreen.withOpacity(0.15),
                                    primaryGreen.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: primaryGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.client.nombre,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentYellow.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Código: ${widget.client.codCliente}',
                                      style: GoogleFonts.inter(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        _buildClientInfoRow(
                            Icons.location_on, widget.client.direccion),
                        const SizedBox(height: 10),
                        _buildClientInfoRow(Icons.category,
                            'Categoría: ${widget.client.categoria}'),
                        // NOTA: No mostrar última lectura para evitar fraudes
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tipo de lectura
              Text(
                'Tipo de Lectura',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: TipoLectura.values.map((tipo) {
                      return RadioListTile<TipoLectura>(
                        title: Text(
                          tipo.nombre,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        value: tipo,
                        groupValue: _tipoLectura,
                        onChanged: (value) {
                          setState(() {
                            _tipoLectura = value!;
                          });
                        },
                        activeColor: primaryGreen,
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Campo de lectura (solo si es lectura normal)
              if (_tipoLectura == TipoLectura.normal) ...[
                Text(
                  'Lectura del Medidor',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _lecturaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Valor del medidor (kWh)',
                      labelStyle: GoogleFonts.inter(),
                      hintText: 'Ej: 15420',
                      prefixIcon: const Icon(Icons.speed, color: primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
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
                ),
                const SizedBox(height: 28),
              ],

              // Observaciones
              Text(
                'Observaciones (Opcional)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    hintText: 'Ingrese observaciones si es necesario...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.note, color: primaryGreen),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Botón de enviar con sombra profesional
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryGreen, darkerGreen],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReading,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, size: 24),
                  label: Text(
                    _isSubmitting ? 'Registrando...' : 'Registrar Lectura',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
