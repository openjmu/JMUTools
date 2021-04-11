///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 6:01 PM
///
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extensions/build_context_extension.dart';
import '../extensions/size_extension.dart';
export '../widgets/adaptive_layout.dart';
export '../widgets/dialogs/confirmation_bottom_sheet.dart';
export '../widgets/dialogs/confirmation_dialog.dart';
export '../widgets/dismiss_wrapper.dart';
export '../widgets/fixed_appbar.dart';
export '../widgets/gaps.dart';
export '../widgets/in_app_webview.dart';
export '../widgets/loading_icon.dart';
export '../widgets/no_splash.dart';
export '../widgets/tapper.dart';
export '../widgets/theme_text_button.dart';
export '../widgets/value_listenable_builders.dart';

class LineDivider extends StatelessWidget {
  const LineDivider({
    Key? key,
    this.thickness = 1,
    this.color,
    this.indent,
    this.endIndent,
  }) : super(key: key);

  final double thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      thickness: thickness.w,
      height: thickness.w,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    VoidCallback? onRemoved,
  }) : super(
          controller: controller,
          referenceBox: referenceBox,
          onRemoved: onRemoved,
          color: Colors.transparent,
        ) {
    controller.addInkFeature(this);
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}

/// Progress Indicator. Used in loading data.
class PlatformProgressIndicator extends StatelessWidget {
  const PlatformProgressIndicator({
    Key? key,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.color,
    this.value,
    this.brightness,
    this.alignment,
    this.size,
  }) : super(key: key);

  final double strokeWidth;
  final double radius;
  final Color? color;
  final double? value;
  final Brightness? brightness;
  final Alignment? alignment;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (Platform.isIOS || Platform.isMacOS) {
      child = CupertinoTheme(
        data: CupertinoThemeData(
          brightness: brightness ?? context.brightness,
        ),
        child: CupertinoActivityIndicator(radius: radius),
      );
    } else {
      child = CircularProgressIndicator(
        strokeWidth: strokeWidth.w,
        valueColor:
            color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
        value: value,
      );
    }
    if (size != null) {
      child = SizedBox.fromSize(size: size!, child: child);
    }
    if (alignment != null) {
      child = Align(alignment: alignment!, child: child);
    }
    return child;
  }
}
