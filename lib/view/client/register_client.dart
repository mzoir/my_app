import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'package:my_app/utils/responsive.dart';
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
      prefixIcon: Icon(icon, size: Responsive.s(18), color: borderColor),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.s(16),
        vertical: Responsive.s(12),
      ),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? "Erreur")),
      );
      return;
    }

    if (!mounted) return;
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
            stops: [0.3146, 1.0],
            colors: [
              Color.fromRGBO(255, 140, 91, 0.0),
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

                  // Fields
                  _buildField(nameCtrl, "Nom complet", Icons.person_outline, fieldW, R),
                  SizedBox(height: R(16)),
                  _buildField(emailCtrl, "Adresse email", Icons.email_outlined, fieldW, R),
                  SizedBox(height: R(16)),
                  _buildField(phoneCtrl, "Téléphone", Icons.phone_outlined, fieldW, R),
                  SizedBox(height: R(16)),
                  _birthField(R, fieldW),
                  SizedBox(height: R(16)),
                  _buildField(cityCtrl, "Ville", Icons.location_on_outlined, fieldW, R),

                  Spacer(flex: 2),

                  // Button
                  SizedBox(
                    width: btnW,
                    height: R(44),
                    child: ElevatedButton(
                      onPressed: vm.loading ? null : _onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R(28)),
                        ),
                      ),
                      child: vm.loading
                          ? SizedBox(
                              width: R(18),
                              height: R(18),
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              "Suivant",
                              style: GoogleFonts.publicSans(
                                fontSize: R(15),
                                fontWeight: FontWeight.bold,
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
                        style: GoogleFonts.publicSans(
                          fontSize: R(14),
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          "Connexion",
                          style: GoogleFonts.publicSans(
                            fontSize: R(14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(flex: 1),

                  // Home Indicator
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

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon,
      double width, double Function(double) R) {
    return SizedBox(
      width: width,
      height: R(48),
      child: TextField(
        controller: ctrl,
        decoration: _figmaDec(hint, icon),
        style: GoogleFonts.poppins(
          fontSize: R(14),
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
        ),
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
