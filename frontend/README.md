# App de Lecturas Eléctricas

Aplicación móvil Flutter para electricistas que necesitan registrar lecturas de medidores e imprimir preavisos por Bluetooth.

## Características

- ✅ Login con usuario/contraseña
- ✅ Dashboard con rutas asignadas
- ✅ Mapa con ubicación de casas pendientes (puntos rojos) y registradas (puntos verdes)
- ✅ Formulario de registro de lectura con diferentes tipos (normal, casa cerrada, etc.)
- ✅ Envío de lectura al backend y recepción del preaviso
- ✅ Impresión del preaviso por Bluetooth en impresora térmica

## Configuración

### 1. API Key de Google Maps

Para que el mapa funcione, necesitas una API Key de Google Maps:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un proyecto o selecciona uno existente
3. Habilita "Maps SDK for Android" y "Maps SDK for iOS"
4. Crea una API Key
5. Reemplaza `TU_API_KEY_DE_GOOGLE_MAPS_AQUI` en:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift` (si usas iOS)

### 2. Credenciales de prueba

Para probar el login:
- **Usuario:** `demo`
- **Contraseña:** `demo`

O también:
- **Usuario:** `electricista1`
- **Contraseña:** `123456`

### 3. Conectar el Backend Real

Cuando tengas el backend listo:

1. Abre `lib/api_config.dart`
2. Cambia `baseUrl` por la URL de tu backend
3. Cambia `useMockData` a `false`

```dart
class ApiConfig {
  static const String baseUrl = 'https://tu-backend.com/api';
  static const bool useMockData = false;  // Cambiar a false
}
```

## Estructura del Proyecto

```
lib/
├── main.dart              # Punto de entrada
├── api_config.dart        # Configuración de APIs
├── models.dart            # Modelos de datos
├── mock_data.dart         # Datos de prueba
├── services.dart          # Servicios API
├── providers.dart         # Estado con Provider
├── print_service.dart     # Impresión Bluetooth
├── login_screen.dart      # Pantalla de login
├── dashboard_screen.dart  # Dashboard con rutas
├── route_detail_screen.dart # Mapa y lista de clientes
├── reading_form_screen.dart # Formulario de lectura
└── printer_screen.dart    # Configuración de impresora
```

## APIs Esperadas del Backend

### POST /auth/login
```json
Request:
{
  "username": "string",
  "password": "string"
}

Response:
{
  "id": "string",
  "username": "string",
  "nombre": "string",
  "token": "string"
}
```

### GET /routes
```json
Response:
[
  {
    "id": "string",
    "nombre": "string",
    "total_clientes": 15,
    "clientes_pendientes": 10,
    "clientes_registrados": 5
  }
]
```

### GET /clients?route_id={id}
```json
Response:
[
  {
    "cod_cliente": "string",
    "nombre": "string",
    "categoria": "string",
    "direccion": "string",
    "latitud": -12.0769,
    "longitud": -77.0822,
    "registrado": false,
    "ultima_lectura": "15420",
    "fecha_ultima_lectura": "2026-02-15"
  }
]
```

### POST /readings
```json
Request:
{
  "cod_cliente": "string",
  "tipo_lectura": "NORMAL|CERRADA|DANADO|SIN_ACCESO|NO_EXISTE",
  "lectura_medidor": "string",
  "observaciones": "string",
  "fecha_registro": "2026-03-27T12:00:00Z"
}

Response (Preaviso):
{
  "cod_cliente": "string",
  "nombre_cliente": "string",
  "direccion": "string",
  "categoria": "string",
  "lectura_anterior": "string",
  "lectura_actual": "string",
  "consumo": "string",
  "monto_a_pagar": "string",
  "fecha_vencimiento": "string",
  "periodo": "string",
  "mensaje": "string"
}
```

## Ejecutar la App

```bash
cd frontend
flutter pub get
flutter run
```

## Impresora Bluetooth

La app es compatible con impresoras térmicas que usan protocolo ESC/POS estándar.
Para conectar una impresora:

1. Enciende la impresora y ponla en modo emparejamiento
2. En la app, ve al Dashboard > ícono de impresora (arriba derecha)
3. Presiona "Buscar Dispositivos"
4. Selecciona tu impresora
5. Haz una prueba de impresión

## Licencia

MIT
