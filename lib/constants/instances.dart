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
