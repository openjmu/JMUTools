///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-10 15:48
///
import 'package:flutter/material.dart';
import 'package:jmu_tools/exports/export.dart';

class CourseAdaptiveView extends StatelessWidget {
  const CourseAdaptiveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      maxWidth: 1080.w,
      children: <Widget>[
        Selector<CoursesProvider, String?>(
          selector: (_, CoursesProvider p) => p.remark,
          builder: (_, String? remark, __) {
            if (remark.isNotNullOrEmpty) {
              return AdaptiveChildWidget(
                weightBuilder: (_) => 12,
                builder: (_) => Text(remark!),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        AdaptiveChildWidget(
          weightBuilder: (AdaptiveType type) =>
              type == AdaptiveType.medium ? 9 : 6,
          builder: (_) => _CardWidget(
            title: '今日',
            selector: (_, CoursesProvider p) => p.coursesToday,
            itemBuilder: (CourseModel c) => _CourseItemWidget(c),
          ),
        ),
        AdaptiveChildWidget(
          weightBuilder: (AdaptiveType type) =>
              type == AdaptiveType.medium ? 9 : 6,
          builder: (_) => _CardWidget(
            title: '明日，${(currentTime + 1.days).mDddd}',
            selector: (_, CoursesProvider p) => p.coursesTomorrow,
            itemBuilder: (CourseModel c) =>
                _CourseItemWidget(c, isToday: false),
          ),
        ),
      ],
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
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.w),
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
                    size: 20.w,
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
