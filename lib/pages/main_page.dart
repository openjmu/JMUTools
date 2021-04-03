///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 16:44
///
import 'package:flutter/material.dart';

import 'package:jmu_tools/exports/export.dart';

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
              text: 'Hi there',
              onPressed: () => UserAPI.getTicket(),
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
}
