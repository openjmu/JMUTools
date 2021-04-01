///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:35 PM
///
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jmu_tools/exports/export.dart';

import 'pages/splash_page.dart';

void main() {
  _customizeErrorWidget();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JMU Tools',
      theme: ThemeData(primarySwatch: defaultLightColor.swatch),
      navigatorKey: Instances.navigatorKey,
      navigatorObservers: <NavigatorObserver>[Instances.routeObserver],
      home: const SplashPage(),
      builder: (BuildContext c, Widget? w) => RepaintBoundary(
        key: Instances.appRepaintBoundaryKey,
        child: w!,
      ),
    );
  }
}

void _rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

void _customizeErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: currentTheme.accentColor.withOpacity(0.125),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              R.ASSETS_PLACEHOLDERS_NO_NETWORK_SVG,
              width: 50.w,
              color: currentTheme.iconTheme.color,
            ),
            VGap(20.w),
            Text(
              '出现了不可预料的错误 (>_<)',
              style: TextStyle(
                color: currentTheme.textTheme.caption!.color,
                fontSize: 22.sp,
              ),
            ),
            VGap(10.w),
            Text(
              details.exception.toString(),
              style: TextStyle(
                color: currentTheme.textTheme.caption!.color,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            VGap(10.w),
            Text(
              details.stack.toString(),
              style: TextStyle(
                color: currentTheme.textTheme.caption!.color,
                fontSize: 16.sp,
              ),
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
            ),
            VGap(20.w),
            Tapper(
              onTap: _takeAppScreenshot,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.w),
                  color: currentTheme.accentColor,
                ),
                child: Text(
                  '保存当前位置错误截图',
                  style: TextStyle(
                    fontSize: 20.sp,
                    height: 1.24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  };
}

Future<void> _takeAppScreenshot() async {
  try {
    final ByteData byteData = await obtainScreenshot(
      Instances.appRepaintBoundaryKey,
    );
    await PhotoManager.editor.saveImage(byteData.buffer.asUint8List());
    showToast('截图保存成功');
  } catch (e) {
    LogUtil.e('Error when taking app\'s screenshot: $e');
    showCenterErrorToast('截图保存失败');
  }
}
