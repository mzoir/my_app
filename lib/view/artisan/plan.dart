import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/view/artisan/Home/official.dart';
// ✅ from lib/utils

class SubscriptionPlans extends StatefulWidget {
  const SubscriptionPlans({super.key});

  @override
  State<SubscriptionPlans> createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends State<SubscriptionPlans> {
  late final PageController _pc;

  bool yearly = true;

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
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        double R(double v) => Responsive.s(v);

        // center helper
        double cx(double figmaW) => (c.maxWidth - R(figmaW)) / 2;

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

              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: c.maxHeight,
                  child: Stack(
                    children: [
                      // ===== LOGO (centered) =====
                      Positioned(
                        top: R(79),
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SvgPicture.asset(
                            'images/Exclude.svg',
                            width: R(158.693359375),
                            height: R(37),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // ===== TITLE (centered) =====
                      Positioned(
                        top: R(140),
                        left: cx(352),
                        child: SizedBox(
                          width: R(352),
                          child: Text(
                            "Choisissez votre abonnement",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: R(20),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                              letterSpacing: -0.45,
                            ),
                          ),
                        ),
                      ),

                      // ===== TOGGLE (centered) =====
                      Positioned(
                        top: R(187),
                        left: cx(174.84375),
                        child: Container(
                          width: R(174.84375),
                          height: R(34.629173278808594),
                          padding: EdgeInsets.all(R(4)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(R(30)),
                            border: Border.all(color: AppColors.primary),
                            color: Colors.white.withOpacity(0.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _toggle(
                                  R: R,
                                  text: "Mensuel",
                                  active: !yearly,
                                  onTap: () => _setPlanMode(false),
                                ),
                              ),
                              Expanded(
                                child: _toggle(
                                  R: R,
                                  text: "Annuel",
                                  active: yearly,
                                  onTap: () => _setPlanMode(true),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ===== PLANS (PageView) =====
                      Positioned(
                        top: R(234),
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: (c.maxHeight - R(234) - R(30)).clamp(
                            R(420),
                            R(700),
                          ),
                          width: double.infinity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragStart: (_) {},
                            child: PageView(
                              controller: _pc,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              padEnds: false,
                              pageSnapping: true,
                              children: [
                                PlanCard(
                                  R: R,
                                  title: "Basic",
                                  subtitle: "Pour démarrer votre activité",
                                  price: "0",
                                  buttonText: "Choisir Basic",
                                  mainColor: AppColors.grey800Color,
                                  isFree: true,
                                ),
                                PlanCard(
                                  R: R,
                                  title: "Pro",
                                  subtitle: "Pour booster votre visibilité",
                                  price: yearly ? "300" : "30",
                                  buttonText: "Choisir Pro",
                                  mainColor: AppColors.primary,
                                ),
                                PlanCard(
                                  R: R,
                                  title: "Premium",
                                  subtitle: "Pour dominer votre marché",
                                  price: yearly ? "750" : "75",
                                  buttonText: "Choisir Premium",
                                  mainColor: const Color(0xFF2563EB),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ===== HOME INDICATOR (centered bottom) =====
                      Positioned(
                        bottom: R(12),
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SvgPicture.asset(
                            'images/HomeIndicator.svg',
                            width: R(134),
                            height: R(5),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _toggle({
    required double Function(double) R,
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(R(20)),
      onTap: onTap,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(R(20)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: R(9.55),
            fontWeight: FontWeight.w400,
            color: active ? AppColors.white : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// PlanCard (responsive)
// ===========================================================

class PlanCard extends StatelessWidget {
  final double Function(double) R;

  final String title;
  final String subtitle;
  final String price;
  final String buttonText;
  final Color mainColor;
  final bool isFree;

  const PlanCard({
    super.key,
    required this.R,
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
      padding: EdgeInsets.only(left: R(20), right: R(10)),
      child: Container(
        padding: EdgeInsets.fromLTRB(R(18), R(22), R(18), R(18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R(26)),
          border: Border.all(
            color: isFree ? const Color(0xFFE5E7EB) : AppColors.primary,
            width: R(2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: R(10),
              offset: Offset(0, R(6)),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: R(66),
              height: R(66),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(R(18)),
              ),
              child: Icon(Icons.check, color: Colors.white, size: R(28)),
            ),
            SizedBox(height: R(12)),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: R(18),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: R(6)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: R(12),
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: R(18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontSize: R(42),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: R(6)),
               Text(
                    isFree ? "MAD/Gratuit" : "MAD",
                    style: GoogleFonts.poppins(
                      fontSize: R(16),
                      color: AppColors.textLight,
                    ),
                
                ),
              ],
            ),
            SizedBox(height: R(16)),
            SizedBox(
              width: double.infinity,
              height: R(46),
              child: ElevatedButton(
                onPressed: () {

{
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  }


                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R(18)),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: R(14),
                  ),
                ),
              ),
            ),
            SizedBox(height: R(14)),
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
      padding: EdgeInsets.symmetric(vertical: R(4)),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: R(18),
            color: enabled ? Colors.green : Colors.grey,
          ),
          SizedBox(width: R(8)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: R(12),
                color: enabled ? AppColors.textDark : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
