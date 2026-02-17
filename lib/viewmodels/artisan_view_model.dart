import 'dart:convert';
import 'dart:io' show File; // OK: only used when not web (don’t call it on web)
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class ArtisanViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  String? tempId; // key for registration flow
  String? token; // final sanctum token after set-password

  // ===== Base URL (Web-safe) =====
  String _baseUrl() {
    const port = "8000";
    if (kIsWeb) return "http://127.0.0.1:$port/api";
    // Android emulator
    // ignore: avoid_slow_async_io
    return "http://10.0.2.2:$port/api";
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  String _extractError(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map && j["message"] is String) return j["message"];
      if (j is Map && j["errors"] is Map) {
        final errors = j["errors"] as Map;
        final firstKey = errors.keys.first;
        final firstVal = errors[firstKey];
        if (firstVal is List && firstVal.isNotEmpty) {
          return firstVal.first.toString();
        }
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // =========================
  // STEP 1: START
  // POST /register/artisan/start
  // =========================
  Future<bool> startRegister({
    required String nom,
    required String email,
    required String phone,
    String? birth, // YYYY-MM-DD
  }) async {
    _setLoading(true);
    errorMessage = null;

    try {
      final res = await http.post(
        Uri.parse("${_baseUrl()}/register/artisan/start"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nom_complet": nom,
          "email": email,
          "phone": phone,
          if (birth != null && birth.trim().isNotEmpty)
            "date_naissance": birth.trim(),
        }),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        tempId = data["temp_id"]?.toString();
        _setLoading(false);
        return true;
      }

      errorMessage = _extractError(res.body);
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return false;
  }

  // =========================
  // STEP 2: VERIFY EMAIL
  // POST /register/artisan/verify-email
  // =========================
  Future<bool> verifyEmailOtp(String code) async {
    _setLoading(true);
    errorMessage = null;

    try {
      if (tempId == null) {
        errorMessage = "temp_id manquant. Lance d’abord startRegister.";
        _setLoading(false);
        return false;
      }

      final res = await http.post(
        Uri.parse("${_baseUrl()}/register/artisan/verify-email"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"temp_id": tempId, "code": code}),
      );

      if (res.statusCode == 200) {
        _setLoading(false);
        return true;
      }

      errorMessage = _extractError(res.body);
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return false;
  }

  // =========================
  // STEP 3: VERIFY PHONE
  // POST /register/artisan/verify-phone
  // =========================
  Future<bool> verifyPhoneOtp(String code) async {
    _setLoading(true);
    errorMessage = null;

    try {
      if (tempId == null) {
        errorMessage = "temp_id manquant. Lance d’abord startRegister.";
        _setLoading(false);
        return false;
      }

      final res = await http.post(
        Uri.parse("${_baseUrl()}/register/artisan/verify-phone"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"temp_id": tempId, "code": code}),
      );

      if (res.statusCode == 200) {
        _setLoading(false);
        return true;
      }

      errorMessage = _extractError(res.body);
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return false;
  }

  // =========================
  // STEP 4: COMPLETE PROFILE
  // POST /register/artisan/complete-profile  (multipart)
  // =========================
  Future<bool> completeProfileWeb({
    String? ville,
    String? adresse,
    String? diplome,
    String? description,
    List<html.File>? images,
    html.File? diplomeFile,
    List<int>? serviceIds,
    int? servicePrincipalId,
    String? newServiceName,
  }) async {
    try {
      if (tempId == null) {
        errorMessage = "temp_id manquant. Lance d’abord startRegister.";
        return false;
      }
      final formData = html.FormData();
      formData.append("temp_id", tempId!);
      if (ville != null) formData.append("ville", ville);
      if (adresse != null) formData.append("adresse", adresse);
      if (diplome != null) formData.append("diplome", diplome);
      if (description != null) formData.append("description", description);
      if (newServiceName != null) {
        formData.append("new_service_name", newServiceName);
      }
      if (servicePrincipalId != null) {
        formData.append("service_principal_id", servicePrincipalId.toString());
      }
      if (serviceIds != null && serviceIds.isNotEmpty) {
        formData.append("service_ids", serviceIds.toString());
      }
      if (diplomeFile != null) {
        formData.appendBlob("diplome_file", diplomeFile);
      }
      if (images != null && images.isNotEmpty) {
        for (final img in images) {
          formData.appendBlob("images", img);
        }
      }
      final response = await html.HttpRequest.request(
        "${_baseUrl()}/register/artisan/complete-profile",
        method: "POST",
        sendData: formData,
      );
      if (response.status == 200) {
        return true;
      } else {
        errorMessage = response.responseText;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // STEP 5: SET PASSWORD (final)
  // POST /register/artisan/set-password
  // =========================
  Future<bool> setPassword(String password) async {
    _setLoading(true);
    errorMessage = null;

    try {
      if (tempId == null) {
        errorMessage = "temp_id manquant. Lance d’abord startRegister.";
        _setLoading(false);
        return false;
      }

      final res = await http.post(
        Uri.parse("${_baseUrl()}/register/artisan/set-password"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "temp_id": tempId,
          "password": password,
          "password_confirmation": password,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        token = data["token"]?.toString();
        // after success, tempId becomes useless (backend deletes register_token anyway)
        tempId = null;
        _setLoading(false);
        return true;
      }

      errorMessage = _extractError(res.body);
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return false;
  }
}
