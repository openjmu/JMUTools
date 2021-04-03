///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 20:38
///
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jmu_tools/constants/instances.dart';
import 'package:jmu_tools/exports/providers.dart';
import 'package:jmu_tools/models/data_model.dart';
import 'package:jmu_tools/utils/log_util.dart';
import 'package:jmu_tools/widgets/in_app_webview.dart';

class API {
  const API._();

  static const String oa99Host = 'https://oa99.jmu.edu.cn';
  static const String oap99Host = 'https://oap99.jmu.edu.cn';
  static const String labsHost = 'http://labs.jmu.edu.cn';
  static const String webVpnHost = 'https://webvpn.jmu.edu.cn';

  static const List<String> jmuHosts = <String>[
    oa99Host,
    oap99Host,
    labsHost,
    webVpnHost,
  ];

  /// OpenJMU 官网
  static const String homePage = 'https://openjmu.jmu.edu.cn'; // OpenJMU官网

  /// 学期起始日（用于确定周数）
  static const String firstDayOfTerm =
      'https://openjmu.alexv525.com/api/first-day-of-term';

  /// 检查更新
  static const String checkUpdate =
      'https://openjmu.alexv525.com/api/latest-version';

  /// 公告
  static const String announcement =
      'https://openjmu.alexv525.com/api/announcement';

  /// 吐个槽
  static String complaints(UserModel user) =>
      'https://openjmu.alexv525.com/tucao/index.html'
      '?uid=${user.uid}'
      '&name=${user.username}'
      '&workId=${user.workId}';

  /// 服务状态
  static const String statusWebsite = 'https://status.openjmu.xyz/';

  /// 认证相关
  static const String login = '$oa99Host/v2/passport/api/user/login1'; // 登录
  static const String logout = '$oap99Host/passport/logout'; // 注销
  static const String loginTicket =
      '$oa99Host/v2/passport/api/user/loginticket1'; // 更新session

  /// 用户相关
  static const String userInfo = '$oap99Host/user/info'; // 用户信息
  static String studentInfo({String uid = '0'}) =>
      '$oa99Host/v2/api/class/studentinfo?uid=$uid'; // 学生信息

  /// 课程表相关
  static const String courseSchedule = '$labsHost/CourseSchedule/course.html';
  static const String courseScheduleTeacher =
      '$labsHost/CourseSchedule/Tcourse.html';

  static const String courseScheduleCourses =
      '$labsHost/CourseSchedule/StudentCourseSchedule';
  static const String courseScheduleClassRemark =
      '$labsHost/CourseSchedule/StudentClassRemark';
  static const String courseScheduleTermLists =
      '$labsHost/CourseSchedule/GetSemesters';
  static const String courseScheduleCustom =
      '$labsHost/CourseSchedule/StudentCustomSchedule';

  /// 应用中心
  static const String webAppLists = '$oap99Host/app/unitmenu?cfg=1'; // 获取应用列表
  static String webAppIcons =
      '$oap99Host/app/menuicon?size=f128&unitid=55&'; // 获取应用图标

  /// 将域名替换为 WebVPN 映射的二级域名
  ///
  /// 例如：http://labs.jmu.edu.cn
  /// 结果：https://labs-jmu-edu-cn.webvpn.jmu.edu.cn
  static String replaceWithWebVPN(String url) {
    LogUtil.d('Replacing url: $url');
    final Uri previousUri = Uri.parse(url);
    final String concatHost = previousUri.host.replaceAll('.', '-');
    final String joinedHost = 'https://$concatHost.'
        '${API.webVpnHost.replaceAll('https://', '')}';
    final String replacedUrl = url.replaceAll(API.labsHost, joinedHost);
    LogUtil.d('Replaced with: $replacedUrl');
    return replacedUrl;
  }

  static Future<void> launchWeb({
    required String url,
    String? title,
    WebAppModel? app,
    bool withCookie = true,
  }) async {
    final SettingsProvider provider = Provider.of<SettingsProvider>(
      currentContext,
      listen: false,
    );
    final bool shouldLaunchFromSystem = provider.launchWebAppFromSystem;
    final String uri = '${Uri.parse(url.trim())}';
    if (shouldLaunchFromSystem) {
      LogUtil.d('Launching web: $uri');
      launch(
        uri,
        forceSafariVC: false,
        forceWebView: false,
        enableJavaScript: true,
        enableDomStorage: true,
      );
    } else {
      LogUtil.d('Launching web: $uri');
      AppWebView.launch(
        url: uri,
        title: title,
        app: app,
        withCookie: withCookie,
      );
    }
  }
}
