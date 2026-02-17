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

enum AuthStep {
  verify,         // START => /start returns temp_id
  otpEmail,       // /verify-email
  otpPhone,       // /verify-phone
  artisanInfo,    // fill info
  artisanPortfolio, // upload + desc
  securePassword, // /set-password returns token
}

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

  // otp
  final otp0 = TextEditingController();
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();

  // password
  final pass1 = TextEditingController();
  final pass2 = TextEditingController();

  // artisan info
  final servicePrincipalCtrl = TextEditingController();
  final newServiceCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();
  final diplomeCtrl = TextEditingController();

  // portfolio
  final descriptionCtrl = TextEditingController();
  File? diplomeFile;
  List<File> images = [];

  // IDs (if you have them later)
  List<int> selectedServiceIds = [];
  int? servicePrincipalId;

  // API state
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

  String _baseUrl() {
    const port = "8000";
    // Android emulator -> 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:$port/api";
    return "http://127.0.0.1:$port/api";
  }

  void _setLoading(bool v) {
    setState(() => isLoading = v);
  }

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

  Future<void> _next() async {
    try {
      _setLoading(true);

      // 1) START => temp_id
      if (step == AuthStep.verify) {
        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/start"),
          headers: {"Accept": "application/json", "Content-Type": "application/json"},
          body: jsonEncode({
            "nom_complet": widget.nom,
            "email": widget.email,
            "phone": widget.phone,
             "date_of_birth": widget.birth,
          }),
        );

        if (res.statusCode != 201) throw Exception(_extractMessage(res.body));

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        tempId = data["temp_id"]?.toString();
        if (tempId == null || tempId!.isEmpty) {
          throw Exception("temp_id non reçu depuis le backend.");
        }

        setState(() => step = AuthStep.otpEmail);
        return;
      }

      // 2) VERIFY EMAIL
      if (step == AuthStep.otpEmail) {
        final code = _otpValue();
        if (code.length < 4) throw Exception("Entrez un code valide.");

        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/verify-email"),
          headers: {"Accept": "application/json", "Content-Type": "application/json"},
          body: jsonEncode({"temp_id": tempId, "code": code}),
        );

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        setState(() => step = AuthStep.otpPhone);
        return;
      }

      // 3) VERIFY PHONE
      if (step == AuthStep.otpPhone) {
        final code = _otpValue();
        if (code.length < 4) throw Exception("Entrez un code valide.");

        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/verify-phone"),
          headers: {"Accept": "application/json", "Content-Type": "application/json"},
          body: jsonEncode({"temp_id": tempId, "code": code}),
        );

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        setState(() => step = AuthStep.artisanInfo);
        return;
      }

      // 4) artisan info -> next
      if (step == AuthStep.artisanInfo) {
        setState(() => step = AuthStep.artisanPortfolio);
        return;
      }

      // 5) COMPLETE PROFILE (multipart)
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

        if (newServiceCtrl.text.trim().isNotEmpty) {
          req.fields["new_service_name"] = newServiceCtrl.text.trim();
        }
        if (servicePrincipalId != null) {
          req.fields["service_principal_id"] = servicePrincipalId.toString();
        }
        if (selectedServiceIds.isNotEmpty) {
          req.fields["service_ids"] = jsonEncode(selectedServiceIds);
        }

        if (diplomeFile != null) {
          req.files.add(await http.MultipartFile.fromPath("diplome_file", diplomeFile!.path));
        }
        for (final img in images) {
          req.files.add(await http.MultipartFile.fromPath("images[]", img.path));
        }

        final streamed = await req.send();
        final res = await http.Response.fromStream(streamed);

        if (res.statusCode != 200) throw Exception(_extractMessage(res.body));

        setState(() => step = AuthStep.securePassword);
        return;
      }

      // 6) SET PASSWORD => token
      if (step == AuthStep.securePassword) {
        if (pass1.text.trim().isEmpty || pass2.text.trim().isEmpty) {
          throw Exception("Mot de passe requis.");
        }
        if (pass1.text.trim() != pass2.text.trim()) {
          throw Exception("Les mots de passe ne correspondent pas.");
        }

        final res = await http.post(
          Uri.parse("${_baseUrl()}/register/artisan/set-password"),
          headers: {"Accept": "application/json", "Content-Type": "application/json"},
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
        return;
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
        return "Créer votre compte";
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

  Widget _content() {
    switch (step) {
      case AuthStep.verify:
        return VerifyWidget(email: widget.email, phone: widget.phone);

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
          onPickDiplome: _pickDiplome,
          diplomeSelected: diplomeFile != null,
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

  @override
  Widget build(BuildContext context) {
    final btnText = step == AuthStep.securePassword
        ? "Créer"
        : step == AuthStep.artisanPortfolio
            ? "Confirmer"
            : "Suivant";

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
                                alignment: step == AuthStep.artisanInfo
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subtitle()!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 348,
                    left: 39,
                    child: SizedBox(width: 314, child: _content()),
                  ),
                  Positioned(
                    top: 689,
                    left: 71,
                    child: SizedBox(
                      width: 251,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _next,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                btnText,
                                style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 837,
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

// ====================== WIDGETS ======================

class VerifyWidget extends StatelessWidget {
  final String email;
  final String phone;

  const VerifyWidget({super.key, required this.email, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _box(email, Icons.email_outlined, "email"),
        const SizedBox(height: 16),
        _box(phone, Icons.phone_outlined, "Téléphone"),
        const SizedBox(height: 10),
        const Text(
          "Cliquez sur Suivant pour recevoir les OTP.",
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _box(String text, IconData icon, String tag) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -8,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tag,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ),
      ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: otp.map(_box).toList(),
        ),
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
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
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
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class ArtisanInfoStep extends StatelessWidget {
  final TextEditingController servicePrincipalCtrl;
  final TextEditingController newServiceCtrl;
  final TextEditingController villeCtrl;
  final TextEditingController adresseCtrl;
  final TextEditingController diplomeCtrl;
  final VoidCallback onPickDiplome;
  final bool diplomeSelected;

  const ArtisanInfoStep({
    super.key,
    required this.servicePrincipalCtrl,
    required this.newServiceCtrl,
    required this.villeCtrl,
    required this.adresseCtrl,
    required this.diplomeCtrl,
    required this.onPickDiplome,
    required this.diplomeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _fieldCtrl("Service principal (optionnel)", Icons.handyman_outlined, servicePrincipalCtrl),
        const SizedBox(height: 14),
        _fieldCtrl("Nouveau service (optionnel)", Icons.build_outlined, newServiceCtrl),
        const SizedBox(height: 14),
        _fieldCtrl("Ville (optionnel)", Icons.location_on_outlined, villeCtrl),
        const SizedBox(height: 14),
        _fieldCtrl("Adresse (optionnel)", Icons.home_outlined, adresseCtrl),
        const SizedBox(height: 14),
        _fieldCtrl("Diplôme (texte optionnel)", Icons.school_outlined, diplomeCtrl),
        const SizedBox(height: 14),
        InkWell(
          onTap: onPickDiplome,
          child: Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.document_scanner_outlined, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    diplomeSelected ? "Diplôme sélectionné ✅" : "Scannez le diplôme (optionnel)",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text("Choisir", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldCtrl(String hint, IconData icon, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class ArtisanPortfolioStep extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: descriptionCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Décrivez votre expérience...",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onPickImages,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload, size: 40, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  imagesCount == 0
                      ? "Cliquez pour télécharger vos images"
                      : "Images sélectionnées: $imagesCount ✅",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
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
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(show ? Icons.visibility : Icons.visibility_off),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}