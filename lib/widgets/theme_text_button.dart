///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 18:04
///
import 'package:flutter/material.dart';

import '../constants/styles.dart';
import '../exports/extensions.dart';
import '../models/theme_group.dart';
import 'tapper.dart';

class ThemeTextButton extends StatelessWidget {
  const ThemeTextButton({
    Key? key,
    this.text,
    this.child,
    this.onPressed,
    this.padding,
  })  : assert(
          text != null || child != null,
          'text and child cannot be null at the same time.',
        ),
        super(key: key);

  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  Widget _childBuilder(BuildContext context) {
    if (child != null) {
      return child!;
    }
    return Text(
      text!,
      style: TextStyle(
        color: adaptiveButtonColor(),
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tapper(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: kThemeChangeDuration,
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 35.w, vertical: 8.w),
        decoration: BoxDecoration(
          borderRadius: RadiusConstants.max,
          color: onPressed != null
              ? context.themeColor
              : context.theme.dividerColor,
        ),
        child: _childBuilder(context),
      ),
    );
  }
}
