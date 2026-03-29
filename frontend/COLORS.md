# Sistema de Colores - Cooperativa 15 de Noviembre

## Paleta de Colores Principal

### Verde Corporativo
- **Primary Green**: `#2E7D32` - `Color(0xFF2E7D32)`
  - Color principal del sistema
  - Usado en: AppBar, botones principales, iconos, títulos

- **Darker Green**: `#1B5E20` - `Color(0xFF1B5E20)`
  - Verde más oscuro para degradados y contraste
  - Usado en: Degradados (primaryGreen → darkerGreen)

- **Accent Yellow**: `#F0E000` - `Color(0xFFF0E000)`
  - Color de acento para elementos destacados
  - Usado en: FABs, badges, alertas importantes

## Uso de Degradados

### RadialGradient (Fondos)
```dart
gradient: RadialGradient(
  center: Alignment.center,
  radius: 1.2,
  colors: [primaryGreen, darkerGreen],
  stops: [0.3, 1.0],
)
```
- Usado en: Splash Screen, Login Screen
- Efecto: Centro más claro, esquinas más oscuras

### LinearGradient (Botones y Cards)
```dart
gradient: LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [primaryGreen, darkerGreen],
)
```
- Usado en: Botones principales, cards destacadas
- Efecto: Degradado sutil de arriba hacia abajo

## Sombras

### Sombras Circulares (Logos)
```dart
decoration: BoxDecoration(
  shape: BoxShape.circle,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 15),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 25,
      offset: const Offset(0, 8),
    ),
  ],
)
```

### Sombras de Elevación (Cards y Botones)
```dart
boxShadow: [
  BoxShadow(
    color: primaryGreen.withOpacity(0.4),
    blurRadius: 15,
    offset: const Offset(0, 8),
  ),
]
```

## Colores Auxiliares

- **Error/Danger**: `Colors.red` - Para mensajes de error
- **Success**: `Colors.green` - Para confirmaciones
- **Warning**: `Colors.orange` - Para advertencias
- **Info**: `primaryGreen` - Para información general

## Archivos que Usan los Colores

Todos los siguientes archivos están sincronizados con esta paleta:
- `main.dart`
- `splash_screen.dart`
- `login_screen.dart`
- `dashboard_screen.dart`
- `route_detail_screen.dart`
- `reading_form_screen.dart`
- `printer_screen.dart`
- `permission_service.dart`
- `home_screen.dart`
- `ruta_detail_screen.dart`
- `cliente_detail_screen_clean.dart`

## Notas de Diseño

1. **Consistencia**: Todos los elementos verdes deben usar `primaryGreen` o `darkerGreen`
2. **Degradados**: Siempre usar `primaryGreen → darkerGreen` para mantener coherencia
3. **Sombras**: Usar sombras oscuras sutiles para dar profundidad sin distraer
4. **Accesibilidad**: El contraste entre texto blanco y `primaryGreen` es AAA compliant
