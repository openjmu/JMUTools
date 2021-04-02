///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 20:38
///
import 'package:jmu_tools/models/data_model.dart';

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
}
