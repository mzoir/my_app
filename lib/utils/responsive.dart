import 'package:flutter/widgets.dart';

/// Drop-in replacement for your existing Responsive class.
/// Initialize once in your root widget — no more LayoutBuilder needed.
///
/// Usage in main.dart / App root:
///   Responsive.init(context);   // call inside build(), after MaterialApp
///
/// Or wrap your MaterialApp with ResponsiveInit:
///   ResponsiveInit(child: MaterialApp(...))
///
/// Then anywhere in your code:
///   double R(double v) => Responsive.s(v);   // same shorthand as before
///   Responsive.s(16)                          // direct call
///   Responsive.w(0.5)                         // 50% of screen width
///   Responsive.h(0.1)                         // 10% of screen height
///   Responsive.sp(14)                         // font size scaling
///   Responsive.isSmall                        // phone < 360px wide
///   Responsive.isMedium                       // phone 360–414px
///   Responsive.isLarge                        // phone / small tablet > 414px
///   Responsive.isTablet                       // tablet >= 600px

class Responsive {
  // ── Figma design canvas ───────────────────────────────────────────────────
  static const double _figmaW = 393.0;
  static const double _figmaH = 852.0;

  // ── Device info (set once) ────────────────────────────────────────────────
  static double _screenW = _figmaW;
  static double _screenH = _figmaH;
  static double _scale   = 1.0;
  static double _fontScale = 1.0;

  // ─────────────────────────────────────────────────────────────────────────
  /// Call this ONCE in your root widget's build method, before anything else.
  /// e.g. inside MaterialApp's builder:
  ///   builder: (context, child) {
  ///     Responsive.init(context);
  ///     return child!;
  ///   }
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _screenW = mq.size.width;
    _screenH = mq.size.height;

    final sx = _screenW / _figmaW;
    final sy = _screenH / _figmaH;

    // Use the smaller axis so nothing ever overflows
    _scale = sx < sy ? sx : sy;

    // Font scale: use width ratio but clamp so text never gets too big/small
    _fontScale = (_screenW / _figmaW).clamp(0.75, 1.35);
  }

  /// Legacy support: keep working with LayoutBuilder if you prefer
  static void initFromConstraints(BoxConstraints c) {
    final sx = c.maxWidth  / _figmaW;
    final sy = c.maxHeight / _figmaH;
    _scale     = sx < sy ? sx : sy;
    _screenW   = c.maxWidth;
    _screenH   = c.maxHeight;
    _fontScale = (_screenW / _figmaW).clamp(0.75, 1.35);
  }

  // ── Core scaling ──────────────────────────────────────────────────────────

  /// Scale any dp value from Figma → current device. Same as before: R(v)
  static double s(double v) => v * _scale;

  /// Scale a font size (uses width-based scale with clamp for readability)
  static double sp(double v) => v * _fontScale;

  /// Fraction of screen WIDTH  — e.g. w(0.5) = half the screen
  static double w(double fraction) => _screenW * fraction;

  /// Fraction of screen HEIGHT — e.g. h(0.1) = 10% of screen height
  static double h(double fraction) => _screenH * fraction;

  // ── Breakpoints ───────────────────────────────────────────────────────────
  static bool get isSmall   => _screenW < 360;
  static bool get isMedium  => _screenW >= 360 && _screenW < 414;
  static bool get isLarge   => _screenW >= 414 && _screenW < 600;
  static bool get isTablet  => _screenW >= 600;

  // ── Raw values (useful for min/max guards) ────────────────────────────────
  static double get screenWidth  => _screenW;
  static double get screenHeight => _screenH;
  static double get scale        => _scale;
}

// ─────────────────────────────────────────────────────────────────────────────
/// Optional convenience widget — wrap your MaterialApp with this so
/// Responsive.init() is called automatically on every rebuild / orientation change.
///
/// Example:
///   void main() => runApp(const MyApp());
///
///   class MyApp extends StatelessWidget {
///     const MyApp({super.key});
///     @override
///     Widget build(BuildContext context) {
///       return MaterialApp(
///         builder: (context, child) {
///           Responsive.init(context);   // ← one line, done
///           return child!;
///         },
///         home: const HomeScreen(),
///       );
///     }
///   }
class ResponsiveInit extends StatelessWidget {
  final Widget child;
  const ResponsiveInit({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return child;
  }
}