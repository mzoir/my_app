// auth_flow_page.dart (FULL) ✅ Web + Mobile (universal_html + image_picker)
// Uses ArtisanViewModel for ALL API calls (start/verify/complete-profile/set-password)
// Also supports picking Diplome + Images on Web + Mobile.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:my_app/view/core/app_colors.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/viewmodels/artisan_view_model.dart';
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
  VerifyTarget target = VerifyTarget.email;

  final otp0 = TextEditingController();
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();

  final pass1 = TextEditingController();
  final pass2 = TextEditingController();

  final servicePrincipalCtrl = TextEditingController();
  final newServiceCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();
  final diplomeCtrl = TextEditingController();

  final List<String> serviceTags = [];
  final descriptionCtrl = TextEditingController();

  // ✅ Mobile files (dart:io)
  File? diplomeFile;
  List<File> images = [];

  // ✅ Web files (html.File)
  html.File? diplomeFileWeb;
  List<html.File> webImages = [];

  List<int> selectedServiceIds = [];
  int? servicePrincipalId;

  String? tempId;
  String? finalToken;

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

  String _otpValue() =>
      "${otp0.text}${otp1.text}${otp2.text}${otp3.text}".trim();

  // =====================================================
  // WEB PICKERS
  // =====================================================

  Future<List<html.File>> _pickWebImages() async {
    final input = html.FileUploadInputElement()
      ..multiple = true
      ..accept = "image/*";
    input.click();
    await input.onChange.first;
    return input.files ?? <html.File>[];
  }

  Future<html.File?> _pickWebDiplome() async {
    final input = html.FileUploadInputElement()
      ..accept = "image/*,application/pdf";
    input.click();
    await input.onChange.first;
    final files = input.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  // =====================================================
  // UNIVERSAL PICKERS (WEB + MOBILE)
  // =====================================================

  Future<void> _pickDiplomeUniversal() async {
    if (kIsWeb) {
      final f = await _pickWebDiplome();
      if (f == null) return;
      setState(() {
        diplomeFileWeb = f;
        diplomeCtrl.text = f.name;
      });
    } else {
      final x = await _picker.pickImage(source: ImageSource.gallery);
      if (x == null) return;
      setState(() {
        diplomeFile = File(x.path);
        diplomeCtrl.text = x.name;
      });
    }
  }

  Future<void> _pickImagesUniversal() async {
    if (kIsWeb) {
      final list = await _pickWebImages();
      if (list.isEmpty) return;
      setState(() => webImages.addAll(list));
    } else {
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;
      setState(() => images.addAll(picked.map((e) => File(e.path))));
    }
  }

  // =====================================================
  // NAV
  // =====================================================

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
          step = (target == VerifyTarget.email)
              ? AuthStep.otpEmail
              : AuthStep.otpPhone;
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

  // =====================================================
  // NEXT (ALL CALLS THROUGH ArtisanViewModel)
  // =====================================================

  Future<void> _next() async {
    final vm = context.read<ArtisanViewModel>();

    try {
      // 1) START
      if (step == AuthStep.verify) {
        final ok = await vm.start(
          name: widget.nom,
          email: widget.email,
          phone: widget.phone,
          birth: widget.birth.trim(),
        );
        if (!ok) throw Exception(vm.error ?? "Erreur");
        tempId = vm.tempId;
        _resetOtp();
        setState(() {
          step = (target == VerifyTarget.email)
              ? AuthStep.otpEmail
              : AuthStep.otpPhone;
        });
        return;
      }

      // 2) VERIFY EMAIL
      if (step == AuthStep.otpEmail) {
        final code = _otpValue();
        if (code.length < 4) throw Exception("Entrez un code valide.");
        final ok = await vm.verifyEmail(code);
        if (!ok) throw Exception(vm.error ?? "Erreur");
        _resetOtp();
        setState(() => step = AuthStep.artisanInfo);
        return;
      }

      // 3) VERIFY PHONE
      if (step == AuthStep.otpPhone) {
        final code = _otpValue();
        if (code.length < 4) throw Exception("Entrez un code valide.");
        final ok = await vm.verifyPhone(code);
        if (!ok) throw Exception(vm.error ?? "Erreur");
        _resetOtp();
        setState(() => step = AuthStep.artisanInfo);
        return;
      }

      // 4) artisan info -> portfolio
      if (step == AuthStep.artisanInfo) {
        setState(() => step = AuthStep.artisanPortfolio);
        return;
      }

      // 5) complete profile multipart (web + mobile)
      if (step == AuthStep.artisanPortfolio) {
        final ok = await vm.completeProfile(
          ville: villeCtrl.text.trim(),
          adresse: adresseCtrl.text.trim(),
          diplome: diplomeCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          newService: newServiceCtrl.text.trim().isEmpty
              ? null
              : newServiceCtrl.text.trim(),
          servicePrincipalId: servicePrincipalId,
          serviceIds: selectedServiceIds,
          diplomeFile: kIsWeb ? null : diplomeFile,
          images: kIsWeb ? null : images,
          diplomeFileWeb: kIsWeb ? diplomeFileWeb : null,
          imagesWeb: kIsWeb ? webImages : null,
        );
        if (!ok) throw Exception(vm.error ?? "Erreur");
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
        final ok = await vm.setPassword(
          password: pass1.text.trim(),
          confirmPassword: pass2.text.trim(),
        );
        if (!ok) throw Exception(vm.error ?? "Erreur");
        finalToken = vm.token;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionPlans()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '').trim()),
        ),
      );
    }
  }

  // =====================================================
  // UI HELPERS
  // =====================================================

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

  Widget _content(double R(double v), double sidePadding) {
    final vm = context.watch<ArtisanViewModel>();
    final pickedDiplome = kIsWeb ? diplomeFileWeb != null : diplomeFile != null;
    final imgCount = kIsWeb ? webImages.length : images.length;

    switch (step) {
      case AuthStep.verify:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: VerifyWidget(
            email: widget.email,
            phone: widget.phone,
            target: target,
            onChange: (v) => setState(() => target = v),
          ),
        );

      case AuthStep.otpEmail:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: OtpWidget(
            label: "Code envoyé par email",
            otp: [otp0, otp1, otp2, otp3],
            onResend: vm.loading
                ? null
                : () async {
                    final ok = await vm.resendEmailOtp();
                    if (ok) _resetOtp();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.error ?? "Code renvoyé ✅")),
                    );
                  },
          ),
        );

      case AuthStep.otpPhone:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: OtpWidget(
            label: "Code envoyé par SMS",
            otp: [otp0, otp1, otp2, otp3],
            onResend: vm.loading
                ? null
                : () async {
                    final ok = await vm.resendPhoneOtp();
                    if (ok) _resetOtp();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.error ?? "Code renvoyé ✅")),
                    );
                  },
          ),
        );

      case AuthStep.artisanInfo:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: ArtisanInfoStep(
            servicePrincipalCtrl: servicePrincipalCtrl,
            newServiceCtrl: newServiceCtrl,
            villeCtrl: villeCtrl,
            adresseCtrl: adresseCtrl,
            diplomeCtrl: diplomeCtrl,
            diplomeSelected: pickedDiplome,
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
            onPickDiplome: _pickDiplomeUniversal,
          ),
        );

      case AuthStep.artisanPortfolio:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: ArtisanPortfolioStep(
            descriptionCtrl: descriptionCtrl,
            onPickImages: _pickImagesUniversal,
            imagesCount: imgCount,
          ),
        );

      case AuthStep.securePassword:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: SecurePasswordWidget(pass1, pass2),
        );
    }
  }

  Widget _bottomButtons(
      ArtisanViewModel vm, double R(double v), double btnW) {
    // Verify + OTP + Password → single centered button
    if (step == AuthStep.verify ||
        step == AuthStep.otpEmail ||
        step == AuthStep.otpPhone ||
        step == AuthStep.securePassword) {
      final label = step == AuthStep.securePassword ? "Créer" : "Suivant";
      return Center(
        child: SizedBox(
          width: btnW,
          height: R(48),
          child: ElevatedButton(
            onPressed: vm.loading ? null : _next,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R(28)),
              ),
            ),
            child: vm.loading
                ? SizedBox(
                    width: R(18),
                    height: R(18),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: R(14),
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    }

    // Info + Portfolio → two buttons (Précédent / Suivant|Confirmer)
    final rightText =
        step == AuthStep.artisanInfo ? "Suivant" : "Confirmer";
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: R(48),
            child: OutlinedButton(
              onPressed: vm.loading ? null : _prev,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(28)),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                "Précédent",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: R(14),
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: R(16)),
        Expanded(
          child: SizedBox(
            height: R(48),
            child: ElevatedButton(
              onPressed: vm.loading ? null : _next,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(28)),
                ),
              ),
              child: vm.loading
                  ? SizedBox(
                      width: R(18),
                      height: R(18),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      rightText,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: R(14),
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ArtisanViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adaptive side padding (same pattern as client version)
    final double sidePadding = screenWidth < 400 ? 16 : 32;

    // Button width: 70% of screen (single button), full minus padding for 2-btn row
    final double btnW = screenWidth * 0.7;
    final double twoBtnW = screenWidth - (sidePadding * 2);

    Responsive.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight));
    double R(double v) => Responsive.s(v);

    final bool hasTwoButtons =
        step == AuthStep.artisanInfo || step == AuthStep.artisanPortfolio;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3146, 1.0],
            colors: [
              Color.fromRGBO(255, 140, 91, 0.0),
              Color.fromRGBO(255, 140, 91, 0.30),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  SvgPicture.asset(
                    'images/Exclude.svg',
                    width: R(220),
                    height: R(51.29),
                    fit: BoxFit.contain,
                  ),

                  const Spacer(flex: 1),

                  // Title
                  Text(
                    _title(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: R(24),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),

                  // Progress bar + subtitle (only for artisanInfo / artisanPortfolio)
                  if (_subtitle() != null) ...[
                    SizedBox(height: R(10)),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: sidePadding),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(R(100)),
                        child: LinearProgressIndicator(
                          value: _progress(),
                          minHeight: R(6),
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: R(8)),
                    Text(
                      _subtitle()!,
                      style: GoogleFonts.poppins(
                        fontSize: R(14),
                        color: AppColors.textDark,
                      ),
                    ),
                  ],

                  const Spacer(flex: 1),

                  // Step content
                  SizedBox(
                    width: double.infinity,
                    child: _content(R, sidePadding),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: SizedBox(
                      width: hasTwoButtons ? twoBtnW : btnW,
                      child: _bottomButtons(vm, R, btnW),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Home indicator
                  SvgPicture.asset(
                    'images/HomeIndicator.svg',
                    width: R(134),
                    height: R(5),
                    fit: BoxFit.contain,
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
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
    double R(double v) => Responsive.s(v);

    return Column(
      children: [
        _tile(
          selected: target == VerifyTarget.email,
          tag: "email",
          icon: Icons.email_outlined,
          text: email.isEmpty ? "email@gmail.com" : email,
          onTap: () => onChange(VerifyTarget.email),
          R: R,
        ),
        SizedBox(height: R(16)),
        _tile(
          selected: target == VerifyTarget.phone,
          tag: "Téléphone",
          icon: Icons.phone_outlined,
          text: phone.isEmpty ? "06 xx xx xx xx" : phone,
          onTap: () => onChange(VerifyTarget.phone),
          R: R,
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
    required double Function(double) R,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R(30)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: R(52),
            padding: EdgeInsets.symmetric(horizontal: R(16)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EB),
              borderRadius: BorderRadius.circular(R(30)),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: R(18)),
                SizedBox(width: R(10)),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: R(13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Container(
                  width: R(20),
                  height: R(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(R(4)),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                    color: selected ? AppColors.primary : Colors.transparent,
                  ),
                  child: selected
                      ? Icon(Icons.check, size: R(14), color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
          Positioned(
            left: R(18),
            top: -R(8),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R(10), vertical: R(2)),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(R(16)),
              ),
              child: Text(
                tag,
                style: GoogleFonts.poppins(
                  fontSize: R(10),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// OTP
// =====================================================

class OtpWidget extends StatelessWidget {
  final String label;
  final List<TextEditingController> otp;
  final VoidCallback? onResend;

  const OtpWidget({
    super.key,
    required this.label,
    required this.otp,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: otp.map((c) => _box(c, R)).toList(),
        ),
        SizedBox(height: R(14)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: R(12)),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(R(28)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: R(12)),
          ),
        ),
        SizedBox(height: R(14)),
        TextButton(
          onPressed: onResend,
          child: Text(
            "Renvoyer",
            style: GoogleFonts.poppins(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
              fontSize: R(12),
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _box(TextEditingController c, double Function(double) R) {
    return Container(
      width: R(56),
      height: R(56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R(12)),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// =====================================================
// Artisan Info
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
    double R(double v) => Responsive.s(v);

    return Column(
      children: [
        _pill(
          controller: servicePrincipalCtrl,
          hint: "Service principal",
          icon: Icons.handyman_outlined,
          readOnly: false,
          right: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: R(20),
          ),
          R: R,
        ),
        SizedBox(height: R(14)),
        _pill(
          controller: newServiceCtrl,
          hint: "Type de service",
          icon: Icons.grid_view_rounded,
          rightWidget: SizedBox(
            height: R(36),
            child: ElevatedButton(
              onPressed: onAddTag,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(22)),
                ),
                padding: EdgeInsets.symmetric(horizontal: R(18)),
              ),
              child: Text(
                "Ajouter",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: R(12),
                ),
              ),
            ),
          ),
          R: R,
        ),
        SizedBox(height: R(10)),
        if (tags.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: R(10),
              runSpacing: R(8),
              children: tags.map((t) {
                return InkWell(
                  onTap: () => onRemoveTag(t),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R(12), vertical: R(6)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(R(18)),
                      border: Border.all(color: AppColors.primary),
                      color: const Color(0xFFFFF1EB),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.poppins(
                        fontSize: R(10),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (tags.isNotEmpty) SizedBox(height: R(14)),
        _pill(
          controller: villeCtrl,
          hint: "Ville",
          icon: Icons.location_on_outlined,
          R: R,
        ),
        SizedBox(height: R(14)),
        _pill(
          controller: adresseCtrl,
          hint: "Adresse",
          icon: Icons.home_outlined,
          rightWidget: Container(
            width: R(64),
            height: R(36),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(R(22)),
            ),
            child: Icon(
              Icons.gps_fixed_rounded,
              color: Colors.white,
              size: R(18),
            ),
          ),
          R: R,
        ),
        SizedBox(height: R(14)),
        _pill(
          controller: diplomeCtrl,
          hint: diplomeSelected ? "Diplôme sélectionné" : "Scannez le diplôme",
          icon: Icons.crop_free_rounded,
          readOnly: true,
          onTap: onPickDiplome,
          rightWidget: SizedBox(
            height: R(36),
            child: ElevatedButton(
              onPressed: onPickDiplome,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R(22)),
                ),
                padding: EdgeInsets.symmetric(horizontal: R(18)),
              ),
              child: Text(
                "Scanner",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: R(12),
                ),
              ),
            ),
          ),
          R: R,
        ),
      ],
    );
  }

  Widget _pill({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double Function(double) R,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? right,
    Widget? rightWidget,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R(30)),
      child: Container(
        height: R(48),
        padding: EdgeInsets.symmetric(horizontal: R(14)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EB),
          borderRadius: BorderRadius.circular(R(30)),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: R(18)),
            SizedBox(width: R(10)),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: R(13),
                    color: AppColors.textLight,
                  ),
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
// Portfolio
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
    double R(double v) => Responsive.s(v);
    final count = widget.descriptionCtrl.text.length.clamp(0, 250);

    return Column(
      children: [
        SizedBox(
          height: R(130),
          child: Stack(
            children: [
              Positioned.fill(
                child: TextField(
                  controller: widget.descriptionCtrl,
                  maxLines: null,
                  expands: true,
                  minLines: null,
                  maxLength: 250,
                  decoration: InputDecoration(
                    hintText: "Décrivez votre expérience...",
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFFFFF7F3),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R(20)),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R(20)),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(
                        R(16), R(14), R(16), R(34)),
                  ),
                ),
              ),
              Positioned(
                right: R(10),
                bottom: R(6),
                child: Text(
                  "$count/250 caractères",
                  style: GoogleFonts.poppins(
                    fontSize: R(10),
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: R(16)),
        InkWell(
          onTap: widget.onPickImages,
          borderRadius: BorderRadius.circular(R(20)),
          child: Container(
            height: R(128),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R(20)),
              border: Border.all(color: AppColors.primary),
              color: const Color(0xFFFFF7F3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: R(74),
                  height: R(74),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE6DC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.upload_rounded,
                    color: AppColors.primary,
                    size: R(30),
                  ),
                ),
                SizedBox(height: R(12)),
                Text(
                  "Cliquez pour télécharger vos images",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: R(12),
                    color: AppColors.textDark,
                  ),
                ),
                if (widget.imagesCount > 0) ...[
                  SizedBox(height: R(6)),
                  Text(
                    "Images sélectionnées: ${widget.imagesCount}",
                    style: GoogleFonts.poppins(
                      fontSize: R(11),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: R(14)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: R(22),
              height: R(22),
              child: Checkbox(
                value: accepted,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => accepted = v ?? false),
              ),
            ),
            SizedBox(width: R(10)),
            Expanded(
              child: Text(
                "J'accepte les conditions générales d'utilisation et la politique de confidentialité",
                style: GoogleFonts.poppins(
                  fontSize: R(10.5),
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================
// PASSWORD
// =====================================================

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
    double R(double v) => Responsive.s(v);

    return Column(
      children: [
        _field(
          "Créer un mot de passe",
          widget.pass1,
          show1,
          () => setState(() => show1 = !show1),
          R,
        ),
        SizedBox(height: R(14)),
        _field(
          "Confirmer le mot de passe",
          widget.pass2,
          show2,
          () => setState(() => show2 = !show2),
          R,
        ),
      ],
    );
  }

  Widget _field(
    String hint,
    TextEditingController c,
    bool show,
    VoidCallback toggle,
    double Function(double) R,
  ) {
    return SizedBox(
      height: R(48),
      child: TextField(
        controller: c,
        obscureText: !show,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: R(13)),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: R(18),
          ),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              show ? Icons.visibility : Icons.visibility_off,
              size: R(18),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(R(30)),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(R(30)),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}