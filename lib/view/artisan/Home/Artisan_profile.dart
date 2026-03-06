import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'edit_profile.dart';
import 'package:my_app/utils/responsive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 0;

  void _switchPage(int index) => setState(() => _currentIndex = index);

  Widget _getPage() {
    switch (_currentIndex) {
      case 1:
        return const EditProfileScreen();
      case 2:
        return MesPaiement();
      default:
        return ProfileBody(onSwitchPage: _switchPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AtlasAppBar(),
      body: _getPage(),
    );
  }
}

// ─── PROFILE BODY ─────────────────────────────────────────────────────────────

class ProfileBody extends StatelessWidget {
  final Function(int) onSwitchPage;
  const ProfileBody({super.key, required this.onSwitchPage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double R(double v) => Responsive.s(v);

        final hPad = R(18);
        final vm = context.watch<ClientViewModel>();
        final user = vm.user;
        final totalRequests = vm.requests.length;
        final completedRequests = vm.requests
            .where((r) => r.isCompleted)
            .length;

        return SingleChildScrollView(
          child: Column(
            children: [
              // ───── ORANGE HEADER (avatar + name only, no duplicate appbar) ─────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5601A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(R(32)),
                    bottomRight: Radius.circular(R(32)),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: R(22)),

                    // Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: R(94),
                          height: R(94),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: R(3),
                            ),
                            color: const Color(0xFFDDDDDD),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://i.pravatar.cc/200?img=47',
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: R(12),
                                offset: Offset(0, R(4)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: R(2),
                          right: R(2),
                          child: Container(
                            width: R(28),
                            height: R(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF5601A),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: R(14),
                              color: const Color(0xFFF5601A),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: R(10)),

                    Text(
                      user?.name ?? '—',
                      style: TextStyle(
                        fontSize: R(20),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (user?.email != null) ...[
                      SizedBox(height: R(4)),
                      Text(
                        user!.email,
                        style: TextStyle(
                          fontSize: R(12),
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],

                    SizedBox(height: R(22)),
                  ],
                ),
              ),

              SizedBox(height: R(20)),

              // ───── STATS 2x2 ─────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            icon: Icons.work_outline_rounded,
                            iconColor: const Color(0xFFF5601A),
                            iconBg: const Color(0xFFFFEDE5),
                            value: '$totalRequests',
                            label: 'Demandes',
                            R: R,
                          ),
                        ),
                        SizedBox(width: R(12)),
                        Expanded(
                          child: _StatBox(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF22C55E),
                            iconBg: const Color(0xFFDCFCE7),
                            value: '$completedRequests',
                            label: 'Projets terminés',
                            R: R,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: R(12)),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            icon: Icons.star_outline_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            iconBg: const Color(0xFFFFF8E1),
                            value: '4.8/5',
                            label: 'Note moyenne',
                            R: R,
                          ),
                        ),
                        SizedBox(width: R(12)),
                        Expanded(
                          child: _StatBox(
                            icon: Icons.phone_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            iconBg: const Color(0xFFDBEAFE),
                            value: '2h',
                            label: 'Temps de réponse',
                            R: R,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: R(20)),

              // ───── REFERRAL ─────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R(16),
                    vertical: R(14),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R(16)),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        color: const Color(0xFFF5601A),
                        size: R(20),
                      ),
                      SizedBox(width: R(10)),
                      Expanded(
                        child: Text(
                          'Programme de Parrainage',
                          style: TextStyle(
                            fontSize: R(13),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: R(16),
                            vertical: R(8),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5601A),
                            borderRadius: BorderRadius.circular(R(20)),
                          ),
                          child: Text(
                            'Générer',
                            style: TextStyle(
                              fontSize: R(12),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: R(20)),

              // ───── MENU ─────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  children: [
                    _MenuButton(
                      icon: Icons.manage_accounts_outlined,
                      label: 'Mes Informations',
                      onTap: () => onSwitchPage(1),
                      R: R,
                    ),
                    SizedBox(height: R(12)),
                    _MenuButton(
                      icon: Icons.credit_card_outlined,
                      label: 'Mes paiements',
                      onTap: () => onSwitchPage(2),
                      R: R,
                    ),
                  ],
                ),
              ),

              SizedBox(height: R(40)),

              // ───── LOGOUT ─────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: _LogoutButton(R: R),
              ),

              SizedBox(height: R(40)),
            ],
          ),
        );
      },
    );
  }
}

// ─── REUSABLE WIDGETS ─────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String value, label;
  final double Function(double) R;
  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.R,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(16)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: R(38),
            height: R(38),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(R(10)),
            ),
            child: Icon(icon, color: iconColor, size: R(20)),
          ),
          SizedBox(width: R(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: R(15),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: R(10),
                    color: const Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double Function(double) R;
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.R,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: R(20), vertical: R(18)),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2F33),
          borderRadius: BorderRadius.circular(R(16)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: R(20)),
            SizedBox(width: R(14)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: R(14),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withOpacity(0.6),
              size: R(18),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final double Function(double) R;
  const _LogoutButton({required this.R});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Se déconnecter',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Voulez-vous vraiment vous déconnecter ?',
              style: TextStyle(color: Color(0xFF666666)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Color(0xFF999999)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Déconnecter',
                  style: TextStyle(
                    color: Color(0xFFCC1F1F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await context.read<ClientViewModel>().logout();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: R(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(R(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: R(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: R(10)),
            Icon(Icons.logout_rounded, color: Colors.white, size: R(18)),
          ],
        ),
      ),
    );
  }
}

// ─── EDIT PROFILE ─────────────────────────────────────────────────────────────

class EditProfileBody extends StatefulWidget {
  const EditProfileBody({super.key});
  @override
  State<EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<EditProfileBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStyledField(label: "Nom complet", icon: Icons.person),
          const SizedBox(height: 16),
          _buildStyledField(
            label: "Adresse email",
            icon: Icons.email,
            hint: "exemple@email.com",
          ),
          const SizedBox(height: 16),
          _buildStyledField(
            label: "Téléphone",
            icon: Icons.phone,
            hint: "+212 600000000",
          ),
          const SizedBox(height: 16),
          _buildStyledField(
            label: "Date de naissance",
            icon: Icons.calendar_today,
            hint: "JJ/MM/AAAA",
          ),
          const SizedBox(height: 16),
          _buildStyledField(label: "Ville", icon: Icons.location_city),
          const SizedBox(height: 16),
          _buildStyledField(label: "Adresse", icon: Icons.home),
          const SizedBox(height: 16),
          _buildStyledField(
            label: "Code postale",
            icon: Icons.local_post_office,
            hint: "10000",
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {},
              child: const Text(
                "Modifier",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledField({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (hint != null)
                  Text(
                    hint,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MES PAIEMENTS ────────────────────────────────────────────────────────────

Widget MesPaiement() {
  return const Center(child: Text("Mes Paiements"));
}

// ─── ATLAS APP BAR ────────────────────────────────────────────────────────────

class AtlasAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AtlasAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5601A),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Atlas',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Fix',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5601A),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _AppBarIconBtn(icon: Icons.calendar_today_outlined),
                  const SizedBox(width: 10),
                  _AppBarIconBtn(icon: Icons.notifications_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  const _AppBarIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}