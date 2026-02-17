import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:my_app/view/core/app_colors.dart';
import 'plan.dart';

// =====================================================
// FLOW
// =====================================================

enum AuthStep {
  verify,
  otpEmail,
  otpPhone,
  artisanInfo,
  artisanPortfolio,
  securePassword,
}

enum VerifyTarget { email, phone }

class AuthFlowPage extends StatefulWidget {
  final String nom;
  final String birth;
  final String email;
  final String phone;

  const AuthFlowPage({
    super.key,
    required this.nom,
    required this.birth,
    required this.email,
    required this.phone,
  });

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  AuthStep step = AuthStep.verify;

  // ✅ choose only one
  VerifyTarget target = VerifyTarget.email;

  // otp
  final otp0 = TextEditingController();
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();

  // password
  final pass1 = TextEditingController();
  final pass2 = TextEditingController();

  // artisan info
  final servicePrincipalCtrl = TextEditingController(); // UI only
  final newServiceCtrl = TextEditingController(); // Type de service input
  final villeCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();
  final diplomeCtrl = TextEditingController(); // UI only

  // chips list
  final List<String> serviceTags = [];

  // portfolio
  final descriptionCtrl = TextEditingController();
  File? diplomeFile;
  List<File> images = [];

  // IDs backend
  List<int> selectedServiceIds = [];
  int? servicePrincipalId;

  // API
  String? tempId;
  String? finalToken;

  bool isLoading = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    otp0.dispose();
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();

    pass1.dispose();
    pass2.dispose();

    servicePrincipalCtrl.dispose();
    newServiceCtrl.dispose();
    villeCtrl.dispose();
    adresseCtrl.dispose();
    diplomeCtrl.dispose();

