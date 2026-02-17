import 'package:coastal_farmer_admin/services/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  final http = DioClient();

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['token']);
        _token = response.data['token'];
        _isAuthenticated = true;
        notifyListeners();
      }
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
