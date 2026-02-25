import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/utils/responsive.dart';

enum UserProfileType { client, artisan }

class ChooseProfilePage extends StatefulWidget {
  const ChooseProfilePage({super.key});

  @override
  State<ChooseProfilePage> createState() => _ChooseProfilePageState();
}

class _ChooseProfilePageState extends State<ChooseProfilePage> {
  UserProfileType? selected;

  void _goNext() {
    if (selected == null) return;

    if (selected == UserProfileType.client) {
      Navigator.pushNamed(context, '/client/register');
    } else {
      Navigator.pushNamed(context, '/artisan/register');
    }
  }

  Widget _profileCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required UserProfileType value,
    required double Function(double) R,
    required double cardW,
  }) {
    final isSelected = selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(R(16)),
      onTap: () => setState(() => selected = value),
      child: Container(
        width: cardW,
        height: R(86),
        padding: EdgeInsets.symmetric(horizontal: R(14), vertical: R(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: R(18),
              offset: Offset(0, R(8)),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFFFC5A15) : Colors.transparent,
            width: R(1.5),
          ),
        ),
        child: Row(
          children: [
            // left icon box
            Container(
              width: R(44),
              height: R(44),
              decoration: BoxDecoration(
                color: const Color(0xFFFC5A15),
                borderRadius: BorderRadius.circular(R(12)),
              ),
              child: Icon(icon, color: Colors.white, size: R(22)),
            ),
            SizedBox(width: R(12)),

            // texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: R(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800Color,
                    ),
                  ),
                  SizedBox(height: R(4)),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: R(10.5),
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // right radio (circle)
            Container(
              width: R(18),
              height: R(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFC5A15) : Colors.grey.shade300,
                  width: R(2),
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: R(8),
                        height: R(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFC5A15),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
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

    final cardW = screenWidth * 0.9;
    final btnW = screenWidth * 0.8;
    final canGo = selected != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.35, 1.0],
            colors: [
              Color.fromRGBO(255, 140, 91, 0.0),
              Color.fromRGBO(255, 140, 91, 0.22),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight, // fill screen height
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
                    "Choisissez votre profil",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: R(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800Color,
                    ),
                  ),

                  Spacer(flex: 1),

                  // Cards
                  _profileCard(
                    cardW: cardW,
                    title: "Je suis un Client",
                    subtitle: "Trouvez des artisans qualifiés pour tous vos projets de rénovation et d'entretien",
                    icon: Icons.group_outlined,
                    value: UserProfileType.client,
                    R: R,
                  ),
                  SizedBox(height: R(20)),
                  _profileCard(
                    cardW: cardW,
                    title: "Je suis un Artisan",
                    subtitle: "Développez votre activité et trouvez de nouveaux clients en rejoignant notre plateforme",
                    icon: Icons.handyman_outlined,
                    value: UserProfileType.artisan,
                    R: R,
                  ),

                  Spacer(flex: 2),

                  // Button
                  SizedBox(
                    width: btnW,
                    height: R(52),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canGo
                            ? const Color(0xFFFC5A15)
                            : const Color(0xFFFC5A15).withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R(30)),
                        ),
                      ),
                      onPressed: canGo ? _goNext : null,
                      child: Text(
                        "Suivant",
                        style: GoogleFonts.poppins(
                          fontSize: R(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                        "j'ai un compte ?  ",
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
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color: const Color(0xFFFC5A15),
                          ),
                        ),
                      ),
                    ],
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
}
