import 'package:flutter/material.dart';
import 'models.dart';
import 'services.dart';

/// Provider para manejar el estado de autenticación
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;
  String? get token => _currentUser?.token;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Usuario o contraseña incorrectos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Provider para manejar rutas y clientes
class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();
  
  List<RouteModel> _routes = [];
  List<Client> _currentClients = [];
  RouteModel? _selectedRoute;
  bool _isLoading = false;
  String? _error;

  List<RouteModel> get routes => _routes;
  List<Client> get currentClients => _currentClients;
  List<Client> get pendingClients => _currentClients.where((c) => !c.registrado).toList();
  RouteModel? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setAuthToken(String token) {
    _routeService.setAuthToken(token);
  }

  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _routes = await _routeService.getRoutes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error cargando rutas';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRoute(RouteModel route) async {
    _selectedRoute = route;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentClients = await _routeService.getClientsByRoute(route.id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error cargando clientes';
      _isLoading = false;
      notifyListeners();
    }
  }

  void markClientAsRegistered(String codCliente) {
    final index = _currentClients.indexWhere((c) => c.codCliente == codCliente);
    if (index != -1) {
      // Crear una copia del cliente con registrado = true
      final client = _currentClients[index];
      _currentClients[index] = Client(
        codCliente: client.codCliente,
        nombre: client.nombre,
        categoria: client.categoria,
        direccion: client.direccion,
        latitud: client.latitud,
        longitud: client.longitud,
        registrado: true,
        ultimaLectura: client.ultimaLectura,
        fechaUltimaLectura: client.fechaUltimaLectura,
      );
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedRoute = null;
    _currentClients = [];
    notifyListeners();
  }
}

/// Provider para manejar lecturas
class ReadingProvider extends ChangeNotifier {
  final ReadingService _readingService = ReadingService();
  
  bool _isLoading = false;
  String? _error;
  Preaviso? _lastPreaviso;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Preaviso? get lastPreaviso => _lastPreaviso;

  void setAuthToken(String token) {
    _readingService.setAuthToken(token);
  }

  Future<Preaviso?> registrarLectura(Reading reading, Client client) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final preaviso = await _readingService.registrarLectura(reading, client);
      _lastPreaviso = preaviso;
      _isLoading = false;
      notifyListeners();
      return preaviso;
    } catch (e) {
      _error = 'Error registrando lectura';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearLastPreaviso() {
    _lastPreaviso = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
