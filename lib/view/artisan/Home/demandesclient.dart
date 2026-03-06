import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/service_request.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/viewmodels/artisan_view_model.dart';
import 'package:provider/provider.dart';

class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArtisanViewModel>(context, listen: false).fetchAllRequests();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _Header(
                R: R,
                searchCtrl: _searchCtrl,
                onSearch: (q) {
                  setState(() => _searchQuery = q);
                },
              ),
              Expanded(
                child: Consumer<ArtisanViewModel>(
                  builder: (ctx, vm, _) {
                    if (vm.loadingRequests) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFC5A15),
                        ),
                      );
                    }
                    if (vm.error != null && vm.allRequests.isEmpty) {
                      return _ErrorState(vm: vm, R: R);
                    }
                    final filtered = vm.allRequests.where((r) {
                      if (_searchQuery.isEmpty) return true;
                      final q = _searchQuery.toLowerCase();
                      return (r.serviceName?.toLowerCase().contains(q) ??
                              false) ||
                          (r.description?.toLowerCase().contains(q) ?? false) ||
                          (r.ville?.toLowerCase().contains(q) ?? false);
                    }).toList();

                    return RefreshIndicator(
                      color: const Color(0xFFFC5A15),
                      onRefresh: () => vm.fetchAllRequests(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Section title
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                R(18),
                                R(20),
                                R(18),
                                R(14),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Demandes des clients",
                                        style: GoogleFonts.poppins(
                                          fontSize: R(17),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: R(2)),
                                      Text(
                                        "${filtered.length} nouvelle${filtered.length > 1 ? 's' : ''} demande${filtered.length > 1 ? 's' : ''} disponible${filtered.length > 1 ? 's' : ''}",
                                        style: GoogleFonts.poppins(
                                          fontSize: R(12),
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.handyman,
                                    color: const Color(0xFFFC5A15),
                                    size: R(26),
                                  ),
                                ],
                              ),
                            ),

                            // ── Filter row
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: R(18)),
                              child: Row(
                                children: [
                                  Container(
                                    width: R(46),
                                    height: R(46),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        R(12),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.filter_list_rounded,
                                      color: const Color(0xFF374151),
                                      size: R(22),
                                    ),
                                  ),
                                  SizedBox(width: R(10)),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        height: R(46),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFC5A15),
                                          borderRadius: BorderRadius.circular(
                                            R(30),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Filtrer",
                                            style: GoogleFonts.poppins(
                                              fontSize: R(14),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: R(16)),

                            // ── Cards
                            if (filtered.isEmpty)
                              _EmptyState(R: R)
                            else
                              ...filtered.map(
                                (req) => Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    R(14),
                                    0,
                                    R(14),
                                    R(14),
                                  ),
                                  child: _RequestCard(request: req, R: R),
                                ),
                              ),

                            SizedBox(height: R(20)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════
// HEADER
// ═══════════════════════════════════════
class _Header extends StatelessWidget {
  final double Function(double) R;
  final TextEditingController searchCtrl;
  final void Function(String) onSearch;

  const _Header({
    required this.R,
    required this.searchCtrl,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFC5A15),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(R(18), R(12), R(18), R(18)),
          child: Column(
            children: [
              // Logo + icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Atlas ",
                        style: GoogleFonts.poppins(
                          fontSize: R(22),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: R(7),
                          vertical: R(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(R(6)),
                        ),
                        child: Text(
                          "Fix",
                          style: GoogleFonts.poppins(
                            fontSize: R(13),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFC5A15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _IconBtn(icon: Icons.calendar_month_outlined, R: R),
                      SizedBox(width: R(10)),
                      _IconBtn(icon: Icons.notifications_outlined, R: R),
                    ],
                  ),
                ],
              ),
              SizedBox(height: R(14)),
              // Search bar
              Container(
                height: R(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R(30)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: R(14)),
                    Icon(
                      Icons.search,
                      color: const Color(0xFF9CA3AF),
                      size: R(20),
                    ),
                    SizedBox(width: R(8)),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: onSearch,
                        style: GoogleFonts.poppins(
                          fontSize: R(13),
                          color: const Color(0xFF374151),
                        ),
                        decoration: InputDecoration(
                          hintText: "Quelle demande recherchez-vous ?",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: R(12.5),
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(R(6)),
                      width: R(36),
                      height: R(36),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(R(22)),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: R(18),
                      ),
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final double Function(double) R;
  const _IconBtn({required this.icon, required this.R});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R(40),
      height: R(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: R(20)),
    );
  }
}

// ═══════════════════════════════════════
// REQUEST CARD
// ═══════════════════════════════════════
class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final double Function(double) R;

  const _RequestCard({required this.request, required this.R});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R(16)),
        border: Border.all(
          color: const Color.fromARGB(255, 223, 70, 15),
          width: R(1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(R(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: avatar | name+date+time | badge ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + green dot
                    Stack(
                      children: [
                        Container(
                          width: R(52),
                          height: R(52),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: R(2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: R(6),
                                offset: Offset(0, R(2)),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              "",
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _avatarFallback(R),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: R(2),
                          left: R(2),
                          child: Container(
                            width: R(13),
                            height: R(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: R(1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: R(10)),

                    // Name + date + time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.clientName ?? "Client",
                            style: GoogleFonts.poppins(
                              fontSize: R(13.5),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: R(2)),
                          Text(
                            _formatDate(request.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: R(11.5),
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: R(3)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: R(12),
                                color: const Color(0xFF6B7280),
                              ),
                              SizedBox(width: R(3)),
                              Text(
                                _formatTime(request.createdAt),
                                style: GoogleFonts.poppins(
                                  fontSize: R(11.5),
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: R(6)),

                    // Service badge + location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: R(7), vertical: R(4)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(R(20)),
                            border: Border.all(
                                color: const Color(0xFFD1D5DB), width: R(0.8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                request.serviceName ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: R(9),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              if (request.serviceType != null &&
                                  request.serviceType!.isNotEmpty) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: R(2)),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: R(8),
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                                Text(
                                  request.serviceType!,
                                  style: GoogleFonts.poppins(
                                    fontSize: R(9),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: R(6)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: R(12),
                              color: const Color(0xFFFC5A15),
                            ),
                            SizedBox(width: R(2)),
                            Text(
                              [request.ville, request.address]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                              style: GoogleFonts.poppins(
                                fontSize: R(11),
                                color: const Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: R(12)),

                // ── Title + Description container ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(R(14)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDE5),
                    borderRadius: BorderRadius.circular(R(14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Orange Title ──
                      Text(
                        request.serviceName ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: R(15),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFC5A15),
                        ),
                      ),

                      SizedBox(height: R(6)),

                      // ── Description ──
                      if (request.description != null &&
                          request.description!.isNotEmpty)
                        Text(
                          request.description!,
                          style: GoogleFonts.poppins(
                            fontSize: R(12.5),
                            color: const Color(0xFF374151),
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Voir le détail button ──
          Padding(
            padding: EdgeInsets.fromLTRB(R(14), 0, R(14), R(14)),
            child: SizedBox(
              width: double.infinity,
              height: R(44),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5A15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R(30)),
                  ),
                ),
                child: Text(
                  "Voir le détail",
                  style: GoogleFonts.poppins(
                    fontSize: R(13.5),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(double Function(double) R) {
    return Container(
      color: const Color(0xFFFFEDE5),
      child: Icon(
        Icons.person_rounded,
        color: const Color(0xFFFC5A15),
        size: R(30),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final double Function(double) R;
  const _EmptyState({required this.R});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R(60)),
        child: Column(
          children: [
            Container(
              width: R(80),
              height: R(80),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEDE5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                color: const Color(0xFFFC5A15),
                size: R(40),
              ),
            ),
            SizedBox(height: R(16)),
            Text(
              "Aucune demande trouvée",
              style: GoogleFonts.poppins(
                fontSize: R(15),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: R(6)),
            Text(
              "Les demandes des clients apparaîtront ici",
              style: GoogleFonts.poppins(
                fontSize: R(12),
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════
class _ErrorState extends StatelessWidget {
  final ArtisanViewModel vm;
  final double Function(double) R;
  const _ErrorState({required this.vm, required this.R});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: R(48)),
            SizedBox(height: R(12)),
            Text(
              vm.error!,
              style: GoogleFonts.poppins(
                fontSize: R(13),
                color: Colors.red[400],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R(16)),
            ElevatedButton.icon(
              onPressed: () => vm.fetchAllRequests(),
              icon: Icon(Icons.refresh_rounded, size: R(16)),
              label: Text(
                "Réessayer",
                style: GoogleFonts.poppins(
                  fontSize: R(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC5A15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(30)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: R(24),
                  vertical: R(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}