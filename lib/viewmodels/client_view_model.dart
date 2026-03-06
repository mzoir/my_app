import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/service_request.dart';
import 'package:my_app/models/User.dart';
import 'package:my_app/models/artisan_model.dart';

class ClientViewModel extends ChangeNotifier {
  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';

  List<ServiceRequest> requests = [];
  final _storage = const FlutterSecureStorage();
  bool loadingArtisans = false;
  bool loading = false;
  String? error;
  List<ArtisanModel> artisans = [];
  User? user;
  String? tempId;
  String? token;

  // ==========================================
  // 💬 MESSAGE STATE
  // ==========================================
  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> messages = [];
  int unreadCount = 0;
  bool loadingMessages = false;

Future<String?> login(String email, String password) async {
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

    if (res.statusCode == 200 || res.statusCode == 201) {
      token = data['token']?.toString();
      if (token == null) {
        error = 'Token not found in response';
        return null;
      }
      await _storage.write(key: 'token', value: token);
      await loadUser();

      // ✅ return the role so LoginPage can redirect
      return user?.role;
    } else {
      error = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Login failed (${res.statusCode})';
      return null;
    }
  } catch (e) {
    error = 'Network error: $e';
    return null;
  } finally {
    loading = false;
    notifyListeners();
  }
}
  // ================= Helpers =================
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
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
    final Map<String, dynamic> data = decoded is Map<String, dynamic>
        ? decoded
        : {};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final msg =
        data['message']?.toString() ??
        (data['errors'] is Map
            ? (data['errors'] as Map).values.first.toString()
            : null) ??
        'Request failed (${res.statusCode})';

    throw Exception(msg);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final t = token ?? await _storage.read(key: 'token');
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $t'},
    );

    final dynamic decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    final Map<String, dynamic> data = decoded is Map<String, dynamic>
        ? decoded
        : {};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final msg =
        data['message']?.toString() ?? 'Request failed (${res.statusCode})';
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

  Future<bool> start({
    required String name,
    required String email,
    required String phone,
    String? ville,
    String? dateOfBirth,
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
      tempId = null;
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String get otpValue => '';

  Future<void> logout() async {
    token = null;
    tempId = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<bool> resendEmailOtp() async {
    if (tempId == null) {
      _setError("temp_id manquant. Fais start() d'abord.");
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      await _post('/api/register/user/resend-email', {'temp_id': tempId});
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendPhoneOtp() async {
    if (tempId == null) {
      _setError("temp_id manquant. Fais start() d'abord.");
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      await _post('/api/register/user/resend-phone', {'temp_id': tempId});
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
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
        await fetchRequests();
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
        await fetchRequests();
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
        await fetchRequests();
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

  // ==========================================
  // 💬 FetchArtisans
  // ==========================================

  Future<bool> fetchArtisans() async {
    loadingArtisans = true;
    notifyListeners();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/artisans'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] ?? data) as List;
        artisans = list
            .map((a) => ArtisanModel.fromJson(a as Map<String, dynamic>))
            .toList();
        print(artisans);
        return true;
      } else {
        error = 'Failed to fetch artisans (${res.statusCode})';
        return false;
      }
    } catch (e) {
      error = 'Network error: $e';
      return false;
    } finally {
      loadingArtisans = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 💬 MESSAGE METHODS
  // ==========================================

  /// Send a message to a user/artisan
  Future<bool> sendMessage({
    required int receiverId,
    required String message,
  }) async {
    loadingMessages = true;
    error = null;
    notifyListeners();
    try {
      final t = token ?? await _storage.read(key: 'token');
      final res = await http.post(
        Uri.parse('$baseUrl/api/messages/send'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $t',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'receiver_id': receiverId, 'message': message}),
      );
      if (res.statusCode == 201) {
        await getConversation(receiverId); // refresh conversation
        return true;
      } else {
        final data = jsonDecode(res.body);
        error = data['message']?.toString() ?? 'Failed to send message';
        return false;
      }
    } catch (e) {
      error = 'Network error: $e';
      return false;
    } finally {
      loadingMessages = false;
      notifyListeners();
    }
  }

  /// Get conversation with a specific user
  Future<bool> getConversation(int userId) async {
    loadingMessages = true;
    error = null;
    notifyListeners();
    try {
      final data = await _get('/api/messages/conversation/$userId');
      messages = List<Map<String, dynamic>>.from(data['data'] ?? []);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loadingMessages = false;
      notifyListeners();
    }
  }

  /// Get all conversations (inbox)
  Future<bool> fetchConversations() async {
    loadingMessages = true;
    error = null;
    notifyListeners();
    try {
      final data = await _get('/api/messages/conversations');
      conversations = List<Map<String, dynamic>>.from(data['data'] ?? []);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loadingMessages = false;
      notifyListeners();
    }
  }

  /// Get all received messages
  Future<bool> fetchReceivedMessages() async {
    loadingMessages = true;
    error = null;
    notifyListeners();
    try {
      final data = await _get('/api/messages/received');
      messages = List<Map<String, dynamic>>.from(data['data'] ?? []);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loadingMessages = false;
      notifyListeners();
    }
  }

  /// Get all sent messages
  Future<bool> fetchSentMessages() async {
    loadingMessages = true;
    error = null;
    notifyListeners();
    try {
      final data = await _get('/api/messages/sent');
      messages = List<Map<String, dynamic>>.from(data['data'] ?? []);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loadingMessages = false;
      notifyListeners();
    }
  }

  /// Mark a message as read
  Future<bool> markMessageAsRead(int messageId) async {
    try {
      final t = token ?? await _storage.read(key: 'token');
      final res = await http.put(
        Uri.parse('$baseUrl/api/messages/$messageId/read'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $t'},
      );
      if (res.statusCode == 200) {
        await fetchUnreadCount(); // refresh count
        return true;
      }
      return false;
    } catch (e) {
      error = 'Network error: $e';
      return false;
    }
  }

  /// Get unread messages count
  Future<bool> fetchUnreadCount() async {
    try {
      final data = await _get('/api/messages/unread-count');
      unreadCount = data['unread_count'] ?? 0;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }
///  ======================================|||
/// update profile                          =====
/// ===========================================|||
Future<bool> updateUser({
  String? name,
  String? email,
  String? phone,
  String? ville,
  String? dateOfBirth,
}) async {

  final url = Uri.parse("$baseUrl/api/user/update");

  Map<String, dynamic> body = {};

  if (name != null) body['name'] = name;
  if (email != null) body['email'] = email;
  if (phone != null) body['phone'] = phone;
  if (ville != null) body['ville'] = ville;
  if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;

  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );
print('Status code: ${response.statusCode}');
print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
    return true;
  } else {
    print(response.body);
    return false;
  }
}

}