    descriptionCtrl.dispose();
    super.dispose();
  }

  void _resetOtp() {
    otp0.text = "";
    otp1.text = "";
    otp2.text = "";
    otp3.text = "";
  }

  String _baseUrl() {
    const port = "8000";
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:$port/api";
    return "http://127.0.0.1:$port/api";
  }

  void _setLoading(bool v) => setState(() => isLoading = v);

  String _otpValue() => "${otp0.text}${otp1.text}${otp2.text}${otp3.text}".trim();

  String _extractMessage(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map && j["message"] is String) return j["message"];
      if (j is Map && j["errors"] is Map) {
        final errors = j["errors"] as Map;
        final k = errors.keys.first;
        final v = errors[k];
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  Future<void> _pickDiplome() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    setState(() => diplomeFile = File(x.path));
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() => images.addAll(picked.map((e) => File(e.path))));
  }

  // ✅ PRECEDENT logic
  void _prev() {
    setState(() {
      switch (step) {
        case AuthStep.verify:
          break;

        case AuthStep.otpEmail:
        case AuthStep.otpPhone:
          step = AuthStep.verify;
          break;

        case AuthStep.artisanInfo:
          step = (target == VerifyTarget.email) ? AuthStep.otpEmail : AuthStep.otpPhone;
          break;

        case AuthStep.artisanPortfolio:
          step = AuthStep.artisanInfo;
          break;

        case AuthStep.securePassword:
          step = AuthStep.artisanPortfolio;
          break;
      }
    });
  }

  Future<void> _next() async {
    try {
      _setLoading(true);

      // 1) START
      if (step == AuthStep.verify) {
        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/start"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "nom_complet": widget.nom,
            "email": widget.email,
            "phone": widget.phone,
            "date_of_birth": "2002-01-03",
          }),
        );

        if (res.statusCode != 201) throw Exception(_extractMessage(res.body));

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        tempId = data["temp_id"]?.toString();

        if (tempId == null || tempId!.isEmpty) {
          throw Exception("temp_id non reçu depuis le backend.");
        }

        _resetOtp();

        setState(() {
          step = (target == VerifyTarget.email) ? AuthStep.otpEmail : AuthStep.otpPhone;
        });
        return;
      }

      // 2) VERIFY EMAIL
      if (step == AuthStep.otpEmail) {
        final code = _otpValue();
        if (code.length < 4) throw Exception("Entrez un code valide.");

        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/verify-email"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"temp_id": tempId, "code": code}),
        );

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        _resetOtp();

        setState(() {
          // if started with email => verify phone next, else go info
          step = AuthStep.artisanInfo;
        });
        return;
      }

      // 3) VERIFY PHONE
      if (step == AuthStep.otpPhone) {
        final code = _otpValue();
        if (code.length < 4) throw Exception("Entrez un code valide.");

        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/verify-phone"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"temp_id": tempId, "code": code}),
        );

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        _resetOtp();

        setState(() {
          // if started with phone => verify email next, else go info
          step =  AuthStep.artisanInfo;
        });
        return;
      }

      // 4) artisan info -> portfolio
      if (step == AuthStep.artisanInfo) {
        setState(() => step = AuthStep.artisanPortfolio);
        return;
      }

      // 5) complete profile multipart
      if (step == AuthStep.artisanPortfolio) {
        if (tempId == null) throw Exception("temp_id manquant.");

        final req = http.MultipartRequest(
          "POST",
          Uri.parse("${_baseUrl()}/register/artisan/complete-profile"),
        );

        req.headers["Accept"] = "application/json";
        req.fields["temp_id"] = tempId!;

        if (villeCtrl.text.trim().isNotEmpty) req.fields["ville"] = villeCtrl.text.trim();
        if (adresseCtrl.text.trim().isNotEmpty) req.fields["adresse"] = adresseCtrl.text.trim();
        if (diplomeCtrl.text.trim().isNotEmpty) req.fields["diplome"] = diplomeCtrl.text.trim();
        if (descriptionCtrl.text.trim().isNotEmpty) req.fields["description"] = descriptionCtrl.text.trim();

        if (newServiceCtrl.text.trim().isNotEmpty) req.fields["new_service_name"] = newServiceCtrl.text.trim();
        if (servicePrincipalId != null) req.fields["service_principal_id"] = servicePrincipalId.toString();
        if (selectedServiceIds.isNotEmpty) req.fields["service_ids"] = jsonEncode(selectedServiceIds);

        final streamed = await req.send();
        final res = await http.Response.fromStream(streamed);

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        setState(() => step = AuthStep.securePassword);
        return;
      }

      // 6) set password
      if (step == AuthStep.securePassword) {
        if (pass1.text.trim().isEmpty || pass2.text.trim().isEmpty) {
          throw Exception("Mot de passe requis.");
        }
        if (pass1.text.trim() != pass2.text.trim()) {
          throw Exception("Les mots de passe ne correspondent pas.");
        }

        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/set-password"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "temp_id": tempId,
            "password": pass1.text.trim(),
            "password_confirmation": pass2.text.trim(),
          }),
        );

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        finalToken = data["token"]?.toString();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionPlans()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception:", "").trim())),
      );
    } finally {
      _setLoading(false);
    }
  }

  String _title() {
    switch (step) {
      case AuthStep.verify:
        return "Vérification du compte";
      case AuthStep.artisanInfo:
      case AuthStep.artisanPortfolio:
        return "Créer votre compte";
      case AuthStep.securePassword:
        return "Sécurisez votre compte";
      default:
        return "Entrez le code de vérification";
    }
  }

  String? _subtitle() {
    switch (step) {
      case AuthStep.artisanInfo:
        return "Informations professionnelles";
      case AuthStep.artisanPortfolio:
        return "Portfolio et description";
      default:
        return null;
    }
  }

  double _progress() {
    if (step == AuthStep.artisanInfo) return 0.60;
    if (step == AuthStep.artisanPortfolio) return 0.90;
    return 0.0;
  }

  Widget _content() {
    switch (step) {
      case AuthStep.verify:
        return VerifyWidget(
          email: widget.email,
          phone: widget.phone,
          target: target,
          onChange: (v) => setState(() => target = v),
        );

      case AuthStep.otpEmail:
        return OtpWidget("Code envoyé par email", [otp0, otp1, otp2, otp3]);

      case AuthStep.otpPhone:
        return OtpWidget("Code envoyé par SMS", [otp0, otp1, otp2, otp3]);

      case AuthStep.artisanInfo:
        return ArtisanInfoStep(
          servicePrincipalCtrl: servicePrincipalCtrl,
          newServiceCtrl: newServiceCtrl,
          villeCtrl: villeCtrl,
          adresseCtrl: adresseCtrl,
          diplomeCtrl: diplomeCtrl,
          diplomeSelected: diplomeFile != null,
          tags: serviceTags,
          onAddTag: () {
            final v = newServiceCtrl.text.trim();
            if (v.isEmpty) return;
            setState(() {
              serviceTags.add(v);
              newServiceCtrl.clear();
            });
          },
          onRemoveTag: (t) => setState(() => serviceTags.remove(t)),
          onPickDiplome: _pickDiplome,
        );

      case AuthStep.artisanPortfolio:
        return ArtisanPortfolioStep(
          descriptionCtrl: descriptionCtrl,
          onPickImages: _pickImages,
          imagesCount: images.length,
        );

      case AuthStep.securePassword:
        return SecurePasswordWidget(pass1, pass2);
    }
  }

  // ✅ Buttons row like screenshot
  Widget _bottomButtons() {
    // Row only for artisanInfo & artisanPortfolio
    if (step == AuthStep.artisanInfo || step == AuthStep.artisanPortfolio) {
      final rightText = step == AuthStep.artisanInfo ? "Suivant" : "Confirmer";

      return Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
             
              decoration: BoxDecoration(
borderRadius: BorderRadius.circular(28),
 color:Colors.white,
              ),
              child: OutlinedButton(
                onPressed: isLoading ? null : _prev,
                style: OutlinedButton.styleFrom(
                  
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(
                  "Précédent",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _next,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        rightText,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      );
    }

    // Single button in other steps
    final txt = (step == AuthStep.securePassword) ? "Créer" : "Suivant";

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _next,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                txt,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3146, 1],
                  colors: [
                    Color.fromRGBO(255, 140, 91, 0),
                    Color.fromRGBO(255, 140, 91, 0.30),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: 393,
              height: 852,
              child: Stack(
                children: [
                  Positioned( 
                    top: 113,
                    left: 86,
                    child: SvgPicture.asset(
                      'images/Exclude.svg',
                      width: 220,
                      height: 51.29,
                    ),
                  ),

                  Positioned(
                    top: 203,
                    left: 62,
                    child: SizedBox(
                      width: 270,
                      child: Column(
                        children: [
                          Text(
                            _title(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (_subtitle() != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: 240,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _progress(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subtitle()!,
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // content
                  Positioned(
                    top: 330,
                    left: 39,
                    child: SizedBox(width: 314, child: _content()),
                  ),

                  // ✅ buttons row bottom
                  Positioned(
                    left: 39,
                    right: 39,
                    bottom: 78,
                    child: _bottomButtons(),
                  ),

                  Positioned(
                    bottom: 12,
                    left: 129,
                    child: SvgPicture.asset(
                      'images/HomeIndicator.svg',
                      width: 134,
                      height: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// WIDGETS
// =====================================================

class VerifyWidget extends StatelessWidget {
  final String email;
  final String phone;
  final VerifyTarget target;
  final ValueChanged<VerifyTarget> onChange;

  const VerifyWidget({
    super.key,
    required this.email,
    required this.phone,
    required this.target,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tile(
          selected: target == VerifyTarget.email,
          tag: "email",
          icon: Icons.email_outlined,
          text: email.isEmpty ? "email@gmail.com" : email,
          onTap: () => onChange(VerifyTarget.email),
        ),
        const SizedBox(height: 16),
        _tile(
          selected: target == VerifyTarget.phone,
          tag: "Téléphone",
          icon: Icons.phone_outlined,
          text: phone.isEmpty ? "06 xx xx xx xx" : phone,
          onTap: () => onChange(VerifyTarget.phone),
        ),
      ],
    );
  }

  Widget _tile({
    required bool selected,
    required String tag,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EB),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                    color: selected ? AppColors.primary : Colors.transparent,
                  ),
                  child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: Text(
                tag,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpWidget extends StatelessWidget {
  final String label;
  final List<TextEditingController> otp;

  const OtpWidget(this.label, this.otp, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: otp.map(_box).toList()),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 14),
        const Text(
          "Renvoyer",
          style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _box(TextEditingController c) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// =====================================================
// Artisan Info like screenshot
// =====================================================

class ArtisanInfoStep extends StatelessWidget {
  final TextEditingController servicePrincipalCtrl;
  final TextEditingController newServiceCtrl;
  final TextEditingController villeCtrl;
  final TextEditingController adresseCtrl;
  final TextEditingController diplomeCtrl;

  final bool diplomeSelected;

  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;

  final VoidCallback onPickDiplome;

  const ArtisanInfoStep({
    super.key,
    required this.servicePrincipalCtrl,
    required this.newServiceCtrl,
    required this.villeCtrl,
    required this.adresseCtrl,
    required this.diplomeCtrl,
    required this.diplomeSelected,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onPickDiplome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pill(
          controller: servicePrincipalCtrl,
          hint: "Service principal",
          icon: Icons.handyman_outlined,
          readOnly: false,
          right: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
        ),
        const SizedBox(height: 14),

        _pill(
          controller: newServiceCtrl,
          hint: "Type de service",
          icon: Icons.grid_view_rounded,
          rightWidget: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onAddTag,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Text("Ajouter", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        if (tags.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: tags.map((t) {
                return InkWell(
                  onTap: () => onRemoveTag(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary),
                      color: const Color(0xFFFFF1EB),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        if (tags.isNotEmpty) const SizedBox(height: 14),

        _pill(controller: villeCtrl, hint: "Ville", icon: Icons.location_on_outlined),
        const SizedBox(height: 14),

        _pill(
          controller: adresseCtrl,
          hint: "Adresse",
          icon: Icons.home_outlined,
          rightWidget: Container(
            width: 64,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(height: 14),

        _pill(
          controller: diplomeCtrl,
          hint: diplomeSelected ? "Diplôme sélectionné" : "Scannez le diplôme",
          icon: Icons.crop_free_rounded,
          readOnly: true,
          onTap: onPickDiplome,
          rightWidget: SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onPickDiplome,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Text("Scanner", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? right,
    Widget? rightWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EB),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (rightWidget != null) rightWidget,
            if (rightWidget == null && right != null) right,
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Portfolio like screenshot
// =====================================================

class ArtisanPortfolioStep extends StatefulWidget {
  final TextEditingController descriptionCtrl;
  final VoidCallback onPickImages;
  final int imagesCount;

  const ArtisanPortfolioStep({
    super.key,
    required this.descriptionCtrl,
    required this.onPickImages,
    required this.imagesCount,
  });

  @override
  State<ArtisanPortfolioStep> createState() => _ArtisanPortfolioStepState();
}

class _ArtisanPortfolioStepState extends State<ArtisanPortfolioStep> {
  bool accepted = true;

  @override
  void initState() {
    super.initState();
    widget.descriptionCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.descriptionCtrl.text.length.clamp(0, 250);

    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 120,
              child: TextField(
                controller: widget.descriptionCtrl,
                maxLines: null,
                maxLength: 250,
                decoration: InputDecoration(
                  hintText: "Décrivez votre expérience...",
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xFFFFF7F3),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 6,
              child: Text("$count/250 caractères", style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: widget.onPickImages,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
              color: const Color(0xFFFFF7F3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(color: Color(0xFFFFE6DC), shape: BoxShape.circle),
                  child: const Icon(Icons.upload_rounded, color: AppColors.primary, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  "Cliquez pour télécharger vos images",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark),
                ),
                if (widget.imagesCount > 0) ...[
                  const SizedBox(height: 6),
                  Text("Images sélectionnées: ${widget.imagesCount}",
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: accepted,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => accepted = v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "J'accepte les conditions générales d'utilisation et la politique de confidentialité",
                style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SecurePasswordWidget extends StatefulWidget {
  final TextEditingController pass1;
  final TextEditingController pass2;

  const SecurePasswordWidget(this.pass1, this.pass2, {super.key});

  @override
  State<SecurePasswordWidget> createState() => _SecurePasswordWidgetState();
}

class _SecurePasswordWidgetState extends State<SecurePasswordWidget> {
  bool show1 = false;
  bool show2 = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field("Créer un mot de passe", widget.pass1, show1, () => setState(() => show1 = !show1)),
        const SizedBox(height: 14),
        _field("Confirmer le mot de passe", widget.pass2, show2, () => setState(() => show2 = !show2)),
      ],
    );
  }

  Widget _field(String hint, TextEditingController c, bool show, VoidCallback toggle) {
    return TextField(
      controller: c,
      obscureText: !show,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(onPressed: toggle, icon: Icon(show ? Icons.visibility : Icons.visibility_off)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
