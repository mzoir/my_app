import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/utils/responsive.dart';
import 'navbottom.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  static const List<Map<String, String>> _items = [
    {
      'name': 'Jean Dupont',
      'specialty': 'Jardinage et paysagisme',
      'date': "Aujourd'hui",
      'price': '180€',
      'duration': 'None',
    },
    {
      'name': 'Jean Dupont',
      'specialty': 'Plomberie',
      'date': 'Le 22.déc.2025',
      'price': '180€',
      'duration': '1-2 heures',
    },
    {
      'name': 'Jean Dupont',
      'specialty': 'Dépannage',
      'date': 'Le 14.Janv.2025',
      'price': '180€',
      'duration': 'None',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF3EC),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Orange Header ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC5A15),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(R(28)),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top row: logo + icons
                      Padding(
                        padding: EdgeInsets.fromLTRB(R(18), R(18), R(18), 0),
                        child: Row(
                          children: [
                            _logoWidget(R),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                final shell = context
                                    .findAncestorStateOfType<HomeShellCState>();
                                shell?.setIndex(6); // Agenda = 6
                              },
                              child: _iconBtn(Icons.calendar_today_outlined, R),
                            ),
                            SizedBox(width: R(10)),
                            GestureDetector(
                              onTap: () {
                                final shell = context
                                    .findAncestorStateOfType<HomeShellCState>();
                                shell?.setIndex(5); // Notifications = 5
                              },
                              child: _iconBtn(
                                Icons.notifications_none_rounded,
                                R,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search bar
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          R(18),
                          R(14),
                          R(18),
                          R(20),
                        ),
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
                              Icon(
                                Icons.search,
                                size: R(18),
                                color: Colors.black87,
                              ),
                              SizedBox(width: R(8)),
                              Expanded(
                                child: Text(
                                  "Quelle service recherchez-vous ?",
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
                                child: Icon(
                                  Icons.tune,
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
                ),

                SizedBox(height: R(24)),

                // ── Body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(R(20), 0, R(20), R(100)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Text(
                              "Agenda",
                              style: GoogleFonts.poppins(
                                fontSize: R(20),
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: R(22),
                              color: const Color(0xFFFC5A15),
                            ),
                          ],
                        ),
                        SizedBox(height: R(4)),
                        Text(
                          "Gorem ipsum dolor sit amet, consectetur adipiscing elit.",
                          style: GoogleFonts.poppins(
                            fontSize: R(12),
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: R(18)),

                        // Filter row
                        Row(
                          children: [
                            // Filter icon button
                            Container(
                              width: R(46),
                              height: R(46),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(R(12)),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Icon(
                                Icons.filter_alt_outlined,
                                size: R(22),
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: R(12)),
                            // Filtrer button
                            Expanded(
                              child: Container(
                                height: R(46),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFC5A15),
                                  borderRadius: BorderRadius.circular(R(26)),
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
                          ],
                        ),

                        SizedBox(height: R(20)),

                        // Cards
                        ..._items.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: R(16)),
                            child: _AgendaCard(item: item),
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
      },
    );
  }

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
}

// ── Agenda Card ──
class _AgendaCard extends StatelessWidget {
  final Map<String, String> item;
  const _AgendaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(16)),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: R(10),
            offset: Offset(0, R(4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: avatar + info + date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with online dot
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(R(26)),
                    child: Container(
                      width: R(52),
                      height: R(52),
                      color: const Color(0xFFE5E7EB),
                      child: Icon(
                        Icons.person_rounded,
                        size: R(32),
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: R(2),
                    right: R(2),
                    child: Container(
                      width: R(12),
                      height: R(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: R(1.5)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: R(12)),
              // Name + specialty + rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: R(13),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      item['specialty']!,
                      style: GoogleFonts.poppins(
                        fontSize: R(11),
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: R(3)),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: R(13),
                          color: const Color(0xFFFFA000),
                        ),
                        SizedBox(width: R(3)),
                        Text(
                          "4.8  (127 avis)",
                          style: GoogleFonts.poppins(
                            fontSize: R(10.5),
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Date badge
              Text(
                item['date']!,
                style: GoogleFonts.poppins(
                  fontSize: R(10),
                  color: const Color(0xFFFC5A15),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: R(14)),
          Divider(height: R(1), color: Colors.grey.shade100),
          SizedBox(height: R(12)),

          // Price + duration
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prix proposé",
                    style: GoogleFonts.poppins(
                      fontSize: R(10),
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    item['price']!,
                    style: GoogleFonts.poppins(
                      fontSize: R(20),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFC5A15),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Durée estimée",
                    style: GoogleFonts.poppins(
                      fontSize: R(10),
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    item['duration']!,
                    style: GoogleFonts.poppins(
                      fontSize: R(13),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: R(14)),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: R(14),
                    color: const Color(0xFFFC5A15),
                  ),
                  label: Text(
                    "Annuler la demande",
                    style: GoogleFonts.poppins(
                      fontSize: R(10.5),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFC5A15),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFC5A15)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R(22)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: R(10)),
                  ),
                ),
              ),
              SizedBox(width: R(10)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: R(14),
                    color: Colors.white,
                  ),
                  label: Text(
                    "Voir le profil",
                    style: GoogleFonts.poppins(
                      fontSize: R(10.5),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC5A15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R(22)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: R(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
