///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-11 17:41
///
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmu_tools/constants/resources.dart';
import 'package:jmu_tools/exports/extensions.dart';

class LoadingIcon extends StatefulWidget {
  const LoadingIcon({
    Key? key,
    required this.isRefreshing,
    this.size,
    this.color,
  }) : super(key: key);

  final bool isRefreshing;
  final double? size;
  final Color? color;

  @override
  _LoadingIconState createState() => _LoadingIconState();
}

class _LoadingIconState extends State<LoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    duration: const Duration(milliseconds: 1800),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    updateAnimation();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LoadingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateAnimation();
  }

  void updateAnimation() {
    if (widget.isRefreshing) {
      _animation.repeat();
    } else {
      _animation.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: SvgPicture.asset(
        R.ASSETS_ICONS_LOADING_ICON_SVG,
        width: (widget.size ?? 60).w,
        color:
            widget.color ?? context.textTheme.caption!.color!.withOpacity(0.5),
      ),
    );
  }
}
