import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/view/core/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ simple FAQ open state
  int openFaq = 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // ✅ init your Responsive system with current constraints
        Responsive.init(c);

        // ✅ shortcut to scale values
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF3EC),

          // ✅ FIX: use Column inside ScrollView (NOT Positioned content)
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // =====================================================
                  // HEADER + SEARCH (only this part uses Stack)
                  // =====================================================
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // HEADER (fixed height => Stack is safe)
                      Container(
                        height: R(160),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFC5A15),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(R(28)),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: R(18),
                              left: R(18),
                              child: SvgPicture.asset(
                                'images/Exclude.svg',
                                height: R(34),
                              ),
                            ),
                            Positioned(
                              top: R(14),
                              right: R(18),
                              child: Row(
                                children: [
                                  _iconBtn(Icons.calendar_today_outlined, R),
                                  SizedBox(width: R(10)),
                                  _iconBtn(Icons.notifications_none_rounded, R),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SEARCH BAR (floating over header)
                      Positioned(
                        left: R(20),
                        right: R(20),
                        bottom: -R(23), // ✅ push down outside header
                        child: Container(
                          height: R(46),
                          padding: EdgeInsets.symmetric(horizontal: R(14)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(R(30)),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: R(10),
                                offset: Offset(0, R(4)),
                                color: Colors.black.withOpacity(0.08),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  size: R(18), color: Colors.black87),
                              SizedBox(width: R(8)),
                              Expanded(
                                child: Text(
                                  "Quelle demande recherchez-vous ?",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: R(12),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Container(
                                width: R(32),
                                height: R(32),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2F2F2F),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.tune,
                                    color: Colors.white, size: R(16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: R(40)), // ✅ space after floating search

                  // =====================================================
                  // CONTENT (no Positioned, fully scrollable)
                  // =====================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Annonce d’Aujourd’hui", R),
                        SizedBox(height: R(10)),
                        _promoCard(R),

                        SizedBox(height: R(24)),
                        _sectionRow("Nos artisans les mieux notés", "Voir plus", R),
                        SizedBox(height: R(14)),
                        _artisanRow(R),

                        SizedBox(height: R(30)),
                        _addServiceCard(R),

                        SizedBox(height: R(24)),
                        _sectionTitle("Programme de Parrainage", R),
                        SizedBox(height: R(10)),
                        _referralCard(R),

                        SizedBox(height: R(24)),
                        _sectionTitle("Questions fréquence", R),
                        SizedBox(height: R(12)),
                        _faqBlock(R),

                        SizedBox(height: R(120)), // space for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // BOTTOM NAV (must define R here too)
          // =====================================================
          bottomNavigationBar: Builder(
            builder: (context) {
              double R(double v) => Responsive.s(v);

              return Container(
                height: R(78),
                padding: EdgeInsets.only(bottom: R(10)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(R(30))),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: R(18),
                      offset: Offset(0, -R(6)),
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.home_rounded, true, R),
                    _navItem(Icons.receipt_long_rounded, false, R),
                    _navItem(Icons.handyman_rounded, false, R),
                    _navItem(Icons.chat_bubble_outline_rounded, false, R),
                    _navItem(Icons.person_outline_rounded, false, R),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =====================================================
  // WIDGETS
  // =====================================================

  Widget _iconBtn(IconData icon, double Function(double) R) {
    return Container(
      width: R(38),
      height: R(38),
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, size: R(18), color: Colors.black87),
    );
  }

  Widget _sectionTitle(String t, double Function(double) R) {
    return Text(
      t,
      style: GoogleFonts.poppins(
        fontSize: R(16),
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _sectionRow(String left, String right, double Function(double) R) {
    return Row(
      children: [
        Expanded(child: _sectionTitle(left, R)),
        Text(
          right,
          style: GoogleFonts.poppins(
            fontSize: R(12),
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: R(8)),
        Container(
          width: R(26),
          height: R(26),
          decoration: const BoxDecoration(
              color: Color(0xFF2F2F2F), shape: BoxShape.circle),
          child: Icon(Icons.arrow_forward_ios_rounded,
              size: R(12), color: Colors.white),
        ),
      ],
    );
  }

  Widget _promoCard(double Function(double) R) {
    return Container(
      width: double.infinity,
      height: R(150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R(18)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6A2A), Color(0xFFFC5A15)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: R(14),
            offset: Offset(0, R(8)),
            color: Colors.black.withOpacity(0.12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: R(18),
            top: R(18),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R(10), vertical: R(4)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(R(20)),
              ),
              child: Text(
                "Populaire",
                style: GoogleFonts.poppins(
                  fontSize: R(10),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: R(18),
            top: R(54),
            child: SizedBox(
              width: R(190),
              child: Text(
                "Jorem ipsum dolor sit amet, consectetur",
                style: GoogleFonts.poppins(
                  fontSize: R(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: R(18),
            bottom: R(18),
            child: Container(
              height: R(34),
              padding: EdgeInsets.symmetric(horizontal: R(14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R(20)),
              ),
              child: Center(
                child: Text(
                  "Découvrir maintenant",
                  style: GoogleFonts.poppins(
                    fontSize: R(11),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFC5A15),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: R(12),
            bottom: 0,
            top: 0,
            child: Icon(
              Icons.engineering_rounded,
              size: R(86),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _artisanRow(double Function(double) R) {
    return Row(
      children: [
        Expanded(
          child: _artisanCard(
            name: "Ahmed Bennani",
            city: "Casablanca",
            job: "Plomberie & Sanitaire",
            R: R,
          ),
        ),
        SizedBox(width: R(12)),
        Expanded(
          child: _artisanCard(
            name: "Omar Berrada",
            city: "Marrakech",
            job: "Dépannage Urgence",
            R: R,
          ),
        ),
      ],
    );
  }

  Widget _artisanCard({
    required String name,
    required String city,
    required String job,
    required double Function(double) R,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(16)),
        boxShadow: [
          BoxShadow(
            blurRadius: R(14),
            offset: Offset(0, R(6)),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(R(16))),
            child: Container(
              height: R(115),
              color: Colors.grey.shade300,
              child: Center(
                child: Icon(Icons.image,
                    size: R(30), color: Colors.grey.shade600),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(R(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: R(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.verified,
                        color: const Color(0xFF2D7FF9), size: R(14)),
                  ],
                ),
                SizedBox(height: R(4)),
                Text(job,
                    style: GoogleFonts.poppins(
                        fontSize: R(10.5), color: Colors.grey.shade700)),
                SizedBox(height: R(6)),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: R(14), color: Colors.grey.shade700),
                    SizedBox(width: R(4)),
                    Expanded(
                      child: Text(city,
                          style: GoogleFonts.poppins(
                              fontSize: R(10.5),
                              color: Colors.grey.shade700)),
                    ),
                  ],
                ),
                SizedBox(height: R(6)),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: R(14), color: const Color(0xFFFFA000)),
                    SizedBox(width: R(4)),
                    Text(
                      "4.9/5 (127 reviews)",
                      style: GoogleFonts.poppins(
                          fontSize: R(10.2), color: Colors.grey.shade700),
                    ),
                  ],
                ),
                SizedBox(height: R(10)),
                _btnOrange("View Profile", R,
                    icon: Icons.remove_red_eye_outlined),
                SizedBox(height: R(8)),
                _btnDark("Contacter", R,
                    icon: Icons.chat_bubble_outline_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnOrange(String t, double Function(double) R,
      {required IconData icon}) {
    return Container(
      height: R(36),
      decoration: BoxDecoration(
        color: const Color(0xFFFC5A15),
        borderRadius: BorderRadius.circular(R(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: R(16), color: Colors.white),
          SizedBox(width: R(8)),
          Text(
            t,
            style: GoogleFonts.poppins(
              fontSize: R(11),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnDark(String t, double Function(double) R,
      {required IconData icon}) {
    return Container(
      height: R(36),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(R(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: R(16), color: Colors.white),
          SizedBox(width: R(8)),
          Text(
            t,
            style: GoogleFonts.poppins(
              fontSize: R(11),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addServiceCard(double Function(double) R) {
    return Container(
      padding: EdgeInsets.all(R(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(18)),
        border: Border.all(color: const Color(0xFFFC5A15), width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(R(14)),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(R(16)),
          boxShadow: [
            BoxShadow(
              blurRadius: R(14),
              offset: Offset(0, R(8)),
              color: Colors.black.withOpacity(0.15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: R(34),
                  height: R(34),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(R(10)),
                  ),
                  child: Icon(Icons.add_task_rounded,
                      color: Colors.white, size: R(18)),
                ),
                SizedBox(width: R(10)),
                Expanded(
                  child: Text(
                    "En tant qu’artisan, souhaitez-vous ajouter un autre service ?",
                    style: GoogleFonts.poppins(
                        fontSize: R(12),
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: R(10)),
            Text(
              "Vorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum",
              style: GoogleFonts.poppins(
                  fontSize: R(10.5), color: Colors.white.withOpacity(0.85)),
            ),
            SizedBox(height: R(14)),
            Container(
              width: double.infinity,
              height: R(42),
              decoration: BoxDecoration(
                color: const Color(0xFFFC5A15),
                borderRadius: BorderRadius.circular(R(24)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white, size: R(16)),
                    SizedBox(width: R(8)),
                    Text(
                      "Ajouter un service",
                      style: GoogleFonts.poppins(
                          fontSize: R(11),
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _referralCard(double Function(double) R) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(R(14)),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E8),
            borderRadius: BorderRadius.circular(R(14)),
            border: Border.all(color: const Color(0xFFFFD79A), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt_rounded,
                  size: R(18), color: const Color(0xFFFC5A15)),
              SizedBox(width: R(10)),
              Expanded(
                child: Text(
                  "Gagnez 1 boost gratuit (7 jours) pour chaque ami qui crée un compte artisan via votre lien !",
                  style: GoogleFonts.poppins(fontSize: R(11), color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: R(12)),
        Container(
          width: double.infinity,
          height: R(44),
          decoration: BoxDecoration(
            color: const Color(0xFFFC5A15),
            borderRadius: BorderRadius.circular(R(26)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard_rounded,
                    color: Colors.white, size: R(16)),
                SizedBox(width: R(8)),
                Text(
                  "Générer mon lien de parrainage",
                  style: GoogleFonts.poppins(
                    fontSize: R(11.5),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _faqBlock(double Function(double) R) {
    return Column(
      children: [
        _faqTile(0, "Lorem ipsum dolor sit amet, cons", R),
        SizedBox(height: R(10)),
        _faqTile(1, "Lorem ipsum dolor sit amet, cons", R),
        SizedBox(height: R(10)),
        _faqTile(2, "Lorem ipsum dolor sit amet, cons", R),
        SizedBox(height: R(10)),
        _faqTile(3, "Lorem ipsum dolor sit amet, cons", R),
      ],
    );
  }

  Widget _faqTile(int i, String title, double Function(double) R) {
    final isOpen = openFaq == i;

    return InkWell(
      borderRadius: BorderRadius.circular(R(16)),
      onTap: () => setState(() => openFaq = (openFaq == i ? -1 : i)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: EdgeInsets.all(R(14)),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF3A3A3A) : Colors.white,
          borderRadius: BorderRadius.circular(R(16)),
          border: Border.all(
            color: isOpen ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: R(12),
                      fontWeight: FontWeight.w600,
                      color: isOpen ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isOpen ? Colors.white : const Color(0xFFFC5A15),
                ),
              ],
            ),
            if (isOpen) ...[
              SizedBox(height: R(10)),
              Text(
                "Korem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum.",
                style: GoogleFonts.poppins(
                  fontSize: R(10.5),
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, bool active, double Function(double) R) {
    return Container(
      width: R(54),
      height: R(54),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2F2F2F) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: R(24),
        color: active ? Colors.white : Colors.black87,
      ),
    );
  }
}
