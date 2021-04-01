///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 5:29 PM
///
import 'package:flutter/material.dart';

class Instances {
  const Instances._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final RouteObserver<Route<dynamic>> routeObserver =
      RouteObserver<Route<dynamic>>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;

  static GlobalKey appRepaintBoundaryKey = GlobalKey();
  static GlobalKey<ScaffoldState> mainPageScaffoldKey =
      GlobalKey<ScaffoldState>();
}

NavigatorState get navigatorState => Instances.navigatorKey.currentState!;

BuildContext get currentContext => navigatorState.context;

ThemeData get currentTheme => Theme.of(currentContext);

Color get currentThemeColor => currentTheme.accentColor;

bool get currentIsDark => currentTheme.brightness == Brightness.dark;

DateTime get currentTime => DateTime.now();

int get currentTimeStamp => currentTime.millisecondsSinceEpoch;
