import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/view/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'planc.dart';
import 'package:my_app/viewmodels/client_view_model.dart';
import 'package:my_app/utils/responsive.dart';

enum AuthStep { verify, otpEmail, otpPhone, securePassword }
enum VerifyChoice { email, phone }

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
   
  VerifyChoice choice = VerifyChoice.email;
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
        return VerifyWidget(
          emailCtrl: emailCtrl,
          phoneCtrl: phoneCtrl,
          choice: choice,
          onChoiceChanged: (v) => setState(() => choice = v),
        );
      case AuthStep.otpEmail:
        return OtpWidget(
          label: widget.email,
          otp: [otp0, otp1, otp2, otp3],
          onResend: () async {
            final vm = context.read<ClientViewModel>();
            await vm.resendEmailOtp();
            _resetOtp();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(vm.error ?? "Code renvoyé par email ✅")),
              );
            }
          },
        );
      case AuthStep.otpPhone:
        return OtpWidget(
          label: widget.phone,
          otp: [otp0, otp1, otp2, otp3],
          onResend: () async {
            final vm = context.read<ClientViewModel>();
            await vm.resendPhoneOtp();
            _resetOtp();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(vm.error ?? "Code renvoyé par SMS ✅")),
              );
            }
          },
        );
      case AuthStep.securePassword:
        return SecurePasswordWidget(pass1: pass1, pass2: pass2);
    }
  }

  void _goPlans() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SubscriptionPlans()),
    );
  }

  Future<void> _onNext() async {
    final vm = context.read<ClientViewModel>();

    if (step == AuthStep.verify) {
      setState(() {
        step = (choice == VerifyChoice.email)
            ? AuthStep.otpEmail
            : AuthStep.otpPhone;
        _resetOtp();
      });
      return;
    }

    if (step == AuthStep.otpEmail) {
      final ok = await vm.verifyEmail(code: _otpValue());
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? "Erreur")),
        );
        return;
      }
      setState(() => step = AuthStep.securePassword);
      return;
    }

    if (step == AuthStep.otpPhone) {
      final ok = await vm.verifyPhone(code: _otpValue());
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? "Erreur")),
        );
        return;
      }
      setState(() => step = AuthStep.securePassword);
      return;
    }

    if (step == AuthStep.securePassword) {
      final ok = await vm.setPassword(
        password: pass1.text,
        confirmPassword: pass2.text,
      );
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? "Erreur")),
        );
        return;
      }
      _goPlans();
    }
  }

  String _title() {
    return step == AuthStep.verify
        ? "Vérification du compte"
        : step == AuthStep.securePassword
            ? "Sécurisez votre compte"
            : "Entrez le code de vérification";
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientViewModel>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double sidePadding = screenWidth < 400 ? 16 : 32;

    Responsive.init(BoxConstraints(
      maxWidth: screenWidth,
      maxHeight: screenHeight,
    ));
    double R(double v) => Responsive.s(v);

    final contentW = screenWidth * 1;
    final btnW = screenWidth * 0.7;

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
                  Spacer(flex: 2),

                  // Logo
                  SvgPicture.asset(
                    'images/Exclude.svg',
                    width: R(220),
                    height: R(51.3),
                    fit: BoxFit.contain,
                  ),

                  Spacer(flex: 1),

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

                  Spacer(flex: 1),

                  // Step content
                  SizedBox(
                    width: contentW,
                    child: _buildStepContent(),
                  ),

                  Spacer(flex: 2),

                  // Button
                  SizedBox(
                    width: btnW,
                    height: R(44),
                    child: ElevatedButton(
                      onPressed: vm.loading ? null : _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R(28)),
                        ),
                      ),
                      child: Text(
                        step == AuthStep.securePassword ? "Créer" : "Suivant",
                        style: GoogleFonts.publicSans(
                          fontSize: R(15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Spacer(flex: 1),

                  // Home indicator
                  SvgPicture.asset(
                    'images/HomeIndicator.svg',
                    width: R(134),
                    height: R(5),
                    fit: BoxFit.contain,
                  ),

                  Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= VERIFY =================


class VerifyWidget extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final VerifyChoice choice;
  final ValueChanged<VerifyChoice> onChoiceChanged;

  const VerifyWidget({
    super.key,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.choice,
    required this.onChoiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);
    final screenWidth = MediaQuery.of(context).size.width;

    // padding adaptatif : petit sur mobile, plus large sur tablette/web
    double sidePadding = screenWidth < 400 ? 16 : 32;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: _selectableField(
            value: emailCtrl.text,
            icon: Icons.email_outlined,
            selected: choice == VerifyChoice.email,
            onTap: () => onChoiceChanged(VerifyChoice.email),
            R: R,
          ),
        ),
        SizedBox(height: R(12)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: _selectableField(
            value: phoneCtrl.text,
            icon: Icons.phone_outlined,
            selected: choice == VerifyChoice.phone,
            onTap: () => onChoiceChanged(VerifyChoice.phone),
            R: R,
          ),
        ),
        SizedBox(height: R(10)),
      ],
    );
  }

  Widget _selectableField({
    required String value,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required double Function(double) R,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(R(30)),
      onTap: onTap,
      child: TextField(
        readOnly: true,
        decoration: authBoxDecoration(
          hint: value,
          prefix: Icon(icon, color: AppColors.primary, size: R(18)),
          suffix: Icon(
            selected ? Icons.check_box : Icons.check_box_outline_blank,
            size: R(18),
            color: selected ? AppColors.primary : AppColors.textDark,
          ),
          R: R,
        ),
      ),
    );
  }
}


