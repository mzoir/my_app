import 'package:flutter/material.dart';
import 'package:my_app/utils/responsive.dart';
import 'send_message.dart';
import 'official.dart';
import 'mesmessages.dart';
import 'mesdeamndes.dart';
import 'demande.dart';
import 'notify_aclient.dart';
import 'profileScreen.dart';
import 'agenda_client.dart';

// ====================== HOME SHELL ======================

class HomeShellC extends StatefulWidget {
  const HomeShellC({super.key});

  @override
  State<HomeShellC> createState() => HomeShellCState();
}

class HomeShellCState extends State<HomeShellC> {
  int index = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> pages = const [
    HomePage(),
    MesDemandesScreen(),
    NewDemandeFlow(),
    Mesmessages(),
    ProfileScreen(),
    NotificationsPage(), // 5
      AgendaPage(),         // 6 ← add
  ];

  /// Chat overlay
  SendMessage? openChat;

  void setIndex(int i) {
    setState(() => index = i);
  }
  void openNotifications() {
  setState(() => index = 5);
}
void openAgenda() {
  setState(() => index = 6);
}


  /// Open chat over current page
  void openChatPage(int userId, String userName, String? userPhoto) {
    setState(() {
      openChat = SendMessage(
        initialUserId: userId,
        initialUserName: userName,
        initialUserPhoto: userPhoto,
      );
    });
  }

  /// Close chat overlay
  void closeChatPage() {
    setState(() {
      openChat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        double R(double v) => Responsive.s(v);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: Stack(
            children: [
              // Main pages
              PageStorage(
                bucket: _bucket,
                child: IndexedStack(index: index, children: pages),
              ),

              // Chat overlay
              if (openChat != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.white,
                    child: Column(children: [Expanded(child: openChat!)]),
                  ),
                ),

              // Bottom nav
              Positioned(
                left: 0,
                right: 0,
                bottom: R(14),
                child: BottomNav(current: index, onTap: setIndex),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ====================== BOTTOM NAV ======================

class BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.current, required this.onTap});

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
