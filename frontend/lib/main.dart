/// Main - Punto de entrada de la aplicación
/// Cooperativa de Servicios Públicos de Electricidad 15 de Noviembre
/// Sistema de Lectura de Medidores

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación de la app (solo vertical)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar colores de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CooperativaApp());
}

/// Widget principal de la aplicación
class CooperativaApp extends StatelessWidget {
  const CooperativaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooperativa 15 de Noviembre',
      debugShowCheckedModeBanner: false,
      
      // Tema global de la aplicación
      theme: ThemeData(
        // Usar ColorScheme basado en el verde institucional oscuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3D1C),
          brightness: Brightness.light,
          primary: const Color(0xFF145226),
          secondary: const Color(0xFFF0E000),
        ),
        
        // Color primario más oscuro
        primaryColor: const Color(0xFF0D3D1C),
        
        // Scaffold background
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        
        // AppBar theme con sombra oscura
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D3D1C),
          foregroundColor: Colors.white,
          elevation: 8,
          centerTitle: true,
          shadowColor: Colors.black.withOpacity(0.5),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        
        // ElevatedButton theme con sombra mejorada
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0E000),
            foregroundColor: const Color(0xFF0D3D1C),
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        
        // Card theme con sombras oscuras
        cardColor: Colors.white,
        
        // Usar Material 3
        useMaterial3: true,
        
        // Tipografía profesional con Google Fonts
        textTheme: GoogleFonts.interTextTheme(
          TextTheme(
            displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: const Color(0xFF0D3D1C)),
            displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: const Color(0xFF0D3D1C)),
            displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0D3D1C)),
            headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF0D3D1C)),
            headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0D3D1C)),
            titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: const Color(0xFF0D3D1C)),
            titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: const Color(0xFF0D3D1C)),
            titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0D3D1C)),
            bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
            bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
            bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
            labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.25),
          ),
        ),
      ),
      
      // Pantalla inicial
      home: const SplashScreen(),
    );
  }
}
