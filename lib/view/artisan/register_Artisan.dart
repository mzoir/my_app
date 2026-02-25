import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/utils/responsive.dart';
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
      birthCtrl.text = "$yyyy-$mm-$dd";
    });
  }

  InputDecoration _figmaDec(String hint, IconData icon) {
    const borderColor = Color(0xFFFC5A15);
    const fill = Color(0xFFFFF1EB);

    OutlineInputBorder border(double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.s(30)),
          borderSide: BorderSide(color: borderColor, width: w),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: Responsive.s(12),
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9E9E9E),
      ),
      prefixIcon: Icon(icon, size: Responsive.s(18), color: borderColor),
      filled: true,
      fillColor: fill,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.s(16),
        vertical: Responsive.s(12),
      ),
      enabledBorder: border(1),
      focusedBorder: border(2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Responsive.init(BoxConstraints(
      maxWidth: screenWidth,
      maxHeight: screenHeight,
    ));
    double R(double v) => Responsive.s(v);

    final fieldW = screenWidth * 0.85;
    final btnW = screenWidth * 0.7;

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              child: Column(
                children: [
                  Spacer(flex: 2),

                  // Logo
                  SvgPicture.asset(
                    'images/Exclude.svg',
                    width: R(220),
                    height: R(51.3),
                    fit: BoxFit.contain,
                  ),

                  Spacer(flex: 1),

                  // Title
                  Text(
                    "Créer votre compte",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: R(24),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),

                  Spacer(flex: 1),

                  // Progress bar
                  SizedBox(
                    width: screenWidth * 0.6,
                    height: R(7),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: R(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(R(100)),
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.25,
                          height: R(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(R(100)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: R(12)),

                  // Subtitle
                  Text(
                    "Informations personnelles",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: R(15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Spacer(flex: 1),

                  // Form fields
                  _field(nameCtrl, "Nom complet", Icons.person_outline, fieldW, R),
                  SizedBox(height: R(16)),
                  _birthField(R, fieldW),
                  SizedBox(height: R(16)),
                  _field(emailCtrl, "Adresse email", Icons.email_outlined, fieldW, R),
                  SizedBox(height: R(16)),
                  _field(phoneCtrl, "Téléphone", Icons.phone_outlined, fieldW, R),

                  Spacer(flex: 2),

                  // Button
                  SizedBox(
                    width: btnW,
                    height: R(44),
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
                          borderRadius: BorderRadius.circular(R(28)),
                        ),
                      ),
                      child: Text(
                        "Suivant",
                        style: GoogleFonts.publicSans(
                          fontSize: R(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),

                  Spacer(flex: 1),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "j’ai un compte ? ",
                        style: GoogleFonts.poppins(
                          fontSize: R(12),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          "Connexion",
                          style: GoogleFonts.poppins(
                            fontSize: R(12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(flex: 1),

                  // Home indicator
                  SvgPicture.asset(
                    'images/HomeIndicator.svg',
                    width: R(134),
                    height: R(5),
                    fit: BoxFit.contain,
                  ),

                  Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      double width, double Function(double) R) {
    return SizedBox(
      width: width,
      height: R(48),
      child: TextField(
        controller: c,
        decoration: _figmaDec(hint, icon),
        style: GoogleFonts.poppins(fontSize: R(14), fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _birthField(double Function(double) R, double width) {
    return SizedBox(
      width: width,
      height: R(48),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickBirthDate,
          borderRadius: BorderRadius.circular(R(30)),
          child: AbsorbPointer(
            child: TextField(
              controller: birthCtrl,
              style: GoogleFonts.poppins(fontSize: R(14), fontWeight: FontWeight.w400),
              decoration: _figmaDec("Date de naissance", Icons.calendar_today_outlined).copyWith(
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: R(10)),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFFC5A15),
                    size: R(22),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(minWidth: R(40), minHeight: R(40)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
