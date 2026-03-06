import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'package:my_app/models/artisan_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'notify_artisan.dart';
import 'artisanScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int openFaq = 1;
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    // Fetch artisans from DB on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientViewModel>().fetchArtisans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientViewModel>();

    return LayoutBuilder(
      builder: (context, c) {
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF3EC),

          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // =====================================================
                  // HEADER + SEARCH
                  // =====================================================
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Orange header
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
                            // Logo
                            Positioned(
                              top: R(18),
                              left: R(18),
                              child: _logoWidget(R),
                            ),
                            // Action icons
                            Positioned(
                              top: R(14),
                              right: R(18),
                              child: Row(
                                children: [
                                  _iconBtn(Icons.calendar_today_outlined, R),
                                  SizedBox(width: R(10)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const NotificationsPage(),
                                        ),
                                      );
                                    },
                                    child: _iconBtn(
                                      Icons.notifications_none_rounded,
                                      R,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating search bar
                      Positioned(
                        left: R(40),
                        right: R(40),
                        top: R(80),
                        child: Container(
                          height: R(56),
                          padding: EdgeInsets.symmetric(horizontal: R(14)),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 209, 138, 75),
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
                              Icon(
                                Icons.search,
                                size: R(18),
                                color: Colors.black87,
                              ),
                              SizedBox(width: R(8)),
                              Expanded(
                                child: TextField(
  style: GoogleFonts.poppins(
    fontSize: R(12),
    color: Colors.black, // Text color when user types
  ),
  decoration: InputDecoration(
    hintText: "Quelle demande recherchez-vous ?", // Placeholder
    hintStyle: GoogleFonts.poppins(
      fontSize: R(12),
      color: Colors.grey.shade600, // Same as your previous Text
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners if you want
      borderSide: BorderSide.none, // No border
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                child: Icon(
                                  Icons.search_off_rounded,
                                  color: Colors.white,
                                  size: R(16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: R(40)),

                  // =====================================================
                  // CONTENT
                  // =====================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("Annonce d'Aujourd'hui", R),
                        SizedBox(height: R(10)),
                        _promoCard(R),

                        SizedBox(height: R(24)),
                        _sectionRow(
                          "Nos artisans les mieux notés",
                          "Voir plus",
                          R,
                        ),
                        SizedBox(height: R(14)),

                        // ── Dynamic artisan list from DB ──
                        SizedBox(
                          height: R(350),
                          child: vm.loadingArtisans
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFFFC5A15),
                                    strokeWidth: R(2.5),
                                  ),
                                )
                              : vm.artisans.isEmpty
                              ? Center(
                                  child: Text(
                                    "Aucun artisan disponible",
                                    style: GoogleFonts.poppins(
                                      fontSize: R(13),
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: vm.artisans.length,
                                  separatorBuilder: (_, _) =>
                                      SizedBox(width: R(14)),
                                  itemBuilder: (context, i) =>
                                      ArtisanCard(artisan: vm.artisans[i]),
                                ),
                        ),

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

                        SizedBox(height: R(30)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // LOGO
  // =====================================================

  Widget _logoWidget(double Function(double) R) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Atlas',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: R(26),
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
        SizedBox(width: R(5)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: R(7), vertical: R(3)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(R(7)),
          ),
          child: Text(
            'Fix',
            style: GoogleFonts.poppins(
              fontSize: R(14),
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFC5A15),
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SHARED WIDGETS
  // =====================================================

  Widget _iconBtn(IconData icon, double Function(double) R) {
    return Container(
      width: R(38),
      height: R(38),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
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
            color: Color(0xFF2F2F2F),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: R(12),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PROMO CARD
  // =====================================================

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
              padding: EdgeInsets.symmetric(horizontal: R(10), vertical: R(4)),
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

  // =====================================================
  // ADD SERVICE CARD
  // =====================================================

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
                  child: Icon(
                    Icons.add_task_rounded,
                    color: Colors.white,
                    size: R(18),
                  ),
                ),
                SizedBox(width: R(10)),
                Expanded(
                  child: Text(
                    "En tant qu'artisan, souhaitez-vous ajouter un autre service ?",
                    style: GoogleFonts.poppins(
                      fontSize: R(12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R(10)),
            Text(
              "Vorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum",
              style: GoogleFonts.poppins(
                fontSize: R(10.5),
                color: Colors.white.withOpacity(0.85),
              ),
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
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: R(16),
                    ),
                    SizedBox(width: R(8)),
                    Text(
                      "Ajouter un service",
                      style: GoogleFonts.poppins(
                        fontSize: R(11),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  // =====================================================
  // REFERRAL CARD
  // =====================================================

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
              Icon(
                Icons.bolt_rounded,
                size: R(18),
                color: const Color(0xFFFC5A15),
              ),
              SizedBox(width: R(10)),
              Expanded(
                child: Text(
                  "Gagnez 1 boost gratuit (7 jours) pour chaque ami qui crée un compte artisan via votre lien !",
                  style: GoogleFonts.poppins(
                    fontSize: R(11),
                    color: Colors.black87,
                  ),
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
                Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: R(16),
                ),
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

  // =====================================================
  // FAQ
  // =====================================================

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

    return GestureDetector(
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

  // =====================================================
  // BOTTOM NAV ITEM
  // =====================================================

  Widget _navItem(IconData icon, int index, double Function(double) R) {
    final active = _selectedNav == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNav = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
      ),
    );
  }
}

// =====================================================
// ARTISAN CARD — takes ArtisanModel from DB ✅
// =====================================================

class ArtisanCard extends StatelessWidget {
  final ArtisanModel artisan;
  const ArtisanCard({super.key, required this.artisan});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    // Base design: width=210, height=343, border-radius=12
    // All values scaled proportionally from those base dimensions
    const double baseW = 210;
    const double baseH = 343;
    const double basePhotoH = 160; // photo takes ~160/343 of card height

    return Container(
      width: R(baseW),
      height: R(baseH),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(12)),
        border: Border.all(color: const Color(0xFFE5E7EB), width: R(0.71)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: R(14),
            offset: Offset(0, R(6)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo section ──
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(R(12))),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: artisan.profilePhoto ?? '',
                  width: R(baseW),
                  height: R(basePhotoH),
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: R(baseW),
                    height: R(basePhotoH),
                    color: const Color(0xFFE5E7EB),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: R(48),
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                // Orange flame badge top-left
                Positioned(
                  top: R(10),
                  left: R(10),
                  child: Container(
                    width: R(32),
                    height: R(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC5A15),
                      borderRadius: BorderRadius.circular(R(8)),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: R(18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Info section ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(R(12), R(10), R(12), R(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + verified
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          artisan.name,
                          style: GoogleFonts.poppins(
                            fontSize: R(14),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: R(4)),
                      Icon(
                        Icons.verified_rounded,
                        size: R(16),
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),

                  SizedBox(height: R(4)),

                  // Speciality
                  Text(
                    artisan.speciality.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: R(11.5),
                      color: const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: R(6)),

                  // City
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: R(13),
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(width: R(3)),
                      Expanded(
                        child: Text(
                          artisan.ville ?? '—',
                          style: GoogleFonts.poppins(
                            fontSize: R(11.5),
                            color: const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: R(6)),

                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: R(14),
                        color: const Color(0xFFFFA000),
                      ),
                      SizedBox(width: R(3)),
                      Text(
                        "4.9/5 (127 reviews)",
                        style: GoogleFonts.poppins(
                          fontSize: R(11),
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // View Profile button
                  SizedBox(
                    width: double.infinity,
                    height: R(36),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ArtisanProfileScreen(artisan: artisan),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R(22)),
                        ),
                      ),
                      child: Text(
                        "View Profile",
                        style: GoogleFonts.poppins(
                          fontSize: R(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: R(4)),

                  // Connecter button
                  SizedBox(
                    width: double.infinity,
                    height: R(38),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFC5A15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R(22)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: R(15),
                            color: Colors.white,
                          ),
                          SizedBox(width: R(7)),
                          Text(
                            "Connecter",
                            style: GoogleFonts.poppins(
                              fontSize: R(12),
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
            ),
          ),
        ],
      ),
    );
  }
}
