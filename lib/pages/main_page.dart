///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 16:44
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jmu_tools/exports/export.dart';

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
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(context.watch<DateProvider>().dateString),
              VGap(12.w),
              Text(
                '课程表',
                style: context.textTheme.headline6!.copyWith(
                  fontSize: 24.sp,
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _CardWidget(
                      title: '今日',
                      selector: (_, CoursesProvider p) => p.coursesToday,
                      itemBuilder: (CourseModel c) => _CourseItemWidget(c),
                    ),
                    _CardWidget(
                      title: '明日，${currentTime.mDddd}',
                      selector: (_, CoursesProvider p) => p.coursesTomorrow,
                      itemBuilder: (CourseModel c) =>
                          _CourseItemWidget(c, isToday: false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  const _CardWidget({
    Key? key,
    required this.title,
    required this.selector,
    required this.itemBuilder,
  }) : super(key: key);

  final String title;
  final List<CourseModel> Function(BuildContext, CoursesProvider) selector;
  final Widget Function(CourseModel) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: RadiusConstants.r20,
        color: context.surfaceColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: context.textTheme.headline6!.copyWith(fontSize: 16.sp),
          ),
          VGap(16.w),
          Selector<CoursesProvider, List<CourseModel>>(
            selector: selector,
            builder: (_, List<CourseModel> courses, __) {
              if (courses.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  height: 50.w,
                  child: Text(
                    '无课程安排',
                    style: context.textTheme.caption!.copyWith(fontSize: 18.sp),
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(
                  courses.length,
                  (int index) => itemBuilder(courses[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseItemWidget extends StatelessWidget {
  const _CourseItemWidget(
    this.course, {
    Key? key,
    this.isToday = true,
  }) : super(key: key);

  final CourseModel course;
  final bool isToday;

  bool get isOver => course.isOver && isToday;

  bool get inCurrentTime => course.inCurrentTime;

  Color statusColor(BuildContext context) {
    if (inCurrentTime) {
      return context.themeColor;
    }
    if (isOver) {
      return context.textTheme.caption!.color!;
    }
    return context.textTheme.bodyText2!.color!;
  }

  String get status {
    if (inCurrentTime) {
      return '正在上课';
    }
    if (isOver) {
      return '已下课';
    }
    return '等待上课';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: inCurrentTime ? FontWeight.w500 : FontWeight.normal,
            ),
            child: Row(
              children: <Widget>[
                if (inCurrentTime)
                  Icon(
                    Icons.play_arrow,
                    size: 24.w,
                    color: context.themeColor,
                  ),
                Expanded(
                  child: Text(
                    course.name,
                    style: TextStyle(
                      color: statusColor(context),
                      decoration: isOver ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Gap(10.w),
                Text(
                  course.timeString,
                  style: TextStyle(
                    color: inCurrentTime ? context.themeColor : null,
                  ),
                ),
              ],
            ),
          ),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: !inCurrentTime ? context.textTheme.caption!.color : null,
              fontSize: 15.sp,
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(course.location ?? '未知地点')),
                Text(status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
