import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/models/service_request.dart';

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
  List<ServiceRequest> requests = [];

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init() async {
    token = await _storage.read(key: 'token');
    if (token != null) {
      await loadUser();
    }
    notifyListeners();
  }

  // ── Auth ─────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/login');

      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
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
        await loadUser();
        return true;
      } else {
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

  Future<bool> register(
    String name,
    String email,
    String password,
    String phone,
    String dateOfBirth,
    String Ville,
  ) async {
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
    requests = [];
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  // ── User ─────────────────────────────────────────────────────────

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
      error = 'Failed to parse user data: $e';
      print(error);
      return false;
    }
  }

  Future<Map<String, dynamic>?> me() async {
    final t = token ?? await _storage.read(key: 'token');
    if (t == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $t'},
      );

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(res.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Requests ─────────────────────────────────────────────────────

  /// GET /api/requests — fetch the authenticated user's requests
  Future<bool> fetchRequests() async {
    try {
      final uri = Uri.parse('$baseUrl/api/requests');
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        requests = (data['data'] as List)
            .map((r) => ServiceRequest.fromJson(r as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return true;
      } else {
        error = 'Failed to fetch requests (${res.statusCode})';
        return false;
      }
    } catch (e) {
      error = 'Network error: $e';
      return false;
    }
  }

  /// POST /api/requests — create a new service request
  Future<bool> createRequest({
    required String serviceName,
    required String serviceType,
    required String description,
    required String ville,
    required String address,
    String? additionalInfo,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/requests');
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_name': serviceName,
          'service_type': serviceType,
          'description': description,
          'ville': ville,
          'address': address,
          'additional_info': ?additionalInfo,
        }),
      );

      if (res.statusCode == 201) {
        await fetchRequests(); // Refresh list
        return true;
      } else {
        final data = jsonDecode(res.body);
        error = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Failed to create request (${res.statusCode})';
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

  /// DELETE /api/requests/{id} — delete a service request
  Future<bool> deleteRequest(int requestId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/requests/$requestId');
      final res = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        await fetchRequests(); // Refresh list
        return true;
      } else {
        final data = jsonDecode(res.body);
        error = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Failed to delete request (${res.statusCode})';
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

  /// PUT /api/requests/{id} — update an existing service request
  Future<bool> updateRequest(
    int requestId, {
    String? serviceName,
    String? serviceType,
    String? description,
    String? ville,
    String? address,
    String? additionalInfo,
    String? status,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/requests/$requestId');
      final res = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_name': ?serviceName,
          'service_type': ?serviceType,
          'description': ?description,
          'ville': ?ville,
          'address': ?address,
          'additional_info': ?additionalInfo,
          'status': ?status,
        }),
      );

      if (res.statusCode == 200) {
        await fetchRequests(); // Refresh list
        return true;
      } else {
        final data = jsonDecode(res.body);
        error = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Failed to update request (${res.statusCode})';
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

  /// GET /api/requests/{id} — fetch a single request by id
  Future<ServiceRequest?> getRequest(int requestId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/requests/$requestId');
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final raw = data['data'] ?? data;
        return ServiceRequest.fromJson(raw as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      error = 'Network error: $e';
      return null;
    }
  }

  void update(String? name,
    String? email,
    String? phone,
    String? dob,
    String? city,
    String? address,
    String? zipCode,
) {
    
    print('');
  }
}
