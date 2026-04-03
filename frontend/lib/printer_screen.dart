import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'print_service.dart';
import 'models.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final PrintService _printService = PrintService();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  BluetoothDevice? _connectedDevice;
  String _statusMessage = 'No hay impresora conectada';
  bool _isWebPlatform = false;
  String? _reconnectingPrinterName;

  // Datos de ejemplo para vista previa PDF
  String? _lastClientName;
  String? _lastCategory;
  String? _lastMeterNumber;

  // Colores corporativos
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkerGreen = Color(0xFF1B5E20);

  @override
  void initState() {
    super.initState();
    _isWebPlatform = kIsWeb;
    if (!_isWebPlatform) {
      _initializeBluetooth();
    } else {
      _statusMessage = 'Bluetooth no disponible en navegador web';
    }
  }

  /// Inicializa Bluetooth y verifica permisos al abrir la pantalla
  Future<void> _initializeBluetooth() async {
    // Verificar permisos y estado de Bluetooth
    final isReady = await _printService.checkBluetoothAndPermissions(context);

    if (!isReady) {
      setState(() {
        _statusMessage = 'Bluetooth no disponible';
      });
      return;
    }

    // Intentar reconexión automática si hay impresora guardada
    await _attemptAutoReconnect();
  }

  /// Intenta reconectar a la última impresora usada
  Future<void> _attemptAutoReconnect() async {
    final savedName = await _printService.getSavedPrinterName();
    final savedMac = await _printService.getSavedPrinterMac();

    if (savedMac == null || savedMac.isEmpty) {
      return;
    }

    setState(() {
      _isReconnecting = true;
      _reconnectingPrinterName = savedName ?? 'impresora guardada';
      _statusMessage = 'Reconectando con $_reconnectingPrinterName...';
    });

    final success = await _printService.reconnectToSaved();

    if (mounted) {
      setState(() {
        _isReconnecting = false;
        _reconnectingPrinterName = null;
        if (success) {
          _connectedDevice = _printService.connectedDevice;
          _statusMessage =
              'Conectado a ${_connectedDevice?.platformName ?? savedName}';
        } else {
          _statusMessage = 'Sin conexión';
        }
      });
    }
  }

  Future<void> _scanDevices() async {
    if (_isWebPlatform) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bluetooth no está disponible en navegador web. Use la app móvil.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar permisos y Bluetooth antes de escanear
    final isReady = await _printService.checkBluetoothAndPermissions(context);
    if (!isReady) {
      return;
    }

    setState(() {
      _isScanning = true;
      _devices = [];
      _statusMessage = 'Buscando dispositivos...';
    });

    try {
      final devices = await _printService.scanForPrinters(
        timeout: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _devices = devices;
          _isScanning = false;
          _statusMessage = devices.isEmpty
              ? 'No se encontraron dispositivos'
              : 'Seleccione una impresora';
        });

        if (devices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se encontraron impresoras. Verifica que esté encendida y en modo Bluetooth',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Error al buscar dispositivos';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar dispositivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Conectando a ${device.platformName}...';
    });

    try {
      final success = await _printService.connectToPrinter(device);

      if (mounted) {
        if (success) {
          setState(() {
            _connectedDevice = device;
            _isConnecting = false;
            _statusMessage = 'Conectado a ${device.platformName}';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('✓ Impresora conectada: ${device.platformName}'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _isConnecting = false;
            _statusMessage = 'Error al conectar';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✗ No se pudo conectar. Contraseña: 1234'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _statusMessage = 'Error: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error de conexión. Contraseña: 1234'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _printService.disconnect();
    setState(() {
      _connectedDevice = null;
      _statusMessage = 'Desconectado';
    });
  }

  Future<void> _printTest() async {
    if (!_printService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay impresora conectada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final success = await _printService.printTest();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Prueba de impresión enviada' : 'Error al imprimir',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Widget del indicador LED de conexión
  Widget _buildConnectionLed() {
    final bool isConnected = _connectedDevice != null;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected ? Colors.green : Colors.grey.shade400,
        boxShadow: isConnected
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  /// Widget para la sección de vista previa PDF
  Widget _buildPdfPreviewSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: primaryGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                'Vista Previa del Último PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildPdfInfoRow(
            'Nombre de Cliente:',
            _lastClientName ?? 'Sin datos',
          ),
          const SizedBox(height: 8),
          _buildPdfInfoRow('Categoría:', _lastCategory ?? 'Sin datos'),
          const SizedBox(height: 8),
          _buildPdfInfoRow(
            'Número de Medidor:',
            _lastMeterNumber ?? 'Sin datos',
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Los datos se actualizan al generar un preaviso',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  /// Actualiza los datos de vista previa del PDF
  void updatePdfPreview(
    String clientName,
    String category,
    String meterNumber,
  ) {
    setState(() {
      _lastClientName = clientName;
      _lastCategory = category;
      _lastMeterNumber = meterNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Impresora'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Aviso de web
            if (_isWebPlatform)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bluetooth no disponible en web. Use la app en Android para imprimir.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Estado de conexión con indicador LED
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _connectedDevice != null
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
              child: Row(
                children: [
                  // Indicador LED
                  _buildConnectionLed(),
                  const SizedBox(width: 12),
                  Icon(
                    _connectedDevice != null
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: _connectedDevice != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _connectedDevice != null
                                  ? 'Conectado'
                                  : _isReconnecting
                                  ? 'Reconectando...'
                                  : 'Sin conexión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _connectedDevice != null
                                    ? Colors.green
                                    : Colors.grey.shade700,
                              ),
                            ),
                            if (_isReconnecting) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_connectedDevice != null)
                    IconButton(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      onPressed: _disconnect,
                      tooltip: 'Desconectar',
                    ),
                ],
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
                            (_isScanning || _isWebPlatform || _isConnecting)
                            ? null
                            : _scanDevices,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isScanning ? 'Buscando...' : 'Buscar Dispositivos',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                      onPressed: _printService.isConnected ? _printTest : null,
                      icon: const Icon(Icons.print),
                      label: const Text('Prueba'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de dispositivos
            SizedBox(
              height: 200,
              child: _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isWebPlatform
                                ? Icons.computer
                                : Icons.bluetooth_searching,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isWebPlatform
                                ? 'Función disponible solo en app móvil'
                                : _isScanning
                                ? 'Buscando impresoras cercanas...'
                                : 'Presione "Buscar Dispositivos" para\nencontrar impresoras Bluetooth',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isConnected =
                            _connectedDevice?.remoteId == device.remoteId;
                        final isConnectingThis =
                            _isConnecting &&
                            _statusMessage.contains(device.platformName);

                        return Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? Colors.green.shade50
                                    : primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.print,
                                color: isConnected
                                    ? Colors.green
                                    : primaryGreen,
                              ),
                            ),
                            title: Text(
                              device.platformName.isNotEmpty
                                  ? device.platformName
                                  : 'Dispositivo sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(device.remoteId.toString()),
                            trailing: isConnected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    ],
                                  )
                                : isConnectingThis
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [primaryGreen, darkerGreen],
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isConnecting
                                          ? null
                                          : () => _connectToDevice(device),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Conectar'),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
            ),

            // Sección de vista previa PDF
            _buildPdfPreviewSection(),

            // Instrucciones
            Container(
              padding: const EdgeInsets.all(16),
              color: primaryGreen.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isWebPlatform
                          ? 'Para usar la impresora, instale la app en su dispositivo Android.'
                          : 'Asegúrese de que la impresora térmica esté encendida y en modo de emparejamiento. Contraseña: 1234',
                      style: TextStyle(fontSize: 12, color: primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
