///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 21:13
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jmu_tools/apis/api.dart';
import 'package:jmu_tools/extensions/size_extension.dart';
import 'package:jmu_tools/models/data_model.dart';
import 'package:jmu_tools/utils/log_util.dart';

class WebAppIcon extends StatelessWidget {
  const WebAppIcon({
    Key? key,
    required this.app,
    this.size,
  }) : super(key: key);

  final WebAppModel app;
  final double? size;

  double? get oldIconSize => size != null ? size! / 1.375 : null;

  String get iconPath => 'assets/icons/app-center/apps/'
      '${app.appId}-${app.code}.svg';

  String get oldIconUrl => '${API.webAppIcons}'
      'appid=${app.appId}'
      '&code=${app.code}';

  Future<bool> get exist async {
    try {
      await rootBundle.load(iconPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Widget> loadAsset() async {
    if (await exist) {
      return SvgPicture.asset(
        iconPath,
        width: size?.w,
        height: size?.w,
      );
    } else {
      LogUtil.e(
        'Error when loading '
        '${app.name} (${app.appId}-${app.code})'
        '\'s icon.',
      );
      return Image.network(
        oldIconUrl,
        fit: BoxFit.fill,
        width: oldIconSize?.w,
        height: oldIconSize?.w,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FutureBuilder<Widget>(
      initialData: const SizedBox.shrink(),
      future: loadAsset(),
      builder: (_, AsyncSnapshot<Widget> snapshot) => snapshot.data!,
    );
    if (size != null) {
      child = SizedBox.fromSize(
        size: Size.square(size!.w),
        child: Center(child: child),
      );
    }
    return child;
  }
}
