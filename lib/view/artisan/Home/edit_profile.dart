import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navbottom.dart' ;
import 'package:my_app/viewmodels/artisan_view_model.dart';

// ─── EDIT PROFILE SCREEN ─────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          _HeaderCard(
            selectedTab: _selectedTab,
            onTabChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(
            child: _tabBody(_selectedTab),
          ),
        ],
      ),
    );
  }

  Widget _tabBody(int tab) {
    switch (tab) {
      case 1:
        return const _PreferencesBody();
      case 2:
        return const _SecurityBody();
      default:
        return const _InformationsBody();
    }
  }
}

// ─── HEADER CARD + TABS ───────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _HeaderCard({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [

                      Row( 
children:  [

                         IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
       Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeShell()),
    );
    },
  ),
                      Text(
                        'Mes informations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
]
                      ),

                      SizedBox(height: 6),
                      Text(
                        'Gorem ipsum dolor sit amet, consectetur\nadipiscing elit.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.manage_accounts_outlined,
                    color: Color(0xFFF5601A),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Row(
            children: [
              _Tab(
                label: 'Informations personnelles',
                selected: selectedTab == 0,
                onTap: () => onTabChanged(0),
              ),
              _Tab(
                label: 'Préférences',
                selected: selectedTab == 1,
                onTap: () => onTabChanged(1),
              ),
              _Tab(
                label: 'Sécurité',
                selected: selectedTab == 2,
                onTap: () => onTabChanged(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFF5601A) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFFF5601A) : const Color(0xFF999999),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── INFORMATIONS BODY ────────────────────────────────────────────────────────

class _InformationsBody extends StatefulWidget {
  const _InformationsBody();

  @override
  State<_InformationsBody> createState() => _InformationsBodyState();
}

class _InformationsBodyState extends State<_InformationsBody> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _dobCtrl     = TextEditingController();
  final _villeCtrl   = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _codeCtrl    = TextEditingController();

  bool _loaded = false;

  /// Fetches user data from API once and fills all controllers.
  Future<void> _loadUserData() async {
    if (_loaded) return;
    _loaded = true;

    final vm = context.read<ArtisanViewModel>();
    final data = await vm.me(); // returns Map<String, dynamic>?
    if (data == null || !mounted) return;

    _nameCtrl.text    = data['name']?.toString()          ?? '';
    _emailCtrl.text   = data['email']?.toString()         ?? '';
    _phoneCtrl.text   = data['phone']?.toString()         ?? '';
    _dobCtrl.text     = data['date_of_birth']?.toString() ?? '';
    _villeCtrl.text   = data['ville']?.toString()         ?? '';
    _adresseCtrl.text = data['address']?.toString()       ?? '';
    _codeCtrl.text    = data['zip_code']?.toString()      ?? '';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Load after first frame so context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _villeCtrl.dispose();
    _adresseCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                _ModifierButton(onTap: _saveChanges),
              ],
            ),
            const SizedBox(height: 20),
            _FloatingField(
              label: 'Nom complet',
              controller: _nameCtrl,
              icon: Icons.person_outline,
            ),
            _FloatingField(
              label: 'Adresse email',
              controller: _emailCtrl,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            _FloatingField(
              label: 'Téléphone',
              controller: _phoneCtrl,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _FloatingField(
              label: 'Date de naissance',
              controller: _dobCtrl,
              icon: Icons.calendar_today_outlined,
            ),
            _FloatingField(
              label: 'Ville',
              controller: _villeCtrl,
              icon: Icons.location_on_outlined,
            ),
            _FloatingField(
              label: 'Adresse',
              controller: _adresseCtrl,
              icon: Icons.home_outlined,
            ),
            _FloatingField(
              label: 'Code postale',
              controller: _codeCtrl,
              icon: Icons.local_post_office_outlined,
              keyboardType: TextInputType.number,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

Future<void> _saveChanges() async {
  final vm = context.read<ArtisanViewModel>();

  // Affiche un loader pendant la requête
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final success = await vm.updateUser(
    name: _nameCtrl.text,
    email: _emailCtrl.text,
    phone: _phoneCtrl.text,
    ville: _villeCtrl.text,
    dateOfBirth: _dobCtrl.text,
  );

  if (!mounted) return;
  Navigator.of(context).pop(); // ferme le loader

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? 'Profil mis à jour avec succès' : 'Erreur lors de la mise à jour',
      ),
      backgroundColor: success ? const Color(0xFFF5601A) : Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
}

// ─── FLOATING LABEL FIELD ─────────────────────────────────────────────────────

class _FloatingField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isLast;

  const _FloatingField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isLast = false,
  });

  @override
  State<_FloatingField> createState() => _FloatingFieldState();
}

class _FloatingFieldState extends State<_FloatingField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFF5601A);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: color.withOpacity(_focused ? 1.0 : 0.55),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.circle, color: color, size: 0), // placeholder spacing
                Icon(widget.icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    keyboardType: widget.keyboardType,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Positioned(
            top: -9,
            left: 44,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MODIFIER BUTTON ─────────────────────────────────────────────────────────

class _ModifierButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ModifierButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF5601A),
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text(
              'Modifier',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PLACEHOLDER TABS ────────────────────────────────────────────────────────


class _PreferencesBody extends StatefulWidget {
  const _PreferencesBody();

  @override
  State<_PreferencesBody> createState() => _PreferencesBodyState();
}

class _PreferencesBodyState extends State<_PreferencesBody> {
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  String _selectedLanguage = 'Français';

  static const Color _orange = Color(0xFFE8541A);
  static const Color _orangeLight = Color(0xFFFFF0EA);
  static const Color _borderActive = Color(0xFFE8541A);
  static const Color _borderInactive = Color(0xFFE0E0E0);
  static const Color _subtitleColor = Color(0xFF9E9E9E);
  static const Color _textColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 28),

          // Email Notifications Toggle
          _buildToggleCard(
            label: 'email',
            icon: Icons.mail_outline_rounded,
            title: 'Notifications par email',
            subtitle: 'Recevoir des notifications sur les nouvelles demandes',
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
          ),
          const SizedBox(height: 10),

          // SMS Notifications Toggle
          _buildToggleCard(
            label: 'téléphone',
            icon: Icons.smartphone_rounded,
            title: 'Notifications par SMS',
            subtitle: 'Recevoir des SMS pour les mises à jour importantes',
            value: _smsNotifications,
            onChanged: (val) => setState(() => _smsNotifications = val),
          ),
          const SizedBox(height: 10),

          // Language Selector
          _buildLanguageCard(),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required String label,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final bool isActive = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive ? _orangeLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? _borderActive : _borderInactive,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isActive ? _orange : const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isActive ? _textColor : const Color(0xFF555555),
                      ),
                    ),
                  ),
                  _buildCheckbox(isActive, onChanged),
                ],
              ),
            ),

            // Floating label
            Positioned(
              top: -11,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Subtitle
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 6),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: _subtitleColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? _orange : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: value ? _orange : const Color(0xFFBDBDBD),
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 15, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildLanguageCard() {
    final List<String> languages = [
      'Français',
      'English',
      'العربية',
      'Español',
      'Deutsch',
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dropdown Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderActive,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: _orange, size: 24),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
              items: languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Row(
                    children: [
                      const Icon(Icons.translate_rounded,
                          size: 20, color: _orange),
                      const SizedBox(width: 12),
                      Text(lang),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Floating label
        Positioned(
          top: -11,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Langue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityBody extends StatefulWidget {
  const _SecurityBody();

  @override
  State<_SecurityBody> createState() => _SecurityBodyState();
}

class _SecurityBodyState extends State<_SecurityBody> {
  bool _twoFactorEnabled = false;

  static const Color _orange = Color(0xFFE8541A);
  static const Color _orangeLight = Color(0xFFFFF0EA);
  static const Color _borderColor = Color(0xFFE0E0E0);
  static const Color _subtitleColor = Color(0xFF9E9E9E);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _red = Color(0xFFD32F2F);
  static const Color _redLight = Color(0xFFFFF0F0);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sécurité',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),

          // Password Row
          _buildActionCard(
            icon: Icons.password_rounded,
            title: 'Mode de passe',
            subtitle: 'Changez votre mot de passe régulièrement',
            trailing: _buildOrangeButton('Modifier', onTap: () {}),
          ),
          const SizedBox(height: 20),

          // 2FA Row
          _buildActionCard(
            icon: Icons.key_rounded,
            title: 'Authentification à deux facteurs',
            subtitle: 'Sécurisez votre compte avec la 2FA',
            trailing: _buildToggleSwitch(),
          ),
          const SizedBox(height: 20),

          // Payment Methods Row
          _buildActionCard(
            icon: Icons.credit_card_rounded,
            title: 'Moyens de paiement',
            subtitle: 'Gérez vos cartes bancaires',
            trailing: _buildOrangeButton('Gérer', onTap: () {}),
          ),

          const SizedBox(height: 32),

          // Delete Account Card
          _buildDeleteAccountCard(),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: _orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 6),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: _subtitleColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrangeButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _orange,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return GestureDetector(
      onTap: () => setState(() => _twoFactorEnabled = !_twoFactorEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          color: _twoFactorEnabled ? _orange : const Color(0xFFD0D0D0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment:
              _twoFactorEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard() {
    return Container(
      decoration: BoxDecoration(
        color: _redLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Supprimer mon compte',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _red,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cette action est irréversible',
                  style: TextStyle(
                    fontSize: 12,
                    color: _red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteConfirmation(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF555555))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}