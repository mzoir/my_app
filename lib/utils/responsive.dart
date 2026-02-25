import 'package:flutter/widgets.dart';

class Responsive {
  static late double _scale;

  static void init(BoxConstraints c) {
    const figmaW = 393.0;
    const figmaH = 852.0;

    final sx = c.maxWidth / figmaW;
    final sy = c.maxHeight / figmaH;

    _scale = sx < sy ? sx : sy;
  }

  static double s(double v) => v * _scale;
}
