import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/viewmodels/UserViewModel.dart';
import  'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // ✅ Replace this with your real login method (API / Provider)
  Future<void> login(String email, String password) async {
    // TODO: call your backend/provider here

 final auth = Provider.of<AuthProvider>(context, listen: false);

  final ok = await auth.login(email, password);

  if (!mounted) return;

  if (ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login réussi")),
    );
    Navigator.pushReplacementNamed(context, '/home'); // عدل route إذا لازم
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? "Login failed")),
    );
  }

  }

  InputDecoration _figmaDec(String hint, {Widget? suffixIcon}) {
    const borderColor = Color(0xFFFC5A15);

    OutlineInputBorder border(double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      enabledBorder: border(1),
      focusedBorder: border(2),
      suffixIcon: suffixIcon,
    );
  }

  Widget _pillButton({
    required double top,
    required String text,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
    Widget? leftIcon,
  }) {
    return Positioned(
      top: top,
      left: 30,
      child: SizedBox(
        width: 333,
        height: 54,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: Stack(
              children: [
                if (leftIcon != null)
                  Positioned(
                    left: 18,
                    top: 0,
                    bottom: 0,
                    child: Center(child: leftIcon),
                  ),
                Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: 0,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== Background layer 1 (white) =====
          Positioned.fill(child: Container(color: Colors.white)),

          // ===== Background layer 2 (vertical gradient) =====
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3146, 1.0],
                  colors: [
                    Color.fromRGBO(255, 140, 91, 0.0),
                    Color.fromRGBO(255, 140, 91, 0.30),
                  ],
                ),
              ),
            ),
          ),

          // ===== UI =====
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 393, // Figma frame
                height: 852, // Figma frame
                child: Stack(
                  children: [
                    // ===== LOGO (Figma) =====
                    Positioned(
                      top: 113,
                      left: 86,
                      child: Opacity(
                        opacity: 1,
                        child: Transform.rotate(
                          angle: 0,
                          child: SvgPicture.asset(
                            'images/Exclude.svg',
                            width: 220,
                            height: 51.2939453125,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // ===== TITLE (Figma) =====
                    Positioned(
                      top: 197,
                      left: 46,
                      child: SizedBox(
                        width: 301,
                        height: 32,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Bienvenue à nouveau",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              height: 38 / 24,
                              letterSpacing: -0.45,
                              color: AppColors.grey800Color,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ✅ FORM LOGIN (same style as before)
                    Form(
                      key: _formKey,
                      child: Stack(
                        children: [
                          // EMAIL
                          Positioned(
                            top: 273,
                            left: 40,
                            child: SizedBox(
                              width: 314,
                              height: 48,
                              child: TextFormField(
                                controller: emailCtrl,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? "Email requis"
                                    : null,
                                decoration: _figmaDec("Email"),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),

                          // PASSWORD
                          Positioned(
                            top: 343,
                            left: 40,
                            child: SizedBox(
                              width: 314,
                              height: 48,
                              child: TextFormField(
                                controller: passwordCtrl,
                                obscureText: _obscure,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? "Mot de passe requis"
                                    : null,
                                decoration: _figmaDec(
                                  "Mot de passe",
                                  suffixIcon: IconButton(
                                    splashRadius: 18,
                                    onPressed: () {
                                      setState(() => _obscure = !_obscure);
                                    },
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: const Color(0xFFFC5A15),
                                    ),
                                  ),
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),

                          // LOGIN BUTTON
                          Positioned(
                            top: 455,
                            left: 97,
                            child: SizedBox(
                              width: 199,
                              height: 44,
                              child: Material(
                                color: const Color(0xFFFC5A15),
                                borderRadius: BorderRadius.circular(30),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () async {
                                    if (!(_formKey.currentState?.validate() ?? false)) return;

                                    final email = emailCtrl.text.trim();
                                    final password = passwordCtrl.text;

                                    try {
                                      await login(email, password);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Login réussi")),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Erreur login: $e")),
                                      );
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      "Login",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== SOCIAL / FOOTER FRAME (FIGMA EXACT) =====
                    Positioned(
                      top: 551,
                      left: 6,
                      child: Container(
                        width: 381,
                        height: 301,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // ===== SVG 1 =====
                            Positioned(
                              top: 30,
                              left: 33,
                              child: InkWell(
                                onTap: () {

  Navigator.pushReplacementNamed(context, '/connect'); // 
                                  
                                },
                                child: SvgPicture.asset(
                                  'images/Group75902.svg',
                                  width: 333,
                                  height: 54,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // ===== SVG 2 =====
                            Positioned(
                              top: 104,
                              left: 24,
                              child: InkWell(
                                onTap: () {
                                 
                                },
                                child: Image.asset(
                                  'images/Group75903.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // ===== SVG 3 =====
                            Positioned(
                              top: 174,
                              left: 24,
                              child: InkWell(
                                onTap: () {},
                              
                                 child:SvgPicture.asset(
                                  'images/Group75957.svg',
                                  
                                  fit: BoxFit.contain,
                                ),
                              
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ===== FOOTER =====
                    Positioned(
                      top: 815,
                      left: 0,
                      child: SizedBox(
                        width: 393,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Je nais pas un compte ?  ",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/connect');
                              },
                              child: Text(
                                "S'inscrire",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFC5A15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 837,
                      left: 129,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            print("InkWell tapped!");
                          },
                          child: SvgPicture.asset(
                            'images/HomeIndicator.svg',
                            width: 134,
                            height: 5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
