///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 16:44
///
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
  @override
  void initState() {
    super.initState();
    if (!widget.isFromLogin) {
      UserAPI.checkSessionValid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ThemeTextButton(
              text: 'checkSessionValid',
              onPressed: () => UserAPI.checkSessionValid(),
            ),
            ThemeTextButton(
              text: 'getTicket',
              onPressed: () => UserAPI.updateSession(),
            ),
            ThemeTextButton(
              text: 'updateUserInfo',
              onPressed: () => UserAPI.updateUserInfo(),
            ),
            ThemeTextButton(
              text: 'logout',
              onPressed: () => UserAPI.logout(),
            ),
            ThemeTextButton(
              text: 'clearBoxes',
              onPressed: () => Boxes.clearAllBoxes(context),
            ),
            ThemeTextButton(
              text: 'test',
              onPressed: () =>
                  HttpUtil.fetch<void>(FetchType.post, url: API.logout),
            ),
          ],
        ),
        // child: Text(
        //   UserAPI.user.toString(),
        // ),
      ),
    );
  }
}
