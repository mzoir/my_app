import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ClientViewModel extends ChangeNotifier {
  // ✅ Android emulator: 10.0.2.2
  // ✅ Web/Windows: 127.0.0.1
  final String baseUrl = kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

  final _storage = const FlutterSecureStorage();

  bool loading = false;
  String? error;

  String? tempId; // returned from start
  String? token;  // returned from setPassword

  // ================= Helpers =================
  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final dynamic decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    final Map<String, dynamic> data = decoded is Map<String, dynamic> ? decoded : {};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    // Laravel often: {message: "..."} or {errors:{...}}
    final msg = data['message']?.toString() ??
        (data['errors'] is Map ? (data['errors'] as Map).values.first.toString() : null) ??
        'Request failed (${res.statusCode})';

    throw Exception(msg);
  }

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    error = e;
    notifyListeners();
  }

  // ================= API Steps =================

  /// STEP 1: start registration -> returns temp_id
  Future<bool> start({
    required String name,
    required String email,
    required String phone,
    String? ville,
    String? dateOfBirth, // yyyy-mm-dd
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final data = await _post('/api/register/user/start', {
        'name': name,
        'email': email,
        'phone': phone,
        'ville': ville,
        'date_of_birth': dateOfBirth,
      });

      tempId = data['temp_id']?.toString();
      if (tempId == null) throw Exception("temp_id manquant dans la réponse");

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// STEP 2: verify email otp
  Future<bool> verifyEmail({required String code}) async {
    if (tempId == null) {
      _setError("temp_id manquant. Fais start() d'abord.");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _post('/api/register/user/verify-email', {
        'temp_id': tempId,
        'code': code,
      });
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// STEP 3: verify phone otp
  Future<bool> verifyPhone({required String code}) async {
    if (tempId == null) {
      _setError("temp_id manquant. Fais start() d'abord.");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _post('/api/register/user/verify-phone', {
        'temp_id': tempId,
        'code': code,
      });
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// STEP 4: set password -> returns token
  Future<bool> setPassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (tempId == null) {
      _setError("temp_id manquant. Fais start() d'abord.");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final data = await _post('/api/register/user/set-password', {
        'temp_id': tempId,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      token = data['token']?.toString();
      if (token == null) throw Exception("token manquant dans la réponse");

      await _storage.write(key: 'token', value: token);

      // close temp flow locally
      tempId = null;

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================= Utils =================
  String get otpValue => ''; // (optionnel) si tu veux stocker OTP dans VM

  Future<void> logout() async {
    token = null;
    tempId = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}
