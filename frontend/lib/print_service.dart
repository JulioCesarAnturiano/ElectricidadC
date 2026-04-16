import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'models.dart';

/// Servicio para impresión Bluetooth en impresora térmica
class PrintService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription? _scanSubscription;

  // UUID estándar para impresoras térmicas (puede variar según marca)
  static const String serviceUUID = "49535343-FE7D-4AE5-8FA9-9FAFD205E455";
  static const String characteristicUUID =
      "49535343-8841-43F4-A8D4-ECBE34729BB3";

  // Keys para SharedPreferences
  static const String _printerMacKey = 'printer_mac';
  static const String _printerNameKey = 'printer_name';

  // Colores corporativos (mismo estilo que el resto de la app)
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkerGreen = Color(0xFF1B5E20);

  /// Lista de dispositivos encontrados
  List<BluetoothDevice> discoveredDevices = [];

  /// Estado de conexión
  bool get isConnected =>
      _connectedDevice != null && _writeCharacteristic != null;

  /// Obtiene el dispositivo conectado actualmente
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Obtiene el nombre de la impresora conectada
  String? get connectedPrinterName => _connectedDevice?.platformName;

  // ============================================================
  // MÉTODOS NUEVOS PARA PERMISOS Y PERSISTENCIA
  // ============================================================

  /// Verifica y solicita permisos de Bluetooth y verifica que esté encendido
  /// Retorna true si todo está listo para escanear/conectar
  Future<bool> checkBluetoothAndPermissions(BuildContext context) async {
    // 1. Verificar soporte de Bluetooth
    if (await FlutterBluePlus.isSupported == false) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth no soportado en este dispositivo'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // 2. Solicitar permisos de Bluetooth en runtime
    final permissionsGranted = await _requestBluetoothPermissions(context);
    if (!permissionsGranted) {
      return false;
    }

    // 3. Verificar si Bluetooth está encendido
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (context.mounted) {
        await _showBluetoothOffDialog(context);
      }
      // Verificar de nuevo después del diálogo
      final newState = await FlutterBluePlus.adapterState.first;
      return newState == BluetoothAdapterState.on;
    }

    return true;
  }

  /// Solicita permisos de Bluetooth en runtime
  Future<bool> _requestBluetoothPermissions(BuildContext context) async {
    // Solicitar todos los permisos necesarios
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // Verificar si alguno fue denegado permanentemente
    bool anyPermanentlyDenied = statuses.values.any(
      (status) => status.isPermanentlyDenied,
    );

    if (anyPermanentlyDenied && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Se necesitan permisos de Bluetooth'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Ir a Configuración',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return false;
    }

    // Verificar si todos los permisos críticos fueron concedidos
    bool bluetoothScanGranted =
        statuses[Permission.bluetoothScan]?.isGranted ?? false;
    bool bluetoothConnectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;

    if (!bluetoothScanGranted || !bluetoothConnectGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Se necesitan permisos de Bluetooth para continuar',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _requestBluetoothPermissions(context),
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Muestra diálogo cuando Bluetooth está apagado
  Future<void> _showBluetoothOffDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bluetooth_disabled,
                color: primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bluetooth Apagado',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Para conectar la impresora necesitas activar el Bluetooth.',
          style: GoogleFonts.inter(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryGreen, darkerGreen],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FlutterBluePlus.turnOn();
                } catch (e) {
                  // En algunos dispositivos turnOn no está soportado
                  debugPrint(
                    'No se pudo encender Bluetooth automáticamente: $e',
                  );
                }
              },
              icon: const Icon(Icons.bluetooth, size: 18),
              label: Text(
                'Activar Bluetooth',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene la MAC de la impresora guardada
  Future<String?> getSavedPrinterMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printerMacKey);
  }

  /// Obtiene el nombre de la impresora guardada
  Future<String?> getSavedPrinterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printerNameKey);
  }

  /// Guarda los datos de la impresora conectada
  Future<void> savePrinterData(String mac, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerMacKey, mac);
    await prefs.setString(_printerNameKey, name);
  }

  /// Elimina los datos de la impresora guardada
  Future<void> clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerMacKey);
    await prefs.remove(_printerNameKey);
  }

  /// Intenta reconectar a la impresora guardada previamente
  /// Retorna true si la reconexión fue exitosa
  Future<bool> reconnectToSaved() async {
    final savedMac = await getSavedPrinterMac();
    if (savedMac == null || savedMac.isEmpty) {
      return false;
    }

    try {
      // Verificar que Bluetooth esté encendido
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        return false;
      }

      // Crear dispositivo desde la MAC guardada
      final device = BluetoothDevice.fromId(savedMac);

      // Intentar conectar (sin reintentos para reconexión silenciosa)
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;

      // Descubrir servicios y buscar característica escribible
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // Priorizar writeWithoutResponse para BT 3.0/4.0
          if (characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            return true;
          }
          if (characteristic.properties.write && _writeCharacteristic == null) {
            _writeCharacteristic = characteristic;
          }
        }
      }

      return _writeCharacteristic != null;
    } catch (e) {
      debugPrint('Error en reconexión automática: $e');
      _connectedDevice = null;
      _writeCharacteristic = null;
      return false;
    }
  }

  /// Escanea dispositivos Bluetooth cercanos
  Future<List<BluetoothDevice>> scanForPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    discoveredDevices.clear();

    // Verificar si Bluetooth está encendido
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth no soportado en este dispositivo');
    }

    // Encender Bluetooth si está apagado (solo Android)
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      throw Exception('Por favor, encienda el Bluetooth');
    }

    // Iniciar escaneo
    await FlutterBluePlus.startScan(timeout: timeout);

    // Escuchar resultados
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Filtrar solo dispositivos con nombre (probables impresoras)
        if (r.device.platformName.isNotEmpty &&
            !discoveredDevices.any((d) => d.remoteId == r.device.remoteId)) {
          discoveredDevices.add(r.device);
        }
      }
    });

    // Esperar a que termine el escaneo
    await Future.delayed(timeout);
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    return discoveredDevices;
  }

  /// Conecta a una impresora específica (con reintento automático)
  Future<bool> connectToPrinter(
    BluetoothDevice device, {
    bool isRetry = false,
  }) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;

      // Descubrir servicios
      List<BluetoothService> services = await device.discoverServices();

      // Buscar característica escribible - PRIORIZAR writeWithoutResponse para BT 3.0/4.0
      BluetoothCharacteristic? writeWithoutResponseChar;
      BluetoothCharacteristic? writeChar;

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.writeWithoutResponse) {
            writeWithoutResponseChar = characteristic;
          }
          if (characteristic.properties.write) {
            writeChar = characteristic;
          }
        }
      }

      // Preferir writeWithoutResponse para mejor compatibilidad con BT 3.0
      _writeCharacteristic = writeWithoutResponseChar ?? writeChar;

      if (_writeCharacteristic != null) {
        // Guardar datos de la impresora para reconexión futura
        await savePrinterData(
          device.remoteId.toString(),
          device.platformName.isNotEmpty ? device.platformName : 'Impresora',
        );
        return true;
      }

      // Si no encontramos la característica, intentar con la primera disponible
      if (services.isNotEmpty && services.first.characteristics.isNotEmpty) {
        _writeCharacteristic = services.first.characteristics.first;
        await savePrinterData(
          device.remoteId.toString(),
          device.platformName.isNotEmpty ? device.platformName : 'Impresora',
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error conectando a impresora: $e');

      // Reintentar una vez si no es ya un reintento
      if (!isRetry) {
        debugPrint('Reintentando conexión...');
        await Future.delayed(const Duration(seconds: 2));
        return connectToPrinter(device, isRetry: true);
      }

      _connectedDevice = null;
      _writeCharacteristic = null;
      return false;
    }
  }

  /// Desconecta de la impresora actual
  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (e) {
      print('Error desconectando: $e');
    } finally {
      _connectedDevice = null;
      _writeCharacteristic = null;
    }
  }

  /// Imprime el preaviso
  Future<bool> printPreaviso(Preaviso preaviso) async {
    if (!isConnected) {
      throw Exception('No hay impresora conectada');
    }

    try {
      // Generar bytes ESC/POS para la impresora
      final List<int> bytes = _generateEscPosBytes(preaviso);

      // Enviar en chunks para evitar overflow del buffer
      const int chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length)
            ? i + chunkSize
            : bytes.length;
        final chunk = bytes.sublist(i, end);

        await _writeCharacteristic!.write(
          Uint8List.fromList(chunk),
          withoutResponse:
              _writeCharacteristic!.properties.writeWithoutResponse,
        );

        // Pequeña pausa entre chunks
        await Future.delayed(const Duration(milliseconds: 50));
      }

      return true;
    } catch (e) {
      print('Error imprimiendo: $e');
      return false;
    }
  }

  /// Genera los bytes ESC/POS para el preaviso con nuevo formato
  List<int> _generateEscPosBytes(Preaviso preaviso) {
    List<int> bytes = [];

    final fechaActual = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Ticket termico de 58mm: ~32 caracteres por linea
    const int lineWidth = 32;
    const String separator = '================================';

    String normalize(String value, {String fallback = '-'}) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    List<String> wrapText(String text, int width) {
      final words = text.split(' ');
      final lines = <String>[];
      var current = '';

      for (final word in words) {
        final candidate = current.isEmpty ? word : '$current $word';
        if (candidate.length <= width) {
          current = candidate;
        } else {
          if (current.isNotEmpty) {
            lines.add(current);
          }
          current = word;
        }
      }

      if (current.isNotEmpty) {
        lines.add(current);
      }

      return lines.isEmpty ? ['-'] : lines;
    }

    void addField(String label, String value) {
      final normalized = normalize(value);
      final wrapped = wrapText(normalized, lineWidth - 2);
      bytes.addAll(_textToBytes('$label\n'));
      for (final line in wrapped) {
        bytes.addAll(_textToBytes(' $line\n'));
      }
    }

    // Inicializar impresora
    bytes.addAll([0x1B, 0x40]); // ESC @ - Initialize

    // Encabezado
    bytes.addAll([0x1B, 0x61, 0x01]); // ESC a 1 - Center
    bytes.addAll([0x1B, 0x45, 0x01]); // ESC E 1 - Bold on
    bytes.addAll(_textToBytes('COOPERATIVA 15 DE NOVIEMBRE\n'));
    bytes.addAll(_textToBytes('LECTURAS ELECTRICAS\n'));
    bytes.addAll(_textToBytes('PREAVISO DE COBRANZA\n'));
    bytes.addAll([0x1B, 0x45, 0x00]); // ESC E 0 - Bold off

    bytes.addAll(_textToBytes('$separator\n'));
    bytes.addAll(_textToBytes('FECHA IMPRESION\n'));
    bytes.addAll(_textToBytes('$fechaActual\n'));
    bytes.addAll(_textToBytes('$separator\n'));

    // Alineacion izquierda para detalle
    bytes.addAll([0x1B, 0x61, 0x00]); // ESC a 0 - Left

    bytes.addAll(_textToBytes('DATOS DEL CLIENTE\n'));
    bytes.addAll(_textToBytes('--------------------------------\n'));
    addField('NOMBRE:', preaviso.nombreCliente);
    addField('CODIGO CLIENTE:', preaviso.codCliente);
    addField('DIRECCION:', preaviso.direccion);
    addField('CATEGORIA:', preaviso.categoria);

    bytes.addAll(_textToBytes('--------------------------------\n'));
    bytes.addAll(_textToBytes('DATOS DE LECTURA\n'));
    bytes.addAll(_textToBytes('--------------------------------\n'));
    addField('LECTURA ACTUAL:', preaviso.lecturaActual);
    addField('CONSUMO:', '${normalize(preaviso.consumo)} kWh');
    addField('PERIODO:', preaviso.periodo);

    bytes.addAll(_textToBytes('--------------------------------\n'));
    bytes.addAll(_textToBytes('IMPORTE DEL PREAVISO\n'));
    bytes.addAll(_textToBytes('--------------------------------\n'));
    bytes.addAll([0x1B, 0x45, 0x01]); // Bold on
    addField('MONTO A PAGAR:', 'Bs ${normalize(preaviso.montoAPagar, fallback: '0.00')}');
    bytes.addAll([0x1B, 0x45, 0x00]); // Bold off
    addField('VENCIMIENTO:', preaviso.fechaVencimiento);

    bytes.addAll(_textToBytes('$separator\n'));
    bytes.addAll([0x1B, 0x61, 0x01]); // Center
    bytes.addAll(_textToBytes('DOCUMENTO DE PREAVISO\n'));
    bytes.addAll(_textToBytes('$separator\n'));

    // Avanzar papel y cortar (si la impresora soporta corte)
    bytes.addAll([0x1B, 0x64, 0x05]); // ESC d 5 - Feed 5 lines
    bytes.addAll([0x1D, 0x56, 0x00]); // GS V 0 - Full cut (si soporta)

    return bytes;
  }

  /// Convierte texto a bytes latin1 (compatible con impresoras)
  List<int> _textToBytes(String text) {
    return latin1.encode(text);
  }

  /// Imprime texto de prueba para verificar conexión
  Future<bool> printTest() async {
    if (!isConnected) {
      throw Exception('No hay impresora conectada');
    }

    try {
      List<int> bytes = [];

      // Inicializar
      bytes.addAll([0x1B, 0x40]);

      // Centro
      bytes.addAll([0x1B, 0x61, 0x01]);

      // Texto de prueba
      bytes.addAll(_textToBytes('======================\n'));
      bytes.addAll(_textToBytes('PRUEBA DE IMPRESION\n'));
      bytes.addAll(_textToBytes('Conexion exitosa!\n'));
      bytes.addAll(_textToBytes('======================\n'));

      // Avanzar papel
      bytes.addAll([0x1B, 0x64, 0x03]);

      // Enviar en chunks de 512 bytes
      const int chunkSize = 512;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final chunk = bytes.sublist(i, end);

        await _writeCharacteristic!.write(
          Uint8List.fromList(chunk),
          withoutResponse: _writeCharacteristic!.properties.writeWithoutResponse,
        );

        await Future.delayed(const Duration(milliseconds: 50));
      }

      return true;
    } catch (e) {
      print('Error en prueba de impresión: $e');
      return false;
    }
  }
}
