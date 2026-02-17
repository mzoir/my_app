import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'complete.dart';

class ArtisanRegister extends StatefulWidget {
  const ArtisanRegister({super.key});

  @override
  State<ArtisanRegister> createState() => _ArtisanRegisterState();
}

class _ArtisanRegisterState extends State<ArtisanRegister> {
  final nameCtrl = TextEditingController();

  final birthCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    birthCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

Future<void> _pickBirthDate() async {
  final now = DateTime.now();

  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime(now.year - 18, now.month, now.day),
    firstDate: DateTime(1900, 1, 1),
    lastDate: now,
  );

  if (picked == null) return;

  final yyyy = picked.year.toString().padLeft(4, '0');
  final mm = picked.month.toString().padLeft(2, '0');
  final dd = picked.day.toString().padLeft(2, '0');

  setState(() {
    birthCtrl.text = "$yyyy-$mm-$dd"; // ✅ format attendu par Laravel
  });
}


  InputDecoration _figmaDec(String hint, IconData icon) {
    const borderColor = Color(0xFFFC5A15);
    const fill = Color(0xFFFFF1EB);

    OutlineInputBorder border(double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: w),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9E9E9E),
      ),
      prefixIcon: Icon(icon, size: 18, color: borderColor),
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      enabledBorder: border(1),
      focusedBorder: border(2),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  stops: [0.3146, 1],
                  colors: [
                    Color.fromRGBO(255, 140, 91, 0),
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
                      child: SvgPicture.asset(
                        'images/Exclude.svg',
                        width: 220,
                        height: 51.29,
                      ),
                    ),
                    Positioned(
                      top: 203,
                      left: 82,
                      child: SizedBox(
                        width: 229,
                        child: Text(
                          "Créer votre compte",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.45,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 249,
                      left: 94,
                      child: SizedBox(
                        width: 240,
                        height: 7,
                        child: Stack(
                          children: [
                            Container(
                              width: 204,
                              height: 7,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 268,
                      left: 94,
                      child: SizedBox(
                        width: 204,
                        child: Text(
                          "Informations personnelles",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 323,
                      left: 40,
                      child: SizedBox(
                        width: 314,
                        height: 258,
                        child: Column(
                          children: [
                            _field(nameCtrl, "Nom complet", Icons.person_outline),
                            const SizedBox(height: 22),
                            _birthField(),
                            const SizedBox(height: 22),
                            _field(emailCtrl, "Adresse email", Icons.email_outlined),
                            const SizedBox(height: 22),
                            _field(phoneCtrl, "Téléphone", Icons.phone_outlined),
                          ],
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
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty ||
                                birthCtrl.text.trim().isEmpty ||
                                emailCtrl.text.trim().isEmpty ||
                                phoneCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Veuillez remplir tous les champs.")),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AuthFlowPage(
                                  nom: nameCtrl.text.trim(),
                                  birth: birthCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            "Suivant",
                            style: GoogleFonts.publicSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
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
                          const Text("j’ai un compte ? "),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: Text(
                              "Connexion",
                              style: TextStyle(
                                color: AppColors.accent,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 837,
                      left: 129,
                      child: SvgPicture.asset(
                        'images/HomeIndicator.svg',
                        width: 134,
                        height: 5,
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

  Widget _field(TextEditingController c, String hint, IconData icon) {
    return SizedBox(
      width: 314,
      height: 48,
      child: TextField(
        controller: c,
        decoration: _figmaDec(hint, icon),
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }



}
