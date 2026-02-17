// ========================= auth_flow_page.dart =========================
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'planc.dart';
import 'package:my_app/viewmodels/client_view_model.dart';

enum AuthStep { verify, otpEmail, otpPhone, securePassword }

class AuthFlowPage extends StatefulWidget {
  final String tempId;
  final String email;
  final String phone;

  const AuthFlowPage({
    super.key,
    required this.tempId,
    required this.email,
    required this.phone,
  });

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;

  AuthStep step = AuthStep.verify;

  final otp0 = TextEditingController();
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();

  final pass1 = TextEditingController();
  final pass2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: widget.email);
    phoneCtrl = TextEditingController(text: widget.phone);

    // ✅ set tempId inside provider once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ClientViewModel>();
      vm.tempId = widget.tempId;
    });
  }

  void _resetOtp({bool putZero = false}) {
    final v = putZero ? "0" : "";
    otp0.text = v;
    otp1.text = v;
    otp2.text = v;
    otp3.text = v;
  }

  String _otpValue() => "${otp0.text}${otp1.text}${otp2.text}${otp3.text}";

  @override
  void dispose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    otp0.dispose();
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();
    pass1.dispose();
    pass2.dispose();
    super.dispose();
  }

  Widget _buildStepContent() {
    switch (step) {
      case AuthStep.verify:
        return VerifyWidget(emailCtrl: emailCtrl, phoneCtrl: phoneCtrl);

      case AuthStep.otpEmail:
        return OtpWidget(label: widget.email, otp: [otp0, otp1, otp2, otp3]);

      case AuthStep.otpPhone:
        return OtpWidget(label: widget.phone, otp: [otp0, otp1, otp2, otp3]);

      case AuthStep.securePassword:
        return SecurePasswordWidget(pass1: pass1, pass2: pass2);
    }
  }

  void _gologin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPlans()),
    );
  }

  Future<void> _onNext() async {
    final vm = context.read<ClientViewModel>();

    if (step == AuthStep.verify) {
      setState(() {
        step = AuthStep.otpEmail;
        _resetOtp(putZero: false);
      });
      return;
    }

    if (step == AuthStep.otpEmail) {
      final ok = await vm.verifyEmail(code: _otpValue());
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? "Erreur")),
        );
        return;
      }

      setState(() {
        step = AuthStep.otpPhone;
        _resetOtp(putZero: false); // ✅ clear otp boxes when switching
      });
      return;
    }

    if (step == AuthStep.otpPhone) {
      final ok = await vm.verifyPhone(code: _otpValue());
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? "Erreur")),
        );
        return;
      }

      setState(() {
        step = AuthStep.securePassword;
      });
      return;
    }

    if (step == AuthStep.securePassword) {
      final ok = await vm.setPassword(
        password: pass1.text,
        confirmPassword: pass2.text,
      );
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? "Erreur")),
        );
        return;
      }
      _gologin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientViewModel>();

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
                  stops: [0.3146, 1.0],
                  colors: [
                    Color.fromRGBO(255, 140, 91, 0.0),
                    Color.fromRGBO(255, 140, 91, 0.30),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
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
                        child: Text(
                          step == AuthStep.verify
                              ? "Vérification du compte"
                              : step == AuthStep.securePassword
                                  ? "Sécurisez votre compte"
                                  : "Entrez le code de vérification",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 38 / 24,
                            letterSpacing: -0.45,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 348,
                      left: 39,
                      child: SizedBox(width: 314, child: _buildStepContent()),
                    ),
                    Positioned(
                      top: 689,
                      left: 71,
                      child: SizedBox(
                        width: 251,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: vm.loading ? null : _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            step == AuthStep.securePassword ? "Créer" : "Suivant",
                            style: GoogleFonts.publicSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}

// ================= VERIFY =================

class VerifyWidget extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;

  const VerifyWidget({
    super.key,
    required this.emailCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field(emailCtrl.text, Icons.email_outlined),
        const SizedBox(height: 12),
        _field(phoneCtrl.text, Icons.phone_outlined),
      ],
    );
  }

  Widget _field(String value, IconData icon, {String? label}) {
    return Stack(
      children: [
        TextField(
          readOnly: true,
          decoration: authBoxDecoration(
            hint: value,
            prefix: Icon(icon, color: AppColors.primary, size: 18),
            suffix: const Icon(Icons.check_box_outline_blank, size: 18),
          ),
        ),
        if (label != null)
          Positioned(
            left: 18,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: const Color(0xFFFFF1EB),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ================= OTP =================

InputDecoration authBoxDecoration({
  required String hint,
  Widget? prefix,
  Widget? suffix,
  bool filled = true,
}) {
  return InputDecoration(
    border: InputBorder.none,
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
    filled: filled,
    fillColor: const Color(0xFFFFF1EB),
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}

class OtpWidget extends StatelessWidget {
  final String label;
  final List<TextEditingController> otp;

  const OtpWidget({super.key, required this.label, required this.otp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: otp.map(_box).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Renvoyer",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _box(TextEditingController c) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
      ),
    );
  }
}

// ================= PASSWORD =================

class SecurePasswordWidget extends StatefulWidget {
  final TextEditingController pass1;
  final TextEditingController pass2;

  const SecurePasswordWidget({
    super.key,
    required this.pass1,
    required this.pass2,
  });

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
        _field("Créer un mot de passe", show1, () => setState(() => show1 = !show1), widget.pass1),
        const SizedBox(height: 12),
        _field("Confirmer le mot de passe", show2, () => setState(() => show2 = !show2), widget.pass2),
      ],
    );
  }

  Widget _field(String hint, bool show, VoidCallback toggle, TextEditingController ctrl) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: ctrl,
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
      ),
    );
  }
}
