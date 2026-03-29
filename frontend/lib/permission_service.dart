/// Servicio de Permisos - Gestiona avisos de Bluetooth y Ubicación
/// Muestra notificaciones pidiendo al usuario activar servicios necesarios
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionService {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkerGreen = Color(0xFF1B5E20);

  /// Verifica ubicación al abrir el mapa y solicita activarla si está desactivada
  static Future<bool> checkAndRequestLocation(BuildContext context) async {
    // Primero verificar si el servicio de ubicación está activado
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled && context.mounted) {
      await _showLocationServiceDialog(context);
      return false;
    }

    // Luego verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await _showLocationPermissionDeniedDialog(context);
      }
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Muestra diálogo pidiendo activar ubicación
  static Future<void> _showLocationServiceDialog(BuildContext context) async {
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
                Icons.location_off,
                color: primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Activar Ubicación',
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
          'Esta aplicación necesita que actives la ubicación para mostrar el mapa con las rutas de clientes.',
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
                await Geolocator.openLocationSettings();
              },
              icon: const Icon(Icons.settings, size: 18),
              label: Text(
                'Activar Ahora',
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

  /// Muestra diálogo cuando el permiso fue denegado permanentemente
  static Future<void> _showLocationPermissionDeniedDialog(
      BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permiso Denegado',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'El permiso de ubicación fue denegado permanentemente. Por favor, ve a la configuración de la app y habilita el permiso.',
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
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Abrir Configuración'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Verifica Bluetooth y muestra diálogo si está desactivado
  static Future<bool> checkAndRequestBluetooth(BuildContext context) async {
    var status = await Permission.bluetoothConnect.status;

    if (status.isDenied) {
      if (context.mounted) {
        await _showBluetoothDialog(context);
      }
      status = await Permission.bluetoothConnect.request();
    }

    if (status.isPermanentlyDenied && context.mounted) {
      await _showBluetoothPermissionDeniedDialog(context);
      return false;
    }

    return status.isGranted;
  }

  /// Muestra diálogo pidiendo activar Bluetooth
  static Future<void> _showBluetoothDialog(BuildContext context) async {
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
                'Activar Bluetooth',
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
          'Esta aplicación necesita que actives el Bluetooth para conectar con la impresora térmica.',
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
                await [
                  Permission.bluetoothScan,
                  Permission.bluetoothConnect,
                  Permission.bluetooth,
                ].request();
              },
              icon: const Icon(Icons.bluetooth, size: 18),
              label: Text(
                'Activar Ahora',
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

  /// Muestra diálogo cuando el permiso de Bluetooth fue denegado permanentemente
  static Future<void> _showBluetoothPermissionDeniedDialog(
      BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permiso Denegado',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'El permiso de Bluetooth fue denegado. Por favor, ve a la configuración de la app y habilita el permiso.',
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
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Abrir Configuración'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
