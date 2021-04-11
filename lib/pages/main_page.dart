///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 16:44
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jmu_tools/exports/export.dart';

import 'courses/adaptive_view.dart';
import 'courses/grid_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, this.isFromLogin = false}) : super(key: key);

  /// 判断是否是从登录页跳转进入
  ///
  /// 默认打开首页需要检查 session，刚登录的则不需要。
  final bool isFromLogin;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final Timer refreshTimer = Timer.periodic(
    const Duration(minutes: 1),
    (_) {
      if (Instances.appLifeCycleState == AppLifecycleState.resumed) {
        rebuildAllChildren(context);
      }
    },
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!widget.isFromLogin) {
      await UserAPI.checkSessionValid();
    }
    context.read<CoursesProvider>().initCourses();
    context.read<ScoresProvider>().initScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(context.watch<DateProvider>().dateString),
                  VGap(12.w),
                  Row(
                    children: <Widget>[
                      Text(
                        '课程表',
                        style: context.textTheme.headline6!.copyWith(
                          fontSize: 24.sp,
                        ),
                      ),
                      const Spacer(),
                      const ThemeTextButton(
                        text: '退出登录',
                        onPressed: UserAPI.logout,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: const CourseAdaptiveView(),
                // child: const CourseGridView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
