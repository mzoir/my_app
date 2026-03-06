import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'edit_profile.dart';

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex =
      0; // 0 = ProfileBody, 1 = EditProfileBody, 2 = MesPaiement

  Widget _getPage() {
    switch (_currentIndex) {
      case 1:
        return const EditProfileScreen();
      case 2:
        return MesPaiement();
      default:
        return const ProfileBody();
    }
  }

  void _switchPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: const AtlasAppBar(),
      body: _getPage(),
    );
  }
}

// ─── CUSTOM APP BAR ───────────────────────────────────────────────────────────

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

// ─── PROFILE BODY ─────────────────────────────────────────────────────────────

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth > 600 ? 40.0 : 20.0;
    const double avatarRadius = 54.0;

    final profileScreenState = context
        .findAncestorStateOfType<_ProfileScreenState>();

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  color: const Color(0xFFF5601A),
                ),
              ),
              const Positioned(
                bottom: -avatarRadius,
                child: _AvatarWidget(radius: avatarRadius),
              ),
            ],
          ),
          const SizedBox(height: avatarRadius + 14),
          const _ProfileNameSection(),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: const _StatsRow(),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: _MenuItems(
              onSwitchPage: (index) => profileScreenState?._switchPage(index),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: const _LogoutButton(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── AVATAR WIDGET ────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final double radius;
  const _AvatarWidget({required this.radius});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ClientViewModel>();
    final user = auth.user;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            color: const Color(0xFFDDDDDD),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/200?img=47'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF5601A), width: 1.5),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 15,
              color: Color(0xFFF5601A),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PROFILE NAME SECTION ─────────────────────────────────────────────────────

class _ProfileNameSection extends StatelessWidget {
  const _ProfileNameSection();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ClientViewModel>();
    final user = auth.user;

    return Column(
      children: [
        Text(
          user?.name ?? '—',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
        ),
        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            user.phone!,
            style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
        ],
      ],
    );
  }
}

// ─── STATS ROW ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ClientViewModel>();
    final totalRequests = auth.requests.length;
    final completedRequests = auth.requests.where((r) => r.isCompleted).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.access_time_outlined,
            value: '$totalRequests',
            label: 'Demandes',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.person_outline,
            value: '$completedRequests',
            label: 'Projets terminés',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5601A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 241, 241, 241),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── MENU ITEMS ───────────────────────────────────────────────────────────────

class _MenuItems extends StatelessWidget {
  final Function(int) onSwitchPage;

  const _MenuItems({required this.onSwitchPage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.manage_accounts_outlined,
          label: 'Mes Informations',
          onTap: () => onSwitchPage(1),
        ),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.credit_card_outlined,
          label: 'Mes paiements',
          onTap: () => onSwitchPage(2),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── LOGOUT BUTTON ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

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
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFCC1F1F),
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.logout, color: Colors.white, size: 18),
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

// ─── MES PAIEMENTS ───────────────────────────────────────────────────────────

Widget MesPaiement() {
  return Center(child: Text("Mes Paiements"));
}
