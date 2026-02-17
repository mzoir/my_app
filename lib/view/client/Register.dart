// ========================= register_page.dart =========================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'complete.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final birthCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    birthCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  InputDecoration _figmaDec(String hint, IconData icon) {
    const borderColor = Color(0xFFFC5A15);

    OutlineInputBorder border(double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textLight),
      prefixIcon: Icon(icon, size: 18, color: borderColor),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      enabledBorder: border(1),
      focusedBorder: border(2),
    );
  }

  Future<void> _onStart() async {
    final vm = context.read<ClientViewModel>();

    final ok = await vm.start(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      ville: cityCtrl.text.trim(),
      dateOfBirth: birthCtrl.text.trim(),
    );

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? "Erreur")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AuthFlowPage(
          tempId: vm.tempId ?? "",
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientViewModel>();

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
              child: SizedBox(
                width: 393,
                height: 852,
                child: Stack(
                  children: [
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
                    Positioned(
                      top: 203,
                      left: 82,
                      child: SizedBox(
                        width: 229,
                        height: 32,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Créer votre compte",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              height: 38 / 24,
                              letterSpacing: -0.45,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 273,
                      left: 40,
                      child: SizedBox(
                        width: 314,
                        height: 48,
                        child: TextField(
                          controller: nameCtrl,
                          decoration: _figmaDec("Nom complet", Icons.person_outline),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 343,
                      left: 40,
                      child: SizedBox(
                        width: 314,
                        height: 48,
                        child: TextField(
                          controller: emailCtrl,
                          decoration: _figmaDec("Adresse email", Icons.email_outlined),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 413,
                      left: 40,
                      child: SizedBox(
                        width: 314,
                        height: 48,
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: _figmaDec("Téléphone", Icons.phone_outlined),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 483,
                      left: 40,
                      child: SizedBox(
                        width: 314,
                        height: 48,
                        child: TextField(
                          controller: birthCtrl,
                          decoration: _figmaDec("Date de naissance", Icons.calendar_today_outlined),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 553,
                      left: 40,
                      child: SizedBox(
                        width: 314,
                        height: 48,
                        child: TextField(
                          controller: cityCtrl,
                          decoration: _figmaDec("ville", Icons.location_on_outlined),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textDark),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 689,
                      left: 71,
                      child: SizedBox(
                        width: 251,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: vm.loading ? null : _onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            "Suivant",
                            style: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 797,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "j’ai un compte ? ",
                            style: GoogleFonts.publicSans(
                              fontSize: 14,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: Text(
                              "Connexion",
                              style: GoogleFonts.publicSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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
                          onTap: () => debugPrint("InkWell tapped!"),
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
