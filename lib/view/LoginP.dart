import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/utils/responsive.dart';

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

Future<void> login(String email, String password) async {
  final auth = Provider.of<ClientViewModel>(context, listen: false);

  final role = await auth.login(email, password); // ✅ now returns role

  if (!mounted) return;

  if (role != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login réussi")),
    );

    // ✅ redirect based on role
    if (role == 'artisan') {
      Navigator.pushReplacementNamed(context, '/home/artisan');
    } else {
      Navigator.pushReplacementNamed(context, '/home/client');
    }

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? "Login failed")),
    );
  }
  
}

  InputDecoration _figmaDec(String hint, {Widget? suffixIcon}) {
    const borderColor = Color(0xFFFC5A15);

    OutlineInputBorder border(double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.s(30)),
          borderSide: BorderSide(color: borderColor, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: Responsive.s(12),
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        vertical: Responsive.s(12),
        horizontal: Responsive.s(16),
      ),
      enabledBorder: border(1),
      focusedBorder: border(2),
      suffixIcon: suffixIcon,
    );
  }

  Widget _socialButton({
    required double Function(double) R,
    required Widget leftIcon,
    required String text,
    required VoidCallback onTap,
    required Color bg,
    required Color textColor,
    bool shadow = true,
  }) {
    return SizedBox(
      width: double.infinity, // responsive full width
      height: R(54),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(R(30)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: R(18)),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(R(30)),
              boxShadow: shadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: R(18),
                        offset: Offset(0, R(8)),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                SizedBox(width: R(6)),
                SizedBox(width: R(26), height: R(26), child: Center(child: leftIcon)),
                SizedBox(width: R(12)),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    text,
                    style: GoogleFonts.publicSans(
                      fontSize: R(15.2),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(width: R(26)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gmailIcon(double Function(double) R) =>
      Image.asset('images/gmail.png', width: R(22), height: R(22), fit: BoxFit.contain);

  Widget _facebookIcon(double Function(double) R) =>
      Image.asset('images/facebook.png', width: R(22), height: R(22), fit: BoxFit.contain);

  Widget _emailIcon(double Function(double) R) =>
      Image.asset('images/email.png', width: R(22), height: R(22), fit: BoxFit.contain);

  @override
  Widget build(BuildContext context) {
      double R(double v) => Responsive.s(v);

      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.white)),
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
        SafeArea(
  child: SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R(20)),
          child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: R(50)),
                      SvgPicture.asset(
                        'images/Exclude.svg',
                        width: R(220),
                        height: R(51),
                      ),
                      SizedBox(height: R(30)),
                      Text(
                        "Bienvenue à nouveau",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: R(28),
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey800Color,
                        ),
                      ),
                      SizedBox(height: R(40)),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailCtrl,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? "Email requis" : null,
                              decoration: _figmaDec("Email"),
                              style: GoogleFonts.poppins(
                                fontSize: R(14),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: R(20)),
                            TextFormField(
                              controller: passwordCtrl,
                              obscureText: _obscure,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Mot de passe requis" : null,
                              decoration: _figmaDec(
                                "Mot de passe",
                                suffixIcon: IconButton(
                                  splashRadius: R(18),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: R(18),
                                    color: const Color(0xFFFC5A15),
                                  ),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: R(14),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: R(10)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {},
                                child: Text(
                                  "Mot de passe oublié ?",
                                  style: GoogleFonts.poppins(
                                    fontSize: R(11.5),
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: R(30)),
                            SizedBox(
                              width: R(300),
                              height: R(44),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!(_formKey.currentState?.validate() ?? false)) return;
                                  await login(emailCtrl.text.trim(), passwordCtrl.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFC5A15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(R(30)),
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: R(14),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: R(30)),

                      // SOCIAL BUTTONS (responsive full width)
                  
// WHITE CONTAINER wrapping social buttons + sign-up row
Container(
  width: double.infinity,
  padding: EdgeInsets.symmetric(
    horizontal: R(20),
    vertical: R(28),
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(R(30)),
      topRight: Radius.circular(R(30)),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: R(20),
        offset: Offset(0, R(-4)),
      ),
    ],
  ),
  child: 
                      Column(
                        children: [
                          _socialButton(
                            R: R,
                            leftIcon: _emailIcon(R),
                            text: "S'inscrire avec l'application",
                            onTap: () => Navigator.pushReplacementNamed(context, '/connect'),
                            bg: const Color(0xFF2F3338),
                            textColor: Colors.white,
                            shadow: false,
                          ),
                          SizedBox(height: R(20)),
                          _socialButton(
                            R: R,
                            leftIcon: _gmailIcon(R),
                            text: "Se connecter avec Gmail",
                            onTap: () =>
                                Navigator.pushReplacementNamed(context, '/connectgoogle'),
                            bg: Colors.white,
                            textColor: Colors.black,
                            shadow: true,
                          ),
                          SizedBox(height: R(20)),
                          _socialButton(
                            R: R,
                            leftIcon: _facebookIcon(R),
                            text: "Se connecter avec Facebook",
                            onTap: () {},
                            bg: Colors.white,
                            textColor: Colors.black,
                            shadow: true,
                          ),
                     
                      SizedBox(height: R(60)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Je n'ai pas un compte ?  ",
                            style: GoogleFonts.poppins(
                              fontSize: R(12),
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/connect'),
                            child: Text(
                              "S'inscrire",
                              style: GoogleFonts.poppins(
                                fontSize: R(12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFC5A15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: R(20)),
                      SvgPicture.asset(
                        'images/HomeIndicator.svg',
                        width: R(134),
                        height: R(5),
                      ),
           ],
                      ),),
                    ],
                  ),
                ),
              ),
            ),
  ),
        ),
          ],
        ),
        );
      
  }
}