import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  String _baseUrl() {
    const port = "8000";

    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port/api";
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return "http://127.0.0.1:$port/api";
    }
    return "http://192.168.1.10:$port/api"; // phone real (change)
  }

  Future<Map<String, dynamic>> registerArtisan({
    required Map<String, String> fields,
  }) async {
    final url = Uri.parse("${_baseUrl()}/register/artisan");
    final res = await http.post(url, headers: {"Accept": "application/json"}, body: fields);

    final body = jsonDecode(res.body);
    if (res.statusCode == 201) return body;

    throw Exception(body is Map ? body["message"] ?? res.body : res.body);
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse("${_baseUrl()}/email/verify-otp");
    final res = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"email": email, "code": code},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body;

    throw Exception(body is Map ? body["message"] ?? res.body : res.body);
  }

  Future<Map<String, dynamic>> resendEmailOtp({required String email}) async {
    final url = Uri.parse("${_baseUrl()}/email/resend-otp");
    final res = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"email": email},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body;

    throw Exception(body is Map ? body["message"] ?? res.body : res.body);
  }

  // Phone OTP endpoints (si tu les as dans Laravel)
  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String token,
    required String code,
  }) async {
    final url = Uri.parse("${_baseUrl()}/artisan/phone/verify-otp");
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {"code": code},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body;

    throw Exception(body is Map ? body["message"] ?? res.body : res.body);
  }

  Future<Map<String, dynamic>> sendPhoneOtp({required String token}) async {
    final url = Uri.parse("${_baseUrl()}/artisan/phone/send-otp");
    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body;

    throw Exception(body is Map ? body["message"] ?? res.body : res.body);
  }
}
