import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'models.dart';

/// Servicio para impresión Bluetooth en impresora térmica
class PrintService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription? _scanSubscription;
  
  // UUID estándar para impresoras térmicas (puede variar según marca)
  static const String serviceUUID = "49535343-FE7D-4AE5-8FA9-9FAFD205E455";
  static const String characteristicUUID = "49535343-8841-43F4-A8D4-ECBE34729BB3";

  /// Lista de dispositivos encontrados
  List<BluetoothDevice> discoveredDevices = [];
  
  /// Estado de conexión
  bool get isConnected => _connectedDevice != null && _writeCharacteristic != null;

  /// Escanea dispositivos Bluetooth cercanos
  Future<List<BluetoothDevice>> scanForPrinters({Duration timeout = const Duration(seconds: 10)}) async {
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

  /// Conecta a una impresora específica
  Future<bool> connectToPrinter(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      
      // Descubrir servicios
      List<BluetoothService> services = await device.discoverServices();
      
      // Buscar el servicio y característica de escritura
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            return true;
          }
        }
      }
      
      // Si no encontramos la característica, intentar con la primera disponible
      if (services.isNotEmpty && services.first.characteristics.isNotEmpty) {
        _writeCharacteristic = services.first.characteristics.first;
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error conectando a impresora: \$e');
      return false;
    }
  }

  /// Desconecta de la impresora actual
  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (e) {
      print('Error desconectando: \$e');
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
      const int chunkSize = 20;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final chunk = bytes.sublist(i, end);
        
        await _writeCharacteristic!.write(
          Uint8List.fromList(chunk),
          withoutResponse: _writeCharacteristic!.properties.writeWithoutResponse,
        );
        
        // Pequeña pausa entre chunks
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      return true;
    } catch (e) {
      print('Error imprimiendo: \$e');
      return false;
    }
  }

  /// Genera los bytes ESC/POS para el preaviso
  List<int> _generateEscPosBytes(Preaviso preaviso) {
    List<int> bytes = [];
    
    // Comandos ESC/POS
    const List<int> ESC = [0x1B];
    const List<int> GS = [0x1D];
    
    // Inicializar impresora
    bytes.addAll([0x1B, 0x40]); // ESC @ - Initialize
    
    // Configurar alineación centrada
    bytes.addAll([0x1B, 0x61, 0x01]); // ESC a 1 - Center
    
    // Texto en negrita para título
    bytes.addAll([0x1B, 0x45, 0x01]); // ESC E 1 - Bold on
    bytes.addAll(_textToBytes('================================\n'));
    bytes.addAll(_textToBytes('      EMPRESA ELECTRICA\n'));
    bytes.addAll(_textToBytes('================================\n'));
    bytes.addAll([0x1B, 0x45, 0x00]); // ESC E 0 - Bold off
    
    bytes.addAll(_textToBytes('PREAVISO DE CONSUMO\n\n'));
    
    // Alineación izquierda para datos
    bytes.addAll([0x1B, 0x61, 0x00]); // ESC a 0 - Left
    
    bytes.addAll(_textToBytes('Cod. Cliente: \${preaviso.codCliente}\n'));
    bytes.addAll(_textToBytes('Nombre: \${preaviso.nombreCliente}\n'));
    bytes.addAll(_textToBytes('Direccion: \${preaviso.direccion}\n'));
    bytes.addAll(_textToBytes('Categoria: \${preaviso.categoria}\n\n'));
    
    bytes.addAll(_textToBytes('--------------------------------\n'));
    bytes.addAll(_textToBytes('DETALLE DE CONSUMO\n'));
    bytes.addAll(_textToBytes('--------------------------------\n'));
    
    bytes.addAll(_textToBytes('Lectura Anterior: \${preaviso.lecturaAnterior}\n'));
    bytes.addAll(_textToBytes('Lectura Actual:   \${preaviso.lecturaActual}\n'));
    bytes.addAll(_textToBytes('Consumo (kWh):    \${preaviso.consumo}\n\n'));
    
    // Monto en negrita
    bytes.addAll([0x1B, 0x45, 0x01]); // Bold on
    bytes.addAll(_textToBytes('--------------------------------\n'));
    bytes.addAll(_textToBytes('MONTO A PAGAR: S/. \${preaviso.montoAPagar}\n'));
    bytes.addAll(_textToBytes('--------------------------------\n'));
    bytes.addAll([0x1B, 0x45, 0x00]); // Bold off
    
    bytes.addAll(_textToBytes('\nPeriodo: \${preaviso.periodo}\n'));
    bytes.addAll(_textToBytes('Vence: \${preaviso.fechaVencimiento}\n\n'));
    
    bytes.addAll(_textToBytes('\${preaviso.mensaje}\n\n'));
    
    // Centrar pie de ticket
    bytes.addAll([0x1B, 0x61, 0x01]); // Center
    bytes.addAll(_textToBytes('================================\n'));
    bytes.addAll(_textToBytes('    Gracias por su pago\n'));
    bytes.addAll(_textToBytes('================================\n'));
    
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
      
      await _writeCharacteristic!.write(Uint8List.fromList(bytes));
      
      return true;
    } catch (e) {
      print('Error en prueba de impresión: \$e');
      return false;
    }
  }
}