// ================= OTP decoration =================

InputDecoration authBoxDecoration({
  required String hint,
  Widget? prefix,
  Widget? suffix,
  bool filled = true,
  required double Function(double) R,
}) {
  return InputDecoration(
    border: InputBorder.none,
    hintText: hint,
    hintStyle: GoogleFonts.poppins(
      fontSize: R(14),
      fontWeight: FontWeight.w400,
      color: AppColors.blacker,
    ),
    filled: filled,
    fillColor: const Color(0xFFFFF1EB),
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: EdgeInsets.symmetric(horizontal: R(18), vertical: R(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(R(30)),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(R(30)),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}

class OtpWidget extends StatelessWidget {
  final String label;
  final List<TextEditingController> otp;
  final VoidCallback onResend;
  const OtpWidget({
    super.key,
    required this.label,
    required this.otp,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    double R(double v) => Responsive.s(v);
     final screenWidth = MediaQuery.of(context).size.width;

    // padding adaptatif : petit sur mobile, plus large sur tablette/web
    double sidePadding = screenWidth < 400 ? 16 : 32;

    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: otp.map((c) => _box(c, R)).toList(),
        ),),
        SizedBox(height: R(20)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child:
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
        ),),
        SizedBox(height: R(12)),
        TextButton(
          onPressed: () {
            onResend();
          },

          child: Text(
            "Renvoyer",
            style: GoogleFonts.poppins(
              fontSize: R(12),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
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
    double R(double v) => Responsive.s(v);

     final screenWidth = MediaQuery.of(context).size.width;

    // padding adaptatif : petit sur mobile, plus large sur tablette/web
    double sidePadding = screenWidth < 400 ? 16 : 32;
    return 
    Padding(
    padding: EdgeInsets.symmetric(horizontal: sidePadding),
    
    child:
    Column(      children: [
        _field(
          "Créer un mot de passe",
          show1,
          () => setState(() => show1 = !show1),
          widget.pass1,
          R,
        ),
        SizedBox(height: R(12)),
        _field(
          "Confirmer le mot de passe",
          show2,
          () => setState(() => show2 = !show2),
          widget.pass2,
          R,
        ),
      ],
    ),
    );
  }

  Widget _field(
    String hint,
    bool show,
    VoidCallback toggle,
    TextEditingController ctrl,
    double Function(double) R,
  ) {
    return SizedBox(
      height: R(48),
      child: Center(child:TextField(
        controller: ctrl,
        obscureText: !show,
        textAlign: TextAlign.center,
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      ),
    );
  }
}
