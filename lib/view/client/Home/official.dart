// home_shell.dart (RESPONSIVE like we did ✅)
// keep same widget names + no new arguments ✅

import 'package:my_app/viewmodels/client_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mesdeamndes.dart';
import 'demande.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/view/LoginP.dart';
import 'package:my_app/utils/responsive.dart';
import 'profileScreen.dart';
// ✅ same Responsive.s() system

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final pages = const [
    HomePage(),
    MesDemandesScreen(),
    NewDemandeFlow(),
    _StubPage(title: "Messages"),
    ProfileScreen(),
  ];

  void _setIndex(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        Responsive.init(c);
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: Stack(
            children: [
              IndexedStack(index: index, children: pages),

              Positioned(
                left: 0,
                right: 0,
                bottom: R(14),
                child: _BottomNav(current: index, onTap: (i) => _setIndex(i)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final serviceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  int faqOpen = 1; // second one opened like screenshot

  @override
  void dispose() {
    serviceCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: R(110)),
          child: Column(
            children: [
              // =================== ORANGE TOP (APPBAR) ===================
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(R(18), R(16), R(18), R(18)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC5A15),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(R(26)),
                    bottomRight: Radius.circular(R(26)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: R(30),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(text: "Atlas"),
                              const TextSpan(text: " "),
                              TextSpan(
                                text: "Fix",
                                style: TextStyle(
                                  fontSize: R(18),
                                  fontWeight: FontWeight.w800,
                                  backgroundColor: const Color(0xFFFF7A3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _CircleIcon(
                          icon: Icons.calendar_today_outlined,
                          onTap: () {},
                        ),
                        SizedBox(width: R(10)),
                        _CircleIcon(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: R(16)),

                    Row(
                      children: [
                        Expanded(
                          child: _SearchPill(
                            controller: serviceCtrl,
                            hint: "Quelle service recher...",
                            rightWidget: Container(
                              width: R(40),
                              height: R(40),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2D2F33),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: R(20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: R(12)),
                        Expanded(
                          child: _SearchPill(
                            controller: cityCtrl,
                            hint: "Ville...",
                            rightWidget: Container(
                              width: R(40),
                              height: R(40),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2D2F33),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: R(22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: R(18)),

              // =================== SECTION: CATEGORIES ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(18)),
                child: Row(
                  children: [
                    Text(
                      "Lorem ipsum",
                      style: GoogleFonts.poppins(
                        fontSize: R(18),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Voir plus",
                      style: GoogleFonts.poppins(
                        fontSize: R(12),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(width: R(8)),
                    Container(
                      width: R(28),
                      height: R(28),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2F33),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: R(18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R(14)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _CatItem(
                      color: Color(0xFFEF4444),
                      icon: Icons.build_rounded,
                      label: "Réparations\ngénérales",
                    ),
                    _CatItem(
                      color: Color(0xFF3B82F6),
                      icon: Icons.water_drop_rounded,
                      label: "Plomberie",
                    ),
                    _CatItem(
                      color: Color(0xFFF59E0B),
                      icon: Icons.flash_on_rounded,
                      label: "Électricité",
                    ),
                    _CatItem(
                      color: Color(0xFFA855F7),
                      icon: Icons.format_paint_rounded,
                      label: "Peinture",
                    ),
                    _CatItem(
                      color: Color(0xFFEF4444),
                      icon: Icons.electrical_services_rounded,
                      label: "élect...",
                    ),
                  ],
                ),
              ),

              SizedBox(height: R(24)),

              // =================== SECTION: TODAY AD ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(18)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Annonce d’Aujourd’hui",
                    style: GoogleFonts.poppins(
                      fontSize: R(18),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SizedBox(height: R(12)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(18)),
                child: _PromoCard(width: w),
              ),

              SizedBox(height: R(24)),
              // =================== SECTION: TOP ARTISANS ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(18)),
                child: Row(
                  children: [
                    Text(
                      "Nos artisans les mieux notés",
                      style: GoogleFonts.poppins(
                        fontSize: R(16),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Voir plus",
                      style: GoogleFonts.poppins(
                        fontSize: R(12),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(width: R(8)),
                    Container(
                      width: R(28),
                      height: R(28),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2F33),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: R(18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R(14)),

              SizedBox(
                height: R(350),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: R(18)),
                  children: const [
                    _ArtisanCard(
                      imageAsset: "images/artisan1.jpg",
                      name: "Ahmed Bennani",
                      job: "Plomberie & Sanitaire",
                      city: "Casablanca",
                      rating: "4.9/5 (127 reviews)",
                    ),
                    SizedBox(width: 14),
                    _ArtisanCard(
                      imageAsset: "images/artisan2.jpg",
                      name: "Omar Berrada",
                      job: "Dépannage Urgence",
                      city: "Marrakech",
                      rating: "4.9/5 (127 reviews)",
                    ),
                  ],
                ),
              ),

              SizedBox(height: R(26)),

              // =================== SECTION: FAQ ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(18)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Questions fréquentes",
                    style: GoogleFonts.poppins(
                      fontSize: R(18),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SizedBox(height: R(12)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: R(18)),
                child: Column(
                  children: [
                    _FaqTile(
                      title: "Lorem ipsum dolor sit amet, cons",
                      opened: faqOpen == 0,
                      onTap: () =>
                          setState(() => faqOpen = faqOpen == 0 ? -1 : 0),
                    ),
                    SizedBox(height: R(12)),
                    _FaqTile(
                      title: "Lorem ipsum dolor sit amet, cons",
                      opened: faqOpen == 1,
                      onTap: () =>
                          setState(() => faqOpen = faqOpen == 1 ? -1 : 1),
                      body:
                          "Korem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis. Class aptent taciti sociosqu.",
                    ),
                    SizedBox(height: R(12)),
                    _FaqTile(
                      title: "Lorem ipsum dolor sit amet, cons",
                      opened: faqOpen == 2,
                      onTap: () =>
                          setState(() => faqOpen = faqOpen == 2 ? -1 : 2),
                    ),
                    SizedBox(height: R(12)),
                    _FaqTile(
                      title: "Lorem ipsum dolor sit amet, cons",
                      opened: faqOpen == 3,
                      onTap: () =>
                          setState(() => faqOpen = faqOpen == 3 ? -1 : 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== BOTTOM NAV (RESPONSIVE) ======================
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Center(
      child: Container(
        height: R(64),
        margin: EdgeInsets.symmetric(horizontal: R(18)),
        padding: EdgeInsets.symmetric(horizontal: R(10)),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2F33),
          borderRadius: BorderRadius.circular(R(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: R(18),
              offset: Offset(0, R(10)),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              active: current == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.description_outlined,
              active: current == 1,
              onTap: () => onTap(1),
            ),
            _PlusButton(onTap: () => onTap(2)),
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              active: current == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              active: current == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return InkWell(
      borderRadius: BorderRadius.circular(R(24)),
      onTap: onTap,
      child: SizedBox(
        width: R(54),
        height: R(54),
        child: Center(
          child: Icon(
            icon,
            size: R(24),
            color: active ? Colors.white : Colors.white.withOpacity(0.55),
          ),
        ),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlusButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R(26)),
      child: Container(
        width: R(54),
        height: R(54),
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_rounded,
          color: const Color(0xFF2D2F33),
          size: R(26),
        ),
      ),
    );
  }
}

// ====================== SMALL WIDGETS (RESPONSIVE) ======================
class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return InkWell(
      borderRadius: BorderRadius.circular(R(22)),
      onTap: onTap,
      child: Container(
        width: R(42),
        height: R(42),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF111827), size: R(20)),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget rightWidget;

  const _SearchPill({
    required this.controller,
    required this.hint,
    required this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Container(
      height: R(54),
      padding: EdgeInsets.only(left: R(16), right: R(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(
                fontSize: R(12),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: R(12),
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          rightWidget,
        ],
      ),
    );
  }
}

class _CatItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _CatItem({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Column(
      children: [
        Container(
          width: R(54),
          height: R(54),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: R(22)),
        ),
        SizedBox(height: R(8)),
        SizedBox(
          width: R(62),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: R(10),
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final double width;

  const _PromoCard({required this.width});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Container(
      height: R(140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R(18)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7A3D), Color(0xFFFC5A15)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: R(14),
            offset: Offset(0, R(8)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: R(14),
            top: R(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: R(10), vertical: R(4)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(R(14)),
              ),
              child: Text(
                "Populaire",
                style: GoogleFonts.poppins(
                  fontSize: R(10),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            left: R(18),
            top: R(46),
            right: R(140),
            child: Text(
              "Jorem ipsum dolor sit\namet, consectetur",
              style: GoogleFonts.poppins(
                fontSize: R(16),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: R(18),
            bottom: R(14),
            child: Container(
              height: R(32),
              padding: EdgeInsets.symmetric(horizontal: R(14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R(18)),
              ),
              alignment: Alignment.center,
              child: Text(
                "Demander maintenant",
                style: GoogleFonts.poppins(
                  fontSize: R(10.5),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFC5A15),
                ),
              ),
            ),
          ),
          Positioned(
            right: R(10),
            bottom: 0,
            child: SizedBox(
              width: R(130),
              height: R(140),
              child: Image.asset(
                "images/worker.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.engineering_rounded,
                    color: Colors.white,
                    size: R(64),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtisanCard extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String job;
  final String city;
  final String rating;

  const _ArtisanCard({
    required this.imageAsset,
    required this.name,
    required this.job,
    required this.city,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Container(
      width: R(190),
      padding: EdgeInsets.all(R(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: R(14),
            offset: Offset(0, R(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(R(14)),
            child: Stack(
              children: [
                Image.asset(
                  imageAsset,
                  height: R(120),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: R(120),
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: R(10),
                  top: R(10),
                  child: Container(
                    width: R(28),
                    height: R(28),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: R(16),
                      color: const Color(0xFFFC5A15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: R(10)),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: R(13),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.verified_rounded,
                size: R(16),
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
          SizedBox(height: R(6)),
          Text(
            job,
            style: GoogleFonts.poppins(
              fontSize: R(11),
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: R(8)),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: R(14),
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(width: R(4)),
              Expanded(
                child: Text(
                  city,
                  style: GoogleFonts.poppins(
                    fontSize: R(11),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R(8)),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: R(14),
                color: const Color(0xFFF59E0B),
              ),
              SizedBox(width: R(4)),
              Expanded(
                child: Text(
                  rating,
                  style: GoogleFonts.poppins(
                    fontSize: R(10.5),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: R(36),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(18)),
                ),
              ),
              child: Text(
                "View Profile",
                style: GoogleFonts.poppins(
                  fontSize: R(11),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ),
          SizedBox(height: R(10)),
          SizedBox(
            width: double.infinity,
            height: R(38),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC5A15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(18)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_rounded, size: R(16), color: Colors.white),
                  SizedBox(width: R(8)),
                  Text(
                    "Connecter",
                    style: GoogleFonts.poppins(
                      fontSize: R(11),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _FaqTile extends StatelessWidget {
  final String title;
  final bool opened;
  final VoidCallback onTap;
  final String? body;

  const _FaqTile({
    required this.title,
    required this.opened,
    required this.onTap,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    final bg = opened ? const Color(0xFF2D2F33) : Colors.white;
    final fg = opened ? Colors.white : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R(16)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: R(16), vertical: R(14)),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(R(16)),
          border: Border.all(color: opened ? bg : const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: R(12),
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
                Icon(
                  opened
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: opened ? Colors.white : const Color(0xFFFC5A15),
                  size: R(22),
                ),
              ],
            ),
            if (opened && body != null) ...[
              SizedBox(height: R(10)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  body!,
                  style: GoogleFonts.poppins(
                    fontSize: R(11),
                    color: Colors.white.withOpacity(0.75),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StubPage extends StatelessWidget {
  final String title;
  const _StubPage({required this.title});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);
    final vm = context.read<ClientViewModel>();
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                vm.logout();
                Navigator.pushNamed(context, '/login');
              },
              child: Text("logout"),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: R(20),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
