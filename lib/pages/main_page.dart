///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 16:44
///
import 'package:flutter/material.dart';
import 'package:jmu_tools/exports/export.dart';

import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
          ],
        ),
        // child: Text(
        //   UserAPI.user.toString(),
        // ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    UserAPI.checkSessionValid().then((bool isValid) {
      if (!isValid) {
        navigatorState.pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          (_) => false,
        );
        showErrorToast('身份已失效');
      }
    });
  }
}
