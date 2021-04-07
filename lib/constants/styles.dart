///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 18:30
///
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import '../extensions/build_context_extension.dart';
import '../extensions/size_extension.dart';

BorderSide dividerBS(BuildContext c) {
  return BorderSide(
    width: 1.w,
    color: c.theme.dividerColor,
  );
}

class RadiusConstants {
  const RadiusConstants._();

  static BorderRadius get r1 => BorderRadius.circular(1.w);

  static BorderRadius get r2 => BorderRadius.circular(2.w);

  static BorderRadius get r3 => BorderRadius.circular(3.w);

  static BorderRadius get r4 => BorderRadius.circular(4.w);

  static BorderRadius get r5 => BorderRadius.circular(5.w);

  static BorderRadius get r6 => BorderRadius.circular(6.w);

  static BorderRadius get r8 => BorderRadius.circular(8.w);

  static BorderRadius get r9 => BorderRadius.circular(9.w);

  static BorderRadius get r10 => BorderRadius.circular(10.w);

  static BorderRadius get r12 => BorderRadius.circular(12.w);

  static BorderRadius get r15 => BorderRadius.circular(15.w);

  static BorderRadius get r18 => BorderRadius.circular(18.w);

  static BorderRadius get r20 => BorderRadius.circular(20.w);

  static BorderRadius get r25 => BorderRadius.circular(25.w);
  static const BorderRadius max = BorderRadius.all(Radius.circular(999999));
}
