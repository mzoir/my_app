import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/client_view_model.dart';



class NewDemandeFlow extends StatefulWidget {
  const NewDemandeFlow({super.key});

  @override
  State<NewDemandeFlow> createState() => _NewDemandeFlowState();
}

class _NewDemandeFlowState extends State<NewDemandeFlow>
    with AutomaticKeepAliveClientMixin {

  // ✅ ADDED
  @override
  bool get wantKeepAlive => true;

  int _step = 0; // 0 = choose service, 1 = choose type, 2 = details

  String? _selectedService;
  final List<String> _selectedTypes = [];

  void _goNext() => setState(() => _step = (_step + 1).clamp(0, 2));
  void _goPrev() => setState(() => _step = (_step - 1).clamp(0, 2));

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ ADDED (IMPORTANT)

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AtlasAppBar(withSearch: _step == 0 || _step == 2),
      body: Column(
        children: [
          SizedBox(height: 10,),
          _StepProgressBar(currentStep: _step, totalSteps: 3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _step == 0
                    ? ChooseServiceScreen(
                        key: const ValueKey(0),
                        onSelected: (s) {
                          setState(() => _selectedService = s);
                          _goNext();
                        },
                      )
                    : _step == 1
                        ? ChooseTypeScreen(
                            key: const ValueKey(1),
                            serviceName: _selectedService ?? 'Réparations générales',
                            selectedTypes: _selectedTypes,
                            onToggle: (t) => setState(() {
                              _selectedTypes.contains(t)
                                  ? _selectedTypes.remove(t)
                                  : _selectedTypes.add(t);
                            }),
                            onPrev: _goPrev,
                            onNext: _goNext,
                          )
                        : DemandeDetailsScreen(
                            key: const ValueKey(2),
                            selectedService: _selectedService ?? '',
                            selectedTypes: List.unmodifiable(_selectedTypes),
                            onPrev: _goPrev,
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ─── STEP PROGRESS BAR ────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final gap = 6.0;
    final segW = (w - (totalSteps - 1) * gap) / totalSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final active = i <= currentStep;
          return Container(
            width: segW,
            height: 4,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? gap : 0),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFF5601A)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — CHOOSE SERVICE
// ═══════════════════════════════════════════════════════════════════════════════

class ChooseServiceScreen extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const ChooseServiceScreen({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth > 600 ? 32.0 : 16.0;
    final crossCount = screenWidth > 600 ? 4 : 3;

    return SingleChildScrollView(
       key: const PageStorageKey('choose_type_scroll'),
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisissez un service',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sélectionnez le service dont vous avez besoin',
            style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: crossCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: _services.map((s) {
              return _ServiceTile(service: s, onTap: () => onSelected(s.name));
            }).toList(),
          ),
            SizedBox(height: 30,),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _Service service;
  final VoidCallback onTap;

  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF5601A).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: service.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(service.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                service.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 2 — CHOOSE TYPE
// ═══════════════════════════════════════════════════════════════════════════════

class ChooseTypeScreen extends StatelessWidget {
  final String serviceName;
  final List<String> selectedTypes;
  final ValueChanged<String> onToggle;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const ChooseTypeScreen({
    super.key,
    required this.serviceName,
    required this.selectedTypes,
    required this.onToggle,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth > 600 ? 32.0 : 20.0;
    final types = _serviceTypes[serviceName] ?? _defaultTypes;
    final canContinue = selectedTypes.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const PageStorageKey('choose_service_scroll'),
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Icon(Icons.build_outlined,
                        color: Color(0xFFF5601A), size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choisissez un type de service',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sélectionnez le type de service dont vous avez besoin',
                  style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
                const SizedBox(height: 20),
                ...types.map((t) {
                  final selected = selectedTypes.contains(t);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => onToggle(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFF5601A)
                                : const Color(0xFFEEEEEE),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? const Color(0xFFF5601A)
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFFF5601A)
                                      : const Color(0xFFCCCCCC),
                                  width: 1.5,
                                ),
                                color: selected
                                    ? const Color(0xFFF5601A)
                                    : Colors.transparent,
                              ),
                              child: selected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
          child: Row(
            children: [
              // Précédent
              GestureDetector(
                onTap: onPrev,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFF5601A)),
                  ),
                  child: const Center(
                    child: Text(
                      'Précédent',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF5601A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Continuer
              Expanded(
                child: GestureDetector(
                  onTap: canContinue ? onNext : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: canContinue
                          ? const Color(0xFFF5601A)
                          : const Color(0xFFF5601A).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 15,
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
          SizedBox(height: 30,),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 3 — DEMANDE DETAILS
// ═══════════════════════════════════════════════════════════════════════════════

class DemandeDetailsScreen extends StatefulWidget {
  final VoidCallback onPrev;
  final String selectedService;
  final List<String> selectedTypes;

  const DemandeDetailsScreen({
    super.key,
    required this.onPrev,
    required this.selectedService,
    required this.selectedTypes,
  });

  @override
  State<DemandeDetailsScreen> createState() => _DemandeDetailsScreenState();
}

class _DemandeDetailsScreenState extends State<DemandeDetailsScreen> {
  final _descController = TextEditingController();
  final _villeController = TextEditingController();
  final _adresseController = TextEditingController();
  final _infoController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _villeController.dispose();
    _adresseController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _descController.text.trim().isNotEmpty &&
      _villeController.text.trim().isNotEmpty &&
      _adresseController.text.trim().isNotEmpty;

  Future<void> _submit(BuildContext context) async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir la description, la ville et l\'adresse.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<ClientViewModel>();

    final success = await auth.createRequest(
      serviceName: widget.selectedService,
      serviceType: widget.selectedTypes.join(', '),
      description: _descController.text.trim(),
      ville: _villeController.text.trim(),
      address: _adresseController.text.trim(),
      additionalInfo: _infoController.text.trim().isEmpty
          ? null
          : _infoController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande publiée avec succès !'),
          backgroundColor: Color(0xFFF5601A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Une erreur est survenue.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth > 600 ? 32.0 : 20.0;
    final auth = context.watch<ClientViewModel>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
             key: const PageStorageKey('choose_type_scroll'),
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Détails de votre demande',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fournissez les informations nécessaires pour que\nles artisans puissent vous faire une offre précise',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF999999), height: 1.5),
                ),
                const SizedBox(height: 24),

                // Description
                _SectionLabel(
                    icon: Icons.description_outlined,
                    label: 'Description du travail'),
                const SizedBox(height: 8),
                _TextAreaField(
                  controller: _descController,
                  hint: 'Décrivez en détail le travail à réaliser...',
                  maxLength: 250,
                  minLines: 4,
                ),
                const SizedBox(height: 16),

                // Ville
                _OutlineInputField(
                  controller: _villeController,
                  hint: 'ville',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),

                // Adresse
                _AddressField(controller: _adresseController),
                const SizedBox(height: 20),

                // Informations complémentaires
                _SectionLabel(
                    icon: Icons.info_outline,
                    label: 'Informations complémentaires'),
                const SizedBox(height: 8),
                _TextAreaField(
                  controller: _infoController,
                  hint: 'Ajoutez des informations (accès, contraintes,\nhoraires préférés...)',
                  minLines: 3,
                ),
                const SizedBox(height: 20),

                // Photos
                _SectionLabel(
                    icon: Icons.camera_alt_outlined,
                    label: 'Photos (optionnel)'),
                const SizedBox(height: 8),
                _PhotoUploadBox(),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: auth.loading ? null : widget.onPrev,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFF5601A)),
                  ),
                  child: const Center(
                    child: Text(
                      'Précédent',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF5601A),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: auth.loading ? null : () => _submit(context),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: auth.loading
                          ? const Color(0xFFF5601A).withOpacity(0.6)
                          : const Color(0xFFF5601A),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: auth.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Publier la demande',
                              style: TextStyle(
                                fontSize: 15,
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
        SizedBox(height: 30,),
      ],
    );
  }
}

// ─── DETAIL SCREEN WIDGETS ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF5601A), size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _TextAreaField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final int minLines;

  const _TextAreaField({
    required this.controller,
    required this.hint,
    this.maxLength,
    this.minLines = 3,
  });

  @override
  State<_TextAreaField> createState() => _TextAreaFieldState();
}

class _TextAreaFieldState extends State<_TextAreaField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5601A).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: widget.controller,
            maxLines: null,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                null,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                  fontSize: 13, color: Color(0xFFBBBBBB), height: 1.5),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
          ),
          if (widget.maxLength != null)
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Text(
                '${widget.controller.text.length}/${widget.maxLength} caractères',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFFBBBBBB)),
              ),
            ),
        ],
      ),
    );
  }
}

