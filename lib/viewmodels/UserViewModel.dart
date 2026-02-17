import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  // ✅ Android emulator: 10.0.2.2
  // ✅ Chrome/Windows: 127.0.0.1
  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';

  final _storage = const FlutterSecureStorage();

  bool loading = false;
  String? error;
  String? token;

  User? user; 

  Future<void> init() async {
    token = await _storage.read(key: 'token');
    if (token != null) {
      await loadUser();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/login'); // ✅ adjust if your route differs

      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(res.body);
      print(data);
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        token = data['token']?.toString();
        if (token == null) {
          error = 'Token not found in response';
          return false;
        }
        await _storage.write(key: 'token', value: token);
        // load current user after successful login
        await loadUser();
        return true;
      } else {
        // Laravel often returns: {message: "..."} or {errors: {...}}
        error = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Login failed (${res.statusCode})';
        return false;
      }
    } catch (e) {
      error = 'Network error: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String dateOfBirth) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/register');

      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
        }),
      );

      final data = jsonDecode(res.body);
      print(data);
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        token = data['token']?.toString();
        if (token != null) {
          await _storage.write(key: 'token', value: token);
        }
        return true;
      } else {
        error = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Registration failed (${res.statusCode})';
        return false;
      }
    } catch (e) {
      error = 'Network error: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    user = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  // Load user from /api/me using saved token
  Future<bool> loadUser() async {
    final res = await me();
    print(res);
    if (res == null) return false;

  
  
    try {
    final dynamic raw = res['user'] ?? res;

    final userMap = Map<String, dynamic>.from(raw as Map);
    user = User.fromJson(userMap);
      print(user);
      notifyListeners();
      return true;
    } catch (e) {
      // parsing error
      error = 'Failed to parse user data: $e';
       print(error);
      return false;
    }
  }

  // Example: call /api/me with Bearer token
  Future<Map<String, dynamic>?> me() async {
    final t = token ?? await _storage.read(key: 'token');
    if (t == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $t',
        },
      );

      if (res.statusCode == 200) {
        print(200);
        return Map<String, dynamic>.from(jsonDecode(res.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
