///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:42 PM
///
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:jmu_tools/exports/export.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool firstFramed = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        firstFramed = true;
      });
    });
  }

  Widget get logo {
    return Tapper(
      onTap: () {
        UserAPI.login('201521033021', 'DoMyOwn525');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.w),
        child: SvgPicture.asset(
          R.ASSETS_OPENJMU_LOGO_TEXT_SVG,
          width: Screens.width / 3,
          color: currentThemeColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: currentIsDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: AnimatedOpacity(
          duration: 500.milliseconds,
          curve: Curves.easeInOut,
          opacity: firstFramed ? 1.0 : 0.0,
          child: Scaffold(body: Center(child: logo)),
        ),
      ),
    );
  }
}
