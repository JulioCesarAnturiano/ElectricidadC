import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'print_service.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final PrintService _printService = PrintService();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  String _statusMessage = 'No hay impresora conectada';
  bool _isWebPlatform = false;

  // Colores corporativos
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF43A047);

  @override
  void initState() {
    super.initState();
    _isWebPlatform = kIsWeb;
    if (!_isWebPlatform) {
      _checkBluetoothState();
    } else {
      _statusMessage = 'Bluetooth no disponible en navegador web';
    }
  }

  Future<void> _checkBluetoothState() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        setState(() {
          _statusMessage = 'Bluetooth no soportado en este dispositivo';
        });
        return;
      }

      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        setState(() {
          _statusMessage = 'Por favor, encienda el Bluetooth';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Bluetooth no disponible';
      });
    }
  }

  Future<void> _scanDevices() async {
    if (_isWebPlatform) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth no está disponible en navegador web. Use la app móvil.'),
          backgroundColor: Colors.orange,
        ),
      );
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
      
      setState(() {
        _devices = devices;
        _isScanning = false;
        _statusMessage = devices.isEmpty 
            ? 'No se encontraron dispositivos'
            : 'Seleccione una impresora';
      });
    } catch (e) {
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

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _statusMessage = 'Conectando a ${device.platformName}...';
    });

    try {
      final success = await _printService.connectToPrinter(device);
      
      if (success) {
        setState(() {
          _connectedDevice = device;
          _statusMessage = 'Conectado a ${device.platformName}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conectado a ${device.platformName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _statusMessage = 'Error al conectar';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo conectar a la impresora'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
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
          content: Text(success 
              ? 'Prueba de impresión enviada'
              : 'Error al imprimir'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Impresora'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
          
          // Estado de conexión
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _connectedDevice != null 
                ? Colors.green.shade50 
                : Colors.grey.shade100,
            child: Row(
              children: [
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
                      Text(
                        _connectedDevice != null 
                            ? 'Conectado' 
                            : 'Sin conexión',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _connectedDevice != null 
                              ? Colors.green 
                              : Colors.grey.shade700,
                        ),
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
                  child: ElevatedButton.icon(
                    onPressed: (_isScanning || _isWebPlatform) ? null : _scanDevices,
                    icon: _isScanning 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isScanning ? 'Buscando...' : 'Buscar Dispositivos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _printService.isConnected ? _printTest : null,
                  icon: const Icon(Icons.print),
                  label: const Text('Prueba'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),

          // Lista de dispositivos
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isWebPlatform ? Icons.computer : Icons.bluetooth_searching,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isWebPlatform
                              ? 'Función disponible solo en app móvil'
                              : _isScanning 
                                  ? 'Buscando impresoras cercanas...'
                                  : 'Presione "Buscar Dispositivos" para\nencontrar impresoras Bluetooth',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
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
                      final isConnected = _connectedDevice?.remoteId == device.remoteId;
                      
                      return Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isConnected 
                                  ? Colors.green.shade50 
                                  : const Color(0xFFE8F5E9),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(device.remoteId.toString()),
                          trailing: isConnected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () => _connectToDevice(device),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Conectar'),
                                ),
                        ),
                      );
                    },
                  ),
          ),

          // Instrucciones
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE8F5E9),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isWebPlatform
                        ? 'Para usar la impresora, instale la app en su dispositivo Android.'
                        : 'Asegúrese de que la impresora térmica esté encendida y en modo de emparejamiento.',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryGreen,
                    ),
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
