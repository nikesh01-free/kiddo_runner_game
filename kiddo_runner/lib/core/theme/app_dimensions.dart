import 'package:flutter/material.dart';

class AppSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s12 = 48;
}

class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double x2l = 24;
  static const double full = 999;
}

class AppShadows {
  static const List<BoxShadow> shadow1 = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
}
