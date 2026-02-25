import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleLoginDemo extends StatefulWidget {
  @override
  _GoogleLoginDemoState createState() => _GoogleLoginDemoState();
}

class _GoogleLoginDemoState extends State<GoogleLoginDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;


  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.authenticate();
      if (account == null) return; // user canceled

      final GoogleSignInAuthentication auth = await account.authentication;

      // Send token to Laravel backend
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": auth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Laravel Token: ${data['token']}");
        print("User: ${data['user']}");
      } else {
        print("Error: ${response.body}");
      }
    } catch (error) {
      print("Google Sign-In failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Login with Google"),
          onPressed: _handleSignIn,
        ),
      ),
    );
  }
}
