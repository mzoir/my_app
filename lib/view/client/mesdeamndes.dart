import 'package:flutter/material.dart';


class MesDemandesScreen extends StatelessWidget {
  const MesDemandesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: const MesDemandesBody(),
    );
  }
}

// ─── DATA MODEL ──────────────────────────────────────────────────────────────

class DemandeItem {
  final String title;
  final IconData icon;
  final Color iconBg;
  final int reponses;
  final List<Color> avatarColors;
  final int extraCount;

  const DemandeItem({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.reponses,
    required this.avatarColors,
    this.extraCount = 0,
  });
}

const List<DemandeItem> _demandes = [
  DemandeItem(
    title: 'Plomberie',
    icon: Icons.water_drop_outlined,
    iconBg: Color(0xFF2196F3),
    reponses: 3,
    avatarColors: [Color(0xFF90CAF9), Color(0xFF64B5F6), Color(0xFF9575CD)],
  ),
  DemandeItem(
    title: 'Électricité',
    icon: Icons.bolt,
    iconBg: Color(0xFFFFC107),
    reponses: 2,
    avatarColors: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
  ),
  DemandeItem(
    title: 'Services de\nRestauration',
    icon: Icons.restaurant,
    iconBg: Color(0xFF43A047),
    reponses: 5,
    avatarColors: [Color(0xFFA5D6A7), Color(0xFF81C784), Color(0xFFCE93D8)],
    extraCount: 2,
  ),
  DemandeItem(
    title: 'Beauté &\nStyle',
    icon: Icons.favorite_border,
    iconBg: Color(0xFFE91E63),
    reponses: 5,
    avatarColors: [Color(0xFFF48FB1), Color(0xFFF06292), Color(0xFFCE93D8)],
    extraCount: 2,
  ),
];

// ─── BODY ─────────────────────────────────────────────────────────────────────

class MesDemandesBody extends StatelessWidget {
  const MesDemandesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        20,
        horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes demandes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDE3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  color: Color(0xFFF5601A),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Gorem ipsum dolor sit amet, consectetur\nadipiscing elit.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── Cards ──
          ...List.generate(_demandes.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DemandeCard(item: _demandes[i]),
            );
          }),
        ],
      ),
    );
  }
}

// ─── CARD ─────────────────────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  final DemandeItem item;
  const _DemandeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                height: 1.35,
              ),
            ),
          ),

          // Réponses + avatars
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.reponses} réponses',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 6),
              _AvatarStack(
                colors: item.avatarColors,
                extraCount: item.extraCount,
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Delete button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDE3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Color(0xFFF5601A),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AVATAR STACK ─────────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  final List<Color> colors;
  final int extraCount;

  const _AvatarStack({required this.colors, this.extraCount = 0});

  @override
  Widget build(BuildContext context) {
    const double size = 26;
    const double overlap = 8;

    final items = [...colors];
    final total = items.length + (extraCount > 0 ? 1 : 0);
    final totalWidth = size + (total - 1) * (size - overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          ...List.generate(items.length, (i) {
            return Positioned(
              left: i * (size - overlap),
              child: _Avatar(color: items[i], size: size),
            );
          }),
          if (extraCount > 0)
            Positioned(
              left: items.length * (size - overlap),
              child: _ExtraAvatar(count: extraCount, size: size),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Color color;
  final double size;

  const _Avatar({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _ExtraAvatar extends StatelessWidget {
  final int count;
  final double size;

  const _ExtraAvatar({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF4F4F4),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