class _OutlineInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;

  const _OutlineInputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFF5601A).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(prefixIcon, color: const Color(0xFFF5601A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;

  const _AddressField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFF5601A).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.home_outlined, color: Color(0xFFF5601A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Adresse',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF5601A),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5601A).withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDE3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.upload_rounded,
                color: Color(0xFFF5601A), size: 26),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ajouter des photos',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SHARED: APP BAR ──────────────────────────────────────────────────────────

class AtlasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool withSearch;
  const AtlasAppBar({super.key, this.withSearch = true});

  @override
  Size get preferredSize =>
      Size.fromHeight(withSearch ? 120 : 80);

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
                            horizontal: 8, vertical: 3),
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
              if (withSearch) ...[
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
                      const Icon(Icons.search,
                          color: Color(0xFFBBBBBB), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Quelle service recherchez-vous ?',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFFBBBBBB)),
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
                        child: const Icon(Icons.tune,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
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



// ─── DATA ─────────────────────────────────────────────────────────────────────

class _Service {
  final String name;
  final IconData icon;
  final Color bgColor;
  const _Service(this.name, this.icon, this.bgColor);
}

const List<_Service> _services = [
  _Service('Réparations générales', Icons.build_outlined, Color.fromARGB(255, 238, 11, 11)),
  _Service('Plomberie', Icons.water_drop_outlined, Color.fromARGB(255, 4, 91, 221)),
  _Service('Électricité', Icons.bolt, Color.fromARGB(255, 202, 164, 48)),
  _Service('Peinture', Icons.format_paint_outlined, Color.fromARGB(255, 182, 27, 209)),
  _Service('Électroménager', Icons.kitchen_outlined, Color(0xFFE91E63)),
  _Service('Nettoyage', Icons.cleaning_services_outlined, Color(0xFF00BCD4)),
  _Service('Déménagement', Icons.inventory_2_outlined, Color(0xFF673AB7)),
  _Service('Chauffage, Ventilation et Climatisation', Icons.ac_unit_outlined, Color(0xFFFF5722)),
  _Service('Mécanicien Mobile', Icons.car_repair_outlined, Color(0xFF37474F)),
  _Service('Vidange Mobile', Icons.oil_barrel_outlined, Color(0xFF8BC34A)),
  _Service('Assistance Routière', Icons.directions_car_outlined, Color(0xFF9C27B0)),
  _Service("Organisation d'événements", Icons.event_outlined, Color(0xFF009688)),
  _Service('Photographie', Icons.photo_camera_outlined, Color(0xFFCDDC39)),
  _Service('Vidéographie', Icons.videocam_outlined, Color(0xFF2196F3)),
  _Service('Musique & Animation', Icons.music_note_outlined, Color(0xFFE91E63)),
  _Service('Beauté & Style', Icons.favorite_border, Color(0xFFE91E63)),
  _Service('Services de Restauration', Icons.restaurant_outlined, Color(0xFF43A047)),
  _Service("Décoration d'Événements", Icons.celebration_outlined, Color(0xFF9C27B0)),
  _Service('Location de Matériel', Icons.handyman_outlined, Color(0xFF26C6DA)),
  _Service('Réparation Ordinateurs', Icons.laptop_outlined, Color(0xFFFF9800)),
  _Service('Réseau & WiFi', Icons.wifi_outlined, Color(0xFFE91E63)),
  _Service('Maison Connectée', Icons.home_outlined, Color(0xFF1565C0)),
  _Service('Support Technique', Icons.headset_mic_outlined, Color(0xFF6D4C41)),
  _Service('Réparation Téléphones & Tablettes', Icons.phone_android_outlined, Color(0xFFE91E63)),
];

const Map<String, List<String>> _serviceTypes = {
  'Réparations générales': [
    'Montage TV, étagères, tringles',
    'Réparation portes & serrures',
    'Petites menuiseries',
    'Joints & silicone',
  ],
  'Plomberie': [
    'Fuite d\'eau',
    'Débouchage canalisation',
    'Installation robinetterie',
    'Chauffe-eau',
  ],
  'Électricité': [
    'Prise & interrupteur',
    'Tableau électrique',
    'Éclairage',
    'Câblage réseau',
  ],
};

const List<String> _defaultTypes = [
  'Option A',
  'Option B',
  'Option C',
  'Option D',
];