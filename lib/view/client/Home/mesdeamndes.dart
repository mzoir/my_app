import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/service_request.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import "navbottom.dart";

class MesDemandesScreen extends StatefulWidget {
  const MesDemandesScreen({super.key});

  @override
  State<MesDemandesScreen> createState() => _MesDemandesScreenState();
}

// ✅ ADDED AutomaticKeepAliveClientMixin
class _MesDemandesScreenState extends State<MesDemandesScreen>
    with AutomaticKeepAliveClientMixin {
  // ✅ ADDED
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientViewModel>().fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ ADDED (IMPORTANT)

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: const AtlasAppBar(),
      body: const MesDemandesBody(),
    );
  }
}
// ─── CUSTOM APP BAR ──────────────────────────────────────────────────────────

class AtlasAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AtlasAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5601A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                      _AppBarIconBtn(
                        icon: Icons.calendar_today_outlined,
                        onTap: () {
                          final shell = context
                              .findAncestorStateOfType<HomeShellCState>();
                          shell?.setIndex(6); // → AgendaPage
                        },
                      ),

                      SizedBox(width: 10),

                      _AppBarIconBtn(
                        icon: Icons.notifications_outlined,
                        onTap: () {
                          final shell = context
                              .findAncestorStateOfType<HomeShellCState>();
                          shell?.openNotifications();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search,
                      color: Color(0xFFBBBBBB),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Quelle service recherchez-vous ?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 16,
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

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        iconSize: 15.0,
        icon: Icon(icon),
        color: Colors.white,
        onPressed: onTap,
      ),
    );
  }
}

// ─── BODY ─────────────────────────────────────────────────────────────────────

class MesDemandesBody extends StatelessWidget {
  const MesDemandesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth > 600 ? 32.0 : 16.0;
    final vm = context.watch<ClientViewModel>();

    return RefreshIndicator(
      color: const Color(0xFFF5601A),
      onRefresh: () => vm.fetchRequests(),
      child: SingleChildScrollView(
        key: const PageStorageKey('mes_demandes_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          hPad,
          28,
          hPad,
          MediaQuery.of(context).padding.bottom + 24,
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDE3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset("images/tt.png"),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Gorem ipsum dolor sit amet, consectetur adipiscing elit.',
              style: TextStyle(
                fontSize: 13,
                color: Color.fromRGBO(73, 73, 73, 1),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // ── Loading state ──
            if (vm.loading && vm.requests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: Color(0xFFF5601A)),
                ),
              )
            // ── Error state ──
            else if (vm.error != null && vm.requests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFCCCCCC),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        vm.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => vm.fetchRequests(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5601A),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'Réessayer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // ── Empty state ──
            else if (vm.requests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Color(0xFFCCCCCC),
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Aucune demande pour l\'instant.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // ── Cards ──
            else
              ...vm.requests.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DemandeCard(request: request),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── CARD ─────────────────────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  final ServiceRequest request;
  const _DemandeCard({required this.request});

  static const Map<String, IconData> _icons = {
    'Plomberie': Icons.water_drop_outlined,
    'Électricité': Icons.bolt,
    'Peinture': Icons.format_paint_outlined,
    'Nettoyage': Icons.cleaning_services_outlined,
    'Déménagement': Icons.inventory_2_outlined,
    'Photographie': Icons.photo_camera_outlined,
    'Vidéographie': Icons.videocam_outlined,
    'Beauté & Style': Icons.favorite_border,
    'Services de Restauration': Icons.restaurant_outlined,
    'Réparations générales': Icons.build_outlined,
    'Électroménager': Icons.kitchen_outlined,
    'Mécanicien Mobile': Icons.car_repair_outlined,
    'Assistance Routière': Icons.directions_car_outlined,
    'Réparation Ordinateurs': Icons.laptop_outlined,
    'Réseau & WiFi': Icons.wifi_outlined,
    'Support Technique': Icons.headset_mic_outlined,
  };

  static const Map<String, Color> _colors = {
    'Plomberie': Color(0xFF2196F3),
    'Électricité': Color(0xFFFFC107),
    'Peinture': Color(0xFF9C27B0),
    'Nettoyage': Color(0xFF00BCD4),
    'Déménagement': Color(0xFF673AB7),
    'Photographie': Color(0xFFCDDC39),
    'Vidéographie': Color(0xFF2196F3),
    'Beauté & Style': Color(0xFFE91E63),
    'Services de Restauration': Color(0xFF43A047),
    'Réparations générales': Color(0xFFE91E63),
    'Électroménager': Color(0xFFE91E63),
    'Mécanicien Mobile': Color(0xFF37474F),
    'Assistance Routière': Color(0xFF9C27B0),
    'Réparation Ordinateurs': Color(0xFFFF9800),
    'Réseau & WiFi': Color(0xFFE91E63),
    'Support Technique': Color(0xFF6D4C41),
  };

  Color get _iconBg => _colors[request.serviceName] ?? const Color(0xFFF5601A);
  IconData get _icon => _icons[request.serviceName] ?? Icons.build_outlined;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Supprimer la demande',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${request.serviceName ?? 'cette demande'}" ?',
          style: const TextStyle(color: Color(0xFF666666)),
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
              'Supprimer',
              style: TextStyle(
                color: Color(0xFFF5601A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final vm = context.read<ClientViewModel>();
      final success = await vm.deleteRequest(request.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Demande supprimée.'
                  : vm.error ?? 'Erreur lors de la suppression.',
            ),
            backgroundColor: success ? const Color(0xFFF5601A) : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 87,
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
      child: Center(
        child: Row(
          children: [
            // Category icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),

            // Title + responses + avatars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${request.responsesCount} réponse${request.responsesCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (request.responsesCount > 0)
                    buildStackedAvatars(
                      List.generate(
                        request.responsesCount.clamp(0, 3),
                        (i) => 'https://i.pravatar.cc/100?img=${i + 1}',
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        request.serviceName ?? 'Service',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(49, 65, 88, 1),
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Delete button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(231, 229, 206, 162),
                    ),
                    child: Image.asset("images/Vector.png"),
                  ),
                ),
                const SizedBox(height: 9),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildStackedAvatars(List<String> imageUrls) {
  const double avatarSize = 32.0;
  const double overlap = 10.0;

  return SizedBox(
    width: avatarSize + (imageUrls.length - 1) * (avatarSize - overlap),
    height: avatarSize,
    child: Stack(
      children: List.generate(imageUrls.length, (index) {
        return Positioned(
          left: index * (avatarSize - overlap),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundImage: NetworkImage(imageUrls[index]),
            ),
          ),
        );
      }),
    ),
  );
}
