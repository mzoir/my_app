import 'package:flutter/material.dart';
import 'package:my_app/utils/responsive.dart';
import 'send_message.dart';
import 'official.dart';
import 'mesmessages.dart';
import 'agenda.dart';
import 'demandesclient.dart';
import 'Artisan_profile.dart';

// ====================== HOME SHELL ======================

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> pages = const [
    HomePage(),
    AgendaPage(),
     ArtisanHomeScreen(),
    Mesmessages(),
    ProfileScreen(),
  ];

  SendMessage? openChat;

  void setIndex(int i) {
    setState(() => index = i);
  }

  void openChatPage(int userId, String userName, String? userPhoto) {
    setState(() {
      openChat = SendMessage(
        initialUserId: userId,
        initialUserName: userName,
        initialUserPhoto: userPhoto,
      );
    });
  }

  void closeChatPage() {
    setState(() {
      openChat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          bottomNavigationBar: BottomNav(current: index, onTap: setIndex),
          body: Stack(
            children: [
              PageStorage(
                bucket: _bucket,
                child: IndexedStack(index: index, children: pages),
              ),
              if (openChat != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.white,
                    child: Column(children: [Expanded(child: openChat!)]),
                  ),
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
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: const Color(0xFFF7F7F7),
      padding: EdgeInsets.only(
        bottom: bottom > 0 ? bottom : R(16),
        top: R(8),
        left: R(18),
        right: R(18),
      ),
      child: Container(
        height: R(64),
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
        padding: EdgeInsets.symmetric(horizontal: R(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              active: current == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.description_outlined,
              activeIcon: Icons.description_rounded,
              active: current == 1,
              onTap: () => onTap(1),
            ),
            _CenterButton(onTap: () => onTap(2), active: current == 2),
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              active: current == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              active: current == 4,
              onTap: () => onTap(4),
              isProfile: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;
  final bool isProfile;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: R(54),
        height: R(54),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? R(40) : R(36),
            height: active ? R(40) : R(36),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                active ? activeIcon : icon,
                size: R(22),
                color: active ? const Color(0xFF2D2F33) : Colors.white.withOpacity(0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;

  const _CenterButton({required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: R(54),
        height: R(54),
        decoration: BoxDecoration(
          color: active ? Colors.white : const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.handyman_rounded,
            color: active ? const Color(0xFFE84C1E) : const Color(0xFF2D2F33),
            size: R(24),
          ),
        ),
      ),
    );
  }
}