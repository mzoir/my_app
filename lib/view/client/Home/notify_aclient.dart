import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/utils/responsive.dart';
import 'navbottom.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Sample notification data
  static const List<Map<String, String>> _notifications = [
    {
      'name': 'Nom et Prénom',
      'time': 'now',
      'desc': 'Lorem ipsum dolor sit amet, consectetur adipiscing',
    },
    {
      'name': 'Nom et Prénom',
      'time': 'now',
      'desc': 'Lorem ipsum dolor sit amet, consectetur adipiscing',
    },
    {
      'name': 'Nom et Prénom',
      'time': 'now',
      'desc': 'Lorem ipsum dolor sit amet, consectetur adipiscing',
    },
    {
      'name': 'Nom et Prénom',
      'time': 'now',
      'desc': 'Lorem ipsum dolor sit amet, consectetur adipiscing',
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
                            _iconBtn(Icons.calendar_today_outlined, R),
                            SizedBox(width: R(10)),
                            _iconBtn(Icons.notifications_none_rounded, R),
                          ],
                        ),
                      ),
                      // Back arrow
                      Padding(
                        padding: EdgeInsets.fromLTRB(R(18), R(12), R(18), 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              final shell = context
                                  .findAncestorStateOfType<HomeShellCState>();
                              shell?.setIndex(
                                0,
                              ); // make _setIndex public: rename to setIndex
                            },
                            child: Container(
                              width: R(36),
                              height: R(36),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.black87,
                                size: R(18),
                              ),
                            ),
                          ),
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
                                  "Que recherchez-vous ?",
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

                // ── Notifications Body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: R(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Text(
                              "Notifications",
                              style: GoogleFonts.poppins(
                                fontSize: R(18),
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.notifications_none_rounded,
                              size: R(22),
                              color: const Color(0xFFFC5A15),
                            ),
                          ],
                        ),
                        SizedBox(height: R(6)),
                        Text(
                          "Worem ipsum dolor sit amet, consectetur adipiscing elit.",
                          style: GoogleFonts.poppins(
                            fontSize: R(12),
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: R(20)),

                        // Notification list
                        ...List.generate(_notifications.length, (i) {
                          final n = _notifications[i];
                          final isLast = i == _notifications.length - 1;
                          return Column(
                            children: [
                              _notificationTile(
                                n['name']!,
                                n['time']!,
                                n['desc']!,
                                R,
                              ),
                              if (!isLast)
                                Divider(
                                  height: R(1),
                                  color: Colors.grey.shade200,
                                ),
                            ],
                          );
                        }),
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

  Widget _notificationTile(
    String name,
    String time,
    String desc,
    double Function(double) R,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: R(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange circle avatar
          Container(
            width: R(38),
            height: R(38),
            decoration: const BoxDecoration(
              color: Color(0xFFFC5A15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: R(20)),
          ),
          SizedBox(width: R(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: R(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFC5A15),
                      ),
                    ),
                    SizedBox(width: R(8)),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: R(11),
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R(3)),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: R(11.5),
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: R(20), color: Colors.black45),
        ],
      ),
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
