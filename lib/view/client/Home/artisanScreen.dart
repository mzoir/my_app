import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/artisan_model.dart';
import 'package:my_app/utils/responsive.dart';
import "send_message.dart";

class ArtisanProfileScreen extends StatefulWidget {
  final ArtisanModel artisan;

  const ArtisanProfileScreen({super.key, required this.artisan});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  bool _ratingExpanded = false;
  bool _statsExpanded = false;
  bool _paymentExpanded = false;

  late ArtisanModel artisano;

  @override
  void initState() {
    super.initState();
    artisano = widget.artisan;

    // ✅ DEBUG — check what data is coming in
    debugPrint('========== ARTISAN PROFILE DEBUG ==========');
    debugPrint('Name: ${artisano.name}');
    debugPrint('profile_photo: ${artisano.profilePhoto}');
    debugPrint('portfolio_images count: ${artisano.portfolioImages.length}');
    for (int i = 0; i < artisano.portfolioImages.length; i++) {
      debugPrint('  image[$i]: ${artisano.portfolioImages[i]}');
    }
    debugPrint('===========================================');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
      
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: const Color(0xFFFDF4F0),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ───────────── HERO BANNER ─────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background image
                    SizedBox(
                      height: R(200),
                      width: double.infinity,
                      child: artisano.profilePhoto != null &&
                              artisano.profilePhoto!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: artisano.profilePhoto!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => _heroBg(R),
                              errorWidget: (_, _, _) => _heroBg(R),
                            )
                          : _heroBg(R),
                    ),

