import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
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

      // Intentar aumentar MTU para mejorar estabilidad/velocidad en tickets largos
      await _tryRequestMtu(device);

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

      // Intentar aumentar MTU para mejorar estabilidad/velocidad en tickets largos
      await _tryRequestMtu(device);

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
      final List<int> bytes = await _generateEscPosBytes(preaviso);

      await _sendEscPosBytes(bytes);

      return true;
    } catch (e) {
      debugPrint('Error imprimiendo formato completo: $e');

      // Fallback ultra compatible (sin logo) para equipos con BLE más limitado
      try {
        final fallbackBytes = _generateSimpleEscPosBytes(preaviso);
        await _sendEscPosBytes(fallbackBytes, forceChunkSize: 20);
        return true;
      } catch (fallbackError) {
        debugPrint('Error imprimiendo fallback: $fallbackError');
        return false;
      }
    }
  }

  Future<void> _tryRequestMtu(BluetoothDevice device) async {
    try {
      await device.requestMtu(185);
    } catch (_) {
      // iOS/algunas impresoras no soportan requestMtu
    }
  }

  Future<void> _sendEscPosBytes(
    List<int> bytes, {
    int? forceChunkSize,
  }) async {
    if (_writeCharacteristic == null) {
      throw Exception('Característica de escritura no disponible');
    }

    final bool withoutResponse =
        _writeCharacteristic!.properties.writeWithoutResponse;

    // Algunos celulares/impresoras fallan con chunks grandes.
    // Usamos MTU real cuando esté disponible y tamaño conservador como mínimo.
    final int mtu = _connectedDevice?.mtuNow ?? 23;
    final int mtuBasedChunk = (mtu - 3).clamp(20, 180);
    final int chunkSize = forceChunkSize ?? mtuBasedChunk;
    final int pauseMs = withoutResponse ? 30 : 10;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);

      await _writeCharacteristic!.write(
        Uint8List.fromList(chunk),
        withoutResponse: withoutResponse,
      );

      await Future.delayed(Duration(milliseconds: pauseMs));
    }
  }

  List<int> _generateSimpleEscPosBytes(Preaviso preaviso) {
    final bytes = <int>[];

    String normalize(String value, {String fallback = '-'}) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    bytes.addAll([0x1B, 0x40]); // Initialize
    bytes.addAll([0x1B, 0x61, 0x01]); // Center
    bytes.addAll(_textToBytes('COOPERATIVA 15 DE NOVIEMBRE\n'));
    bytes.addAll(_textToBytes('PREAVISO DE COBRANZA\n'));
    bytes.addAll(_textToBytes('------------------------------\n'));

    bytes.addAll([0x1B, 0x61, 0x00]); // Left
    bytes.addAll(_textToBytes('NOMBRE: ${normalize(preaviso.nombreCliente)}\n'));
    bytes.addAll(_textToBytes('CODIGO: ${normalize(preaviso.codCliente)}\n'));
    bytes.addAll(_textToBytes('DIRECCION: ${normalize(preaviso.direccion)}\n'));
    bytes.addAll(_textToBytes('CATEGORIA: ${normalize(preaviso.categoria)}\n'));
    bytes.addAll(_textToBytes('LECTURA ACTUAL: ${normalize(preaviso.lecturaActual)}\n'));
    bytes.addAll(_textToBytes('CONSUMO: ${normalize(preaviso.consumo)} kWh\n'));
    bytes.addAll(_textToBytes('MONTO A PAGAR: Bs ${normalize(preaviso.montoAPagar, fallback: '0.00')}\n'));
    bytes.addAll(_textToBytes('------------------------------\n'));

    bytes.addAll([0x1B, 0x64, 0x05]); // Feed
    bytes.addAll([0x1D, 0x56, 0x00]); // Cut
    return bytes;
  }

  /// Genera los bytes ESC/POS para el preaviso con nuevo formato
  Future<List<int>> _generateEscPosBytes(Preaviso preaviso) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    const int lineWidth = 30;
    const String separator = '------------------------------';

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
          continue;
        }
        if (current.isNotEmpty) {
          lines.add(current);
        }
        current = word;
      }

      if (current.isNotEmpty) {
        lines.add(current);
      }

      return lines.isEmpty ? ['-'] : lines;
    }

    void addSection(String title) {
      bytes.addAll(generator.feed(1));
      bytes.addAll(
        generator.text(
          title,
          styles: PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
      );
      bytes.addAll(generator.text(separator));
    }

    void addField(String label, String value, {bool bold = false}) {
      final normalized = normalize(value);
      final prefix = '$label: ';
      final wrapped = wrapText(normalized, lineWidth - prefix.length);

      for (int i = 0; i < wrapped.length; i++) {
        final line = wrapped[i];
        final output = i == 0 ? '$prefix$line' : '${' ' * prefix.length}$line';
        bytes.addAll(
          generator.text(
            output,
            styles: PosStyles(
              align: PosAlign.left,
              bold: i == 0 ? true : bold,
            ),
          ),
        );
      }

      bytes.addAll(generator.feed(1));
    }

    bytes.addAll(generator.reset());
    bytes.addAll(await _buildLogoBytes());
    bytes.addAll(generator.feed(1));

    bytes.addAll(
      generator.text(
        'COOPERATIVA 15 DE NOVIEMBRE',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'LECTURAS ELECTRICAS',
        styles: PosStyles(
          align: PosAlign.center,
          bold: false,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'PREAVISO DE COBRANZA',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
    );

    bytes.addAll(generator.hr(ch: '='));
    addSection('DATOS DEL CLIENTE');
    addField('NOMBRE:', preaviso.nombreCliente);
    addField('CODIGO CLIENTE:', preaviso.codCliente);
    addField('DIRECCION:', preaviso.direccion);
    addField('CATEGORIA:', preaviso.categoria);

    addSection('DATOS DE LECTURA');
    addField('LECTURA ACTUAL:', preaviso.lecturaActual);
    addField('CONSUMO:', '${normalize(preaviso.consumo)} kWh');

    addSection('IMPORTE DEL PREAVISO');
    addField(
      'MONTO A PAGAR',
      'Bs ${normalize(preaviso.montoAPagar, fallback: '0.00')}',
      bold: true,
    );
    bytes.addAll(generator.hr(ch: '='));
    bytes.addAll(generator.feed(4));
    bytes.addAll(generator.cut());

    return bytes;
  }

  Future<List<int>> _buildLogoBytes() async {
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 110,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        return [];
      }

      final width = image.width;
      final height = image.height;
      final rgba = byteData.buffer.asUint8List();
      final widthBytes = (width + 7) ~/ 8;
      final raster = Uint8List(widthBytes * height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final idx = (y * width + x) * 4;
          final r = rgba[idx];
          final g = rgba[idx + 1];
          final b = rgba[idx + 2];
          final a = rgba[idx + 3];

          final luma = (0.299 * r + 0.587 * g + 0.114 * b);
          final isBlack = a > 30 && luma < 180;

          if (isBlack) {
            final byteIndex = y * widthBytes + (x >> 3);
            raster[byteIndex] |= (0x80 >> (x & 7));
          }
        }
      }

      final xL = widthBytes & 0xFF;
      final xH = (widthBytes >> 8) & 0xFF;
      final yL = height & 0xFF;
      final yH = (height >> 8) & 0xFF;

      return [
        0x1B,
        0x61,
        0x00,
        0x1D,
        0x76,
        0x30,
        0x00,
        xL,
        xH,
        yL,
        yH,
        ...raster,
        0x0A,
      ];
    } catch (e) {
      debugPrint('No se pudo cargar logo para impresion: $e');
      return [];
    }
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

      await _sendEscPosBytes(bytes);

      return true;
    } catch (e) {
      print('Error en prueba de impresión: $e');
      return false;
    }
  }
}
