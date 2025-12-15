import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muzzfund_admin/network/admin_client.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminClient _client = AdminClient();

  String? _token;
  String? _username;
  String? _role;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  String? get username => _username;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AdminAuthProvider() {
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('admin_token');
      if (storedToken != null && storedToken.isNotEmpty) {
        // Check if token is expired
        if (!JwtDecoder.isExpired(storedToken)) {
          _token = storedToken;
          _extractTokenClaims(storedToken);
          _client.setAuthToken(storedToken);
          notifyListeners();
        } else {
          // Token expired, clear it
          await prefs.remove('admin_token');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading stored token: $e');
    }
  }

  void _extractTokenClaims(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      _username = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
          decodedToken['name'] ??
          decodedToken['username'];
      _role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
          decodedToken['role'];
    } catch (e) {
      if (kDebugMode) print('Error extracting token claims: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.login(username, password);

      if (response['success'] == true || response['data'] != null) {
        _token = response['data'] ?? response['token'];
        if (_token != null) {
          _extractTokenClaims(_token!);
          _client.setAuthToken(_token);

          // Store token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_token', _token!);

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _error = response['message'] ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> autoLogin() async {
    // Auto-login with hardcoded admin credentials
    return await login('admin', 'admin');
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _role = null;
    _error = null;
    _client.setAuthToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');

    notifyListeners();
  }

  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      final response = await _client.refreshToken();
      if (response['success'] == true || response['data'] != null) {
        _token = response['data'] ?? response['token'];
        if (_token != null) {
          _extractTokenClaims(_token!);
          _client.setAuthToken(_token);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_token', _token!);

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Refresh token error: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
