import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';

class SubscriptionPlans extends StatefulWidget {
  const SubscriptionPlans({super.key});

  @override
  State<SubscriptionPlans> createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends State<SubscriptionPlans> {
  late final PageController _pc;

  // toggle state
  bool yearly = true; // Annuel selected by default (like your screenshot)

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _setPlanMode(bool isYearly) {
    setState(() => yearly = isYearly);

    // (Optionnel) tu peux aussi changer les prix ici si tu veux
    // مثال: mensual vs annuel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== Background =====
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

          // ===== FRAME =====
          SafeArea(
            child: SizedBox(
              width: 393,
              height: 852,
              child: Stack(
                children: [
                  // ===== LOGO =====
                  Positioned(
                    top: 79,
                    left: 116.65,
                    child: SvgPicture.asset(
                      'images/Exclude.svg',
                      width: 158.693359375,
                      height: 37,
                    ),
                  ),

                  // ===== TITLE =====
                  Positioned(
                    top: 140,
                    left: 20,
                    child: SizedBox(
                      width: 352,
                      height: 23,
                      child: Text(
                        "Choisissez votre abonnement",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                          letterSpacing: -0.45,
                        ),
                      ),
                    ),
                  ),

                  // ===== TOGGLE (Mensuel / Annuel) =====
                  Positioned(
                    top: 187,
                    left: 109,
                    child: Container(
                      width: 174.84375,
                      height: 34.629173278808594,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.primary),
                        color: Colors.white.withOpacity(0.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _toggle(
                              text: "Mensuel",
                              active: !yearly,
                              onTap: () => _setPlanMode(false),
                            ),
                          ),
                          Expanded(
                            child: _toggle(
                              text: "Annuel",
                              active: yearly,
                              onTap: () => _setPlanMode(true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== PLANS (SCROLL HORIZONTAL) =====
                  Positioned(
                    top: 234,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 571,
                      width: 393,

                      // IMPORTANT: ensure drag gestures are caught
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (_) {},
                        child: PageView(
                          controller: _pc,
                          physics: const BouncingScrollPhysics(),
                          clipBehavior: Clip.none,
                          padEnds: false,

                          // OPTIONAL: if you want a small "snap" feeling
                          pageSnapping: true,

                          children: [
                            PlanCard(
                              title: "Basic",
                              subtitle: "Pour démarrer votre activité",
                              price: "0",
                              buttonText: "Choisir Basic",
                              mainColor: AppColors.grey800Color,
                              isFree: true,
                            ),
                            PlanCard(
                              title: "Pro",
                              subtitle: "Pour booster votre visibilité",
                              price: yearly ? "300" : "30", // مثال
                              buttonText: "Choisir Pro",
                              mainColor: AppColors.primary,
                            ),
                            PlanCard(
                              title: "Premium",
                              subtitle: "Pour dominer votre marché",
                              price: yearly ? "750" : "75", // مثال
                              buttonText: "Choisir Premium",
                              mainColor: const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ===== HOME INDICATOR =====
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
        ],
      ),
    );
  }

  // ===== CLEAN TOGGLE (clickable) =====
  Widget _toggle({
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9.55,
            fontWeight: FontWeight.w400,
            color: active ? AppColors.white : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// PlanCard (ton code, inchangé sauf si tu veux + features list)
// ===========================================================

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String buttonText;
  final Color mainColor;
  final bool isFree;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.buttonText,
    required this.mainColor,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isFree ? const Color(0xFFE5E7EB) : AppColors.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isFree ? "MAD/Gratuit" : "MAD",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _feature("Profil de base", true),
            _feature("Jusqu'à 5 demandes / mois", true),
            _feature("Support client standard", true),
            _feature("Portfolio jusqu'à 3 photos", true),
            _feature("Badge vérifié", !isFree),
            _feature("Statistiques", !isFree),
            _feature("Support prioritaire", price == "75" || price == "750"),
            _feature("Réponse automatique", price == "75" || price == "750"),
          ],
        ),
      ),
    );
  }

  Widget _feature(String text, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: enabled ? AppColors.textDark : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