                    // Dark gradient overlay
                    Container(
                      height: R(200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),

                    // Back button + menu
                    Positioned(
                      top: R(48),
                      left: R(16),
                      right: R(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () =>
                                Navigator.pushNamed(context, '/home/client'),
                            R: R,
                          ),
                          _CircleBtn(
                            icon: Icons.more_vert_rounded,
                            onTap: () {},
                            R: R,
                          ),
                        ],
                      ),
                    ),

                    // Name + info
                    Positioned(
                      bottom: R(42),
                      left: R(130),
                      right: R(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artisano.name,
                            style: GoogleFonts.poppins(
                              fontSize: R(20),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R(2)),
                          Text(
                            artisano.services.isNotEmpty
                                ? artisano.services[0]
                                : 'Artisan',
                            style: GoogleFonts.poppins(
                              fontSize: R(12),
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          SizedBox(height: R(6)),
                          Row(
                            children: [
                              _BadgePill(
                                icon: Icons.verified_rounded,
                                iconColor: const Color(0xFF22C55E),
                                label: "Profil vérifié",
                                R: R,
                              ),
                              SizedBox(width: R(8)),
                              _BadgePill(
                                icon: Icons.location_on_outlined,
                                iconColor: Colors.white70,
                                label: artisano.ville ?? '—',
                                R: R,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Avatar
                    Positioned(
                      bottom: R(-28),
                      left: R(18),
                      child: Stack(
                        children: [
                          Container(
                            width: R(90),
                            height: R(90),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: R(3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: R(12),
                                  offset: Offset(0, R(4)),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: artisano.profilePhoto != null &&
                                      artisano.profilePhoto!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: artisano.profilePhoto!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) =>
                                          _avatarFallback(R),
                                      errorWidget: (_, _, _) =>
                                          _avatarFallback(R),
                                    )
                                  : _avatarFallback(R),
                            ),
                          ),
                          Positioned(
                            bottom: R(4),
                            left: R(4),
                            child: Container(
                              width: R(14),
                              height: R(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: R(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: R(38)),

                // ───────────── ACTION BUTTONS ─────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R(18)),
                  child: Row(
                    children: [
                      Expanded(
                        child: _OutlineBtn(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "Message",
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SendMessage(
                                  initialUserId: artisano.id,
                                  initialUserName: artisano.name,
                                  initialUserPhoto: artisano.profilePhoto,
                                ),
                              ),
                            );
                          },
                          R: R,
                        ),
                      ),
                      SizedBox(width: R(14)),
                      Expanded(
                        child: _FilledBtn(
                          icon: Icons.phone_rounded,
                          label: "Appel",
                          onTap: () {},
                          R: R,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: R(22)),

                // ───────────── À PROPOS ─────────────
                _SectionCard(
                  title: "À propos",
                  R: R,
                  child: Text(
                    artisano.description ??
                        "Expert en plomberie avec 15 ans d'expérience. Services rapides et professionnels.",
                    style: GoogleFonts.poppins(
                      fontSize: R(12.5),
                      color: const Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                ),

                SizedBox(height: R(16)),

                // ───────────── COMPÉTENCES ─────────────
                _SectionCard(
                  title: "Compétences",
                  R: R,
                  child: Wrap(
                    spacing: R(8),
                    runSpacing: R(8),
                    children: _buildSkills(artisano, R),
                  ),
                ),

                SizedBox(height: R(16)),

                // ───────────── RATING ─────────────
                _ExpandableCard(
                  leading: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: const Color(0xFFF59E0B),
                        size: R(20),
                      ),
                      SizedBox(width: R(6)),
                      Text(
                        "4.9",
                        style: GoogleFonts.poppins(
                          fontSize: R(16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "127 avis",
                        style: GoogleFonts.poppins(
                          fontSize: R(12),
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  expanded: _ratingExpanded,
                  onTap: () =>
                      setState(() => _ratingExpanded = !_ratingExpanded),
                  expandedContent: _RatingBreakdown(R: R),
                  R: R,
                ),

                SizedBox(height: R(12)),

                // ───────────── STATISTIQUES ─────────────
                _ExpandableCard(
                  leading: Text(
                    "Statistiques",
                    style: GoogleFonts.poppins(
                      fontSize: R(14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  expanded: _statsExpanded,
                  onTap: () => setState(() => _statsExpanded = !_statsExpanded),
                  expandedContent: _StatsContent(R: R),
                  R: R,
                ),

                SizedBox(height: R(22)),

                // ───────────── GALERIE ─────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R(18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Galerie de projets",
                        style: GoogleFonts.poppins(
                          fontSize: R(15),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: R(12)),
                      _GalleryGrid(
                        images: artisano.portfolioImages
                            .whereType<String>()
                            .toList(),
                        R: R,
                        onImageTap: (url) => _showFullImage(context, url),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: R(16)),

                // ───────────── PAIEMENT SÉCURISÉ ─────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R(18)),
                  child: _ExpandableCard(
                    leading: Text(
                      "Paiement sécurisé",
                      style: GoogleFonts.poppins(
                        fontSize: R(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    expanded: _paymentExpanded,
                    onTap: () =>
                        setState(() => _paymentExpanded = !_paymentExpanded),
                    expandedContent: Padding(
                      padding: EdgeInsets.only(top: R(12)),
                      child: Text(
                        "Tous les paiements sont sécurisés et protégés. Vous ne serez débité qu'après confirmation du travail.",
                        style: GoogleFonts.poppins(
                          fontSize: R(12),
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ),
                    R: R,
                  ),
                ),

                SizedBox(height: R(40)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Full screen image viewer
  void _showFullImage(BuildContext context, String url) {
    debugPrint('👁️ Opening full image: $url');
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, _) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, _, _) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSkills(ArtisanModel artisan, double Function(double) R) {
    final skills = ["Installation", "Réparation", "Maintenance"];
    return skills
        .map(
          (s) => Container(
            padding: EdgeInsets.symmetric(horizontal: R(14), vertical: R(6)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDE5),
              borderRadius: BorderRadius.circular(R(20)),
              border: Border.all(
                color: const Color(0xFFFC5A15).withOpacity(0.3),
              ),
            ),
            child: Text(
              s,
              style: GoogleFonts.poppins(
                fontSize: R(11.5),
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFC5A15),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _heroBg(double Function(double) R) => Container(
        color: const Color(0xFF4CAF50),
        child: Center(
          child: Icon(
            Icons.landscape_rounded,
            color: Colors.white.withOpacity(0.3),
            size: R(80),
          ),
        ),
      );

  Widget _avatarFallback(double Function(double) R) => Container(
        color: const Color(0xFFE5E7EB),
        child: Icon(
          Icons.person_rounded,
          color: const Color(0xFF9CA3AF),
          size: R(44),
        ),
      );
}

List<Widget> _buildSkills(ArtisanModel artisan, double Function(double) R) {
  final skills = <String>[
    "Installation",
    "Réparation",
    "Maintenance",
    "Conseil",
    "Urgence 24/7",
  ];
  return skills
      .map(
        (s) => Container(
          padding: EdgeInsets.symmetric(horizontal: R(14), vertical: R(6)),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDE5),
            borderRadius: BorderRadius.circular(R(20)),
            border:
                Border.all(color: const Color(0xFFFC5A15).withOpacity(0.3)),
          ),
          child: Text(
            s,
            style: GoogleFonts.poppins(
              fontSize: R(11.5),
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFC5A15),
            ),
          ),
        ),
      )
      .toList();
}

Widget _heroBg(double Function(double) R) {
  return Container(
    color: const Color(0xFF4CAF50),
    child: Center(
      child: Icon(
        Icons.landscape_rounded,
        color: Colors.white.withOpacity(0.3),
        size: R(80),
      ),
    ),
  );
}

Widget _avatarFallback(double Function(double) R) {
  return Container(
    color: const Color(0xFFE5E7EB),
    child: Icon(
      Icons.person_rounded,
      color: const Color(0xFF9CA3AF),
      size: R(44),
    ),
  );
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double Function(double) R;
  const _CircleBtn({required this.icon, required this.onTap, required this.R});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R(22)),
      child: Container(
        width: R(40),
        height: R(40),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: R(18)),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double Function(double) R;
  const _BadgePill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.R,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R(8), vertical: R(4)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(R(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: R(13)),
          SizedBox(width: R(4)),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: R(10),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double Function(double) R;
  const _OutlineBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.R,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: R(16), color: const Color(0xFFFC5A15)),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: R(13),
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFC5A15),
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, R(48)),
        side: const BorderSide(color: Color(0xFFFC5A15)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R(28)),
        ),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double Function(double) R;
  const _FilledBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.R,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: R(16), color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: R(13),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, R(48)),
        backgroundColor: const Color(0xFFFC5A15),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R(28)),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double Function(double) R;
  const _SectionCard({
    required this.title,
    required this.child,
    required this.R,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: R(15),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: R(10)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(R(14)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R(14)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ExpandableCard extends StatelessWidget {
  final Widget leading;
  final bool expanded;
  final VoidCallback onTap;
  final Widget expandedContent;
  final double Function(double) R;
  const _ExpandableCard({
    required this.leading,
    required this.expanded,
    required this.onTap,
    required this.expandedContent,
    required this.R,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R(14)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.all(R(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(R(14)),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: leading),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280),
                    size: R(22),
                  ),
                ],
              ),
              if (expanded) expandedContent,
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBreakdown extends StatelessWidget {
  final double Function(double) R;
  const _RatingBreakdown({required this.R});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: R(14)),
      child: Column(
        children: [5, 4, 3, 2, 1]
            .map(
              (star) => Padding(
                padding: EdgeInsets.symmetric(vertical: R(3)),
                child: Row(
                  children: [
                    Text(
                      "$star",
                      style: GoogleFonts.poppins(
                        fontSize: R(11),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(width: R(6)),
                    Icon(
                      Icons.star_rounded,
                      size: R(13),
                      color: const Color(0xFFF59E0B),
                    ),
                    SizedBox(width: R(8)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(R(4)),
                        child: LinearProgressIndicator(
                          value: star == 5
                              ? 0.8
                              : star == 4
                                  ? 0.15
                                  : 0.03,
                          backgroundColor: const Color(0xFFF3F4F6),
                          color: const Color(0xFFFC5A15),
                          minHeight: R(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final double Function(double) R;
  const _StatsContent({required this.R});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: R(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: "127", label: "Avis", R: R),
          _StatItem(value: "98%", label: "Satisfaction", R: R),
          _StatItem(value: "3 ans", label: "Expérience", R: R),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final double Function(double) R;
  const _StatItem({required this.value, required this.label, required this.R});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: R(18),
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFC5A15),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: R(11),
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final List<String> images;
  final double Function(double) R;
  final void Function(String url) onImageTap;

  const _GalleryGrid({
    required this.images,
    required this.R,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ DEBUG — print images received by gallery
    debugPrint('🖼️ GalleryGrid received ${images.length} images:');
    for (int i = 0; i < images.length; i++) {
      debugPrint('  🖼️ gallery[$i]: ${images[i]}');
    }

    if (images.isEmpty) {
      debugPrint('⚠️ GalleryGrid: no images to display');
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(R(14)),
            child: SizedBox(
              height: R(170),
              width: double.infinity,
              child: _imgPlaceholder(R),
            ),
          ),
          SizedBox(height: R(8)),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? R(8) : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(R(10)),
                    child: SizedBox(
                      height: R(80),
                      child: _imgPlaceholder(R),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // ✅ First big image
        GestureDetector(
          onTap: () {
            debugPrint('👆 Tapped main image: ${images[0]}');
            onImageTap(images[0]);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(R(14)),
            child: SizedBox(
              height: R(170),
              width: double.infinity,
              child: CachedNetworkImage(
                key: UniqueKey(),
                imageUrl: images[0],
                fit: BoxFit.cover,
                placeholder: (_, _) => _imgPlaceholder(R),
                errorWidget: (_, url, error) {
                  debugPrint('❌ Failed main image: $url | $error');
                  return _imgPlaceholder(R);
                },
              ),
            ),
          ),
        ),

        if (images.length > 1) ...[
          SizedBox(height: R(8)),
          // ✅ Row of up to 3 thumbnails
          Row(
            children: List.generate(
              (images.length - 1).clamp(0, 3),
              (i) {
                final imgIndex = i + 1;
                final isLastWithMore = i == 2 && images.length > 4;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? R(8) : 0),
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('👆 Tapped thumbnail[$i]: ${images[imgIndex]}');
                        onImageTap(images[imgIndex]);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(R(10)),
                        child: SizedBox(
                          height: R(80),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                key: UniqueKey(),
                                imageUrl: images[imgIndex],
                                fit: BoxFit.cover,
                                placeholder: (_, _) => _imgPlaceholder(R),
                                errorWidget: (_, url, error) {
                                  debugPrint('❌ Failed thumbnail[$i]: $url | $error');
                                  return _imgPlaceholder(R);
                                },
                              ),
                              if (isLastWithMore)
                                Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Text(
                                      '+${images.length - 4}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: R(16),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _imgPlaceholder(double Function(double) R) => Container(
        color: const Color(0xFFE5E7EB),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: const Color(0xFF9CA3AF),
            size: R(30),
          ),
        ),
      );
}