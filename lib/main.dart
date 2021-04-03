///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:35 PM
///
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart' show OKToast, ToastPosition;

import 'package:jmu_tools/exports/export.dart';

import 'pages/login_page.dart';
import 'pages/main_page.dart';

final ThemeData theme = ThemeData(primarySwatch: defaultLightColor.swatch);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));

  await Hive.initFlutter();
  await Boxes.openBoxes();
  await Future.wait(
    <Future<void>>[
      DeviceUtil.initDeviceInfo(),
      PackageUtil.initPackageInfo(),
      HttpUtil.initConfig(),
    ],
    eagerError: true,
  );

  UserAPI.recoverLoginInfo();
  _customizeErrorWidget();
  runApp(const ToolsApp());
}

class ToolsApp extends StatefulWidget {
  const ToolsApp({Key? key}) : super(key: key);

  @override
  ToolsAppState createState() => ToolsAppState();
}

class ToolsAppState extends State<ToolsApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LogUtil.d('AppLifecycleState change to: ${state.toString()}');
    Instances.appLifeCycleState = state;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: globalProviders,
      builder: (_, __) => Selector<ThemesProvider, bool>(
        selector: (_, ThemesProvider p) => p.dark,
        builder: (BuildContext ctx, bool isDark, __) => Theme(
          data: isDark
              ? ctx.read<ThemesProvider>().darkTheme
              : ctx.read<ThemesProvider>().lightTheme,
          child: OKToast(
            position: ToastPosition.bottom,
            textStyle: const TextStyle(fontSize: 14),
            textPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: MaterialApp(
              key: Instances.appKey,
              title: 'JMU Tools',
              theme: theme,
              navigatorKey: Instances.navigatorKey,
              navigatorObservers: <NavigatorObserver>[Instances.routeObserver],
              home: UserAPI.isLogin ? const MainPage() : const LoginPage(),
              builder: (BuildContext c, Widget? w) => RepaintBoundary(
                key: Instances.appRepaintBoundaryKey,
                child: w!,
              ),
              localizationsDelegates: localizationsDelegates,
              supportedLocales: supportedLocales,
            ),
          ),
        ),
      ),
    );
  }
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
