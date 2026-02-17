import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/view/core/app_colors.dart';

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
      Navigator.pushNamed(context, '/client/register'); // ✅ route 1
    } else {
      Navigator.pushNamed(context, '/artisan/register'); // ✅ route 2
    }
  }

  Widget _profileCard({
    required double top,
    required String title,
    required String subtitle,
    required IconData icon,
    required UserProfileType value,
  }) {
    final isSelected = selected == value;

    return Positioned(
      top: top,
      left: 26,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => selected = value),
        child: Container(
          width: 341,
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFFFC5A15) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // left icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC5A15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),

              // texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800Color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // right radio (circle)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFC5A15) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGo = selected != null;

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
                  stops: [0.35, 1.0],
                  colors: [
                    Color.fromRGBO(255, 140, 91, 0.0),
                    Color.fromRGBO(255, 140, 91, 0.22),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SizedBox(
              width: 393,
              height: 852,
              child: Stack(
                children: [
                  // logo (keep your svg)
                  Positioned(
                    top: 80,
                    left: 86,
                    child: SvgPicture.asset(
                      'images/Exclude.svg',
                      width: 220,
                      height: 51.3,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Positioned(
                    top: 165,
                    left: 0,
                    right: 0,
                    child: Text(
                      "Choisissez votre profil",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800Color,
                      ),
                    ),
                  ),

                  // cards
                  _profileCard(
                    top: 240,
                    title: "Je suis un Client",
                    subtitle:
                        "Trouvez des artisans qualifiés pour tous vos projets de rénovation et d'entretien",
                    icon: Icons.group_outlined,
                    value: UserProfileType.client,
                  ),

                  _profileCard(
                    top: 340,
                    title: "Je suis un Artisan",
                    subtitle:
                        "Développez votre activité et trouvez de nouveaux clients en rejoignant notre plateforme",
                    icon: Icons.handyman_outlined,
                    value: UserProfileType.artisan,
                  ),

                  // button
                  Positioned(
                    top: 560,
                    left: 46,
                    child: SizedBox(
                      width: 301,
                      height: 52,
                      child: Material(
                        color: canGo
                            ? const Color(0xFFFC5A15)
                            : const Color(0xFFFC5A15).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: canGo ? _goNext : null,
                          child: Center(
                            child: Text(
                              "Suivant",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // footer
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "j'ai un compte ?  ",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            "Connexion",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color: const Color(0xFFFC5A15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
