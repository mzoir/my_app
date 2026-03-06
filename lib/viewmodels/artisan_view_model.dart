import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/models/artisan_model.dart';

import 'package:my_app/models/service_request.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'dart:async';

class ArtisanViewModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool loadingArtisans = false;
  bool loading = false;
  String? error;
  List<ArtisanModel> artisans = [];
  int? artisanId; // ← add this
  String? tempId;
  String? token;
  ArtisanModel? user;

  // ==========================================
  // 💬 MESSAGE STATE
  // ==========================================
  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> messages = [];
  int unreadCount = 0;
  bool loadingMessages = false;
  // ================= BASE URL =================
  String get baseUrl {
    const port = "8000";
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:$port/api";
    }
    return "http://127.0.0.1:$port/api";
  }

  // ================= STATE =================

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    error = e;
    notifyListeners();
  }

  // ================= HELPERS =================
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    throw Exception(data["message"] ?? "Request failed");
  }

  // =====================================================
  // STEP 1 — START
  // =====================================================
  Future<bool> start({
    required String name,
    required String email,
    required String phone,
    String? birth,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final data = await _post("/register/artisan/start", {
        "nom_complet": name,
        "email": email,
        "phone": phone,
        "date_of_birth": birth,
      });

      tempId = data["temp_id"]?.toString();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // STEP 2 — VERIFY EMAIL
  // =====================================================
  Future<bool> verifyEmail(String code) async {
    print("🔥 VERIFY EMAIL CALLED");
    print("🔥 tempId = $tempId");
    print("🔥 code from model = $code");
    if (tempId == null) {
      _setError("temp_id manquant");
      return false;
    }

    _setLoading(true);
    _setError(null);
    debugPrint("VERIFY EMAIL tempId = $tempId | code = $code");
    try {
      await _post("/register/artisan/verify-email", {
        "temp_id": tempId,
        "code": code,
      });

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // STEP 3 — VERIFY PHONE
  // =====================================================
  Future<bool> verifyPhone(String code) async {
    if (tempId == null) {
      _setError("temp_id manquant");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _post("/register/artisan/verify-phone", {
        "temp_id": tempId,
        "code": code,
      });

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RESEND EMAIL OTP
  // =====================================================
  Future<bool> resendEmailOtp() async {
    if (tempId == null) return false;

    _setLoading(true);

    try {
      await _post("/register/user/resend-email", {"temp_id": tempId});
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RESEND PHONE OTP
  // =====================================================
  Future<bool> resendPhoneOtp() async {
    if (tempId == null) return false;

    _setLoading(true);

    try {
      await _post("/register/user/resend-phone", {"temp_id": tempId});
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // STEP 4 — COMPLETE PROFILE (MULTIPART)
  // =====================================================

  Future<bool> completeProfile({
    required String ville,
    required String adresse,
    required String diplome,
    required String description,
    String? newService,
    int? servicePrincipalId,
    List<int>? serviceIds,

    // ✅ mobile files
    File? diplomeFile,
    List<File>? images,

    // ✅ web files
    html.File? diplomeFileWeb,
    List<html.File>? imagesWeb,
  }) async {
    if (tempId == null) {
      _setError("temp_id manquant");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final req = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/register/artisan/complete-profile"),
      );

      req.headers["Accept"] = "application/json";

      req.fields["temp_id"] = tempId!;
      if (ville.trim().isNotEmpty) req.fields["ville"] = ville.trim();
      if (adresse.trim().isNotEmpty) req.fields["adresse"] = adresse.trim();
      if (diplome.trim().isNotEmpty) req.fields["diplome"] = diplome.trim();
      if (description.trim().isNotEmpty) {
        req.fields["description"] = description.trim();
      }

      if (newService != null && newService.trim().isNotEmpty) {
        req.fields["new_service_name"] = newService.trim();
      }
      if (servicePrincipalId != null) {
        req.fields["service_principal_id"] = servicePrincipalId.toString();
      }
      if (serviceIds != null && serviceIds.isNotEmpty) {
        req.fields["service_ids"] = jsonEncode(serviceIds);
      }

      // =======================
      // ✅ FILES (WEB)
      // =======================
      if (kIsWeb) {
        // diplome
        if (diplomeFileWeb != null) {
          final bytes = await _readHtmlFileBytes(diplomeFileWeb);
          req.files.add(
            http.MultipartFile.fromBytes(
              "diplome_file",
              bytes,
              filename: diplomeFileWeb.name,
            ),
          );
        }

        // images
        if (imagesWeb != null && imagesWeb.isNotEmpty) {
          for (final f in imagesWeb) {
            final bytes = await _readHtmlFileBytes(f);
            req.files.add(
              http.MultipartFile.fromBytes("images[]", bytes, filename: f.name),
            );
          }
        }
      }
      // =======================
      // ✅ FILES (MOBILE / DESKTOP)
      // =======================
      else {
        if (diplomeFile != null) {
          req.files.add(
            await http.MultipartFile.fromPath("diplome_file", diplomeFile.path),
          );
        }

        if (images != null && images.isNotEmpty) {
          for (final img in images) {
            req.files.add(
              await http.MultipartFile.fromPath("images[]", img.path),
            );
          }
        }
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200) {
        final msg = _extractMessage(res.body);
        throw Exception(msg);
      }

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);

      // Laravel: { message: "..." }
      if (decoded is Map && decoded["message"] != null) {
        return decoded["message"].toString();
      }

      // Laravel validation: { errors: { field: ["msg"] } }
      if (decoded is Map && decoded["errors"] is Map) {
        final errors = decoded["errors"] as Map;
        final firstKey = errors.keys.first;
        final value = errors[firstKey];

        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }

      return body;
    } catch (_) {
      return body;
    }
  }

  Future<Uint8List> _readHtmlFileBytes(html.File file) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onError.listen((_) {
      completer.completeError("FileReader error");
    });

    reader.onLoadEnd.listen((_) {
      final result = reader.result;

      if (result is ByteBuffer) {
        completer.complete(result.asUint8List());
        return;
      }

      if (result is Uint8List) {
        completer.complete(result);
        return;
      }

      // Sometimes it's a List<int> in some contexts
      if (result is List<int>) {
        completer.complete(Uint8List.fromList(result));
        return;
      }

      completer.completeError(
        "Unable to read file bytes (type: ${result.runtimeType})",
      );
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  // =====================================================
  // STEP 5 — SET PASSWORD
  // =====================================================
  Future<bool> setPassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (tempId == null) {
      _setError("temp_id manquant");
      return false;
    }

    _setLoading(true);

    try {
      final data = await _post("/register/artisan/set-password", {
        "temp_id": tempId,
        "password": password,
        "password_confirmation": confirmPassword,
      });

      token = data["token"]?.toString();
      tempId = null;

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    token = null;
    tempId = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  /// Send a message to a user/artisan  ////
  /// ====================================
  ///               Message             ||||
  /// ==================================== ////
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
        Uri.parse('$baseUrl/artisan/messages/send'),
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
      final data = await _get('/artisan/messages/conversation/$userId');
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
      final data = await _get('/artisan/messages/conversations');
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
      final data = await _get('/artisan/messages/received');
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
      final data = await _get('/artisan/messages/sent');
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
        Uri.parse('$baseUrl/artisan/messages/$messageId/read'),
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
      final data = await _get('/artisan/messages/unread-count');
      unreadCount = data['unread_count'] ?? 0;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
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
  ////////////===============================
  ///////Load profile                    //////
  ///======================================
  Future<void> loadProfile() async {
  try {
    final data = await _get('/artisan/me');
    user = ArtisanModel.fromJson(data['data'] ?? data);
    artisanId = user?.id;
    notifyListeners();
  } catch (e) {
    error = e.toString();
  }
}

////========================= ----------
/// Fetch All client requests //////    |
/// ========================== ---------
// Add these at the top of ArtisanViewModel
List<ServiceRequest> allRequests = [];
bool loadingRequests = false;

Future<void> fetchAllRequests() async {
  loadingRequests = true;
  error = null;
  notifyListeners();
  try {
    final t = token ?? await _storage.read(key: 'token');
    final res = await http.get(
      Uri.parse('$baseUrl/requests/all'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $t'},
    );
    final data = jsonDecode(res.body);
    final list = (data['data'] ?? data) as List;
    allRequests = list.map((e) => ServiceRequest.fromJson(e)).toList();
  } catch (e) {
    error = e.toString();
  } finally {
    loadingRequests = false;
    notifyListeners();
  }
}

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

///////====================================================////////////
/////           Fetch profile artisan 
////====================================/////////////////////
////



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







}
