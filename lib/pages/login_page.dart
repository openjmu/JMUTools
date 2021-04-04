///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:42 PM
///
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:jmu_tools/exports/export.dart';

import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _LoginNotifier _loginModel = _LoginNotifier();

  late final TextEditingController _usernameTEC = TextEditingController(
    text: SettingsUtil.getUserWorkId(),
  );

  @override
  void dispose() {
    _loginModel.dispose();
    _usernameTEC.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_loginModel.isRequesting) {
      return;
    }
    _loginModel.isRequesting = true;
    if (await UserAPI.login(_loginModel.username, _loginModel.password)) {
      navigatorState.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainPage()),
      );
      return;
    }
    _loginModel.isRequesting = false;
  }

  InputBorder _inputBorder(BuildContext context) {
    return UnderlineInputBorder(borderSide: dividerBS(context));
  }

  Widget _fieldWrapper({required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: child,
    );
  }

  Widget _userField(BuildContext context) {
    return _fieldWrapper(
      child: TextField(
        controller: _usernameTEC,
        enabled: !context.select<_LoginNotifier, bool>(
          (_LoginNotifier p) => p.isRequesting,
        ),
        onChanged: (String value) => _loginModel.username = value,
        decoration: InputDecoration(
          border: _inputBorder(context),
          enabledBorder: _inputBorder(context),
          hintText: ' 工号/学号',
          hintStyle: const TextStyle(fontWeight: FontWeight.normal),
          suffixIcon: Consumer<_LoginNotifier>(
            builder: (_, _LoginNotifier p, __) {
              if (p.isRequesting || p.username.isEmpty) {
                return const SizedBox.shrink();
              }
              return Tapper(
                onTap: () {
                  _usernameTEC.clear();
                  _loginModel.username = '';
                },
                child: SvgPicture.asset(
                  R.ASSETS_ICONS_CLEAR_INPUT_SVG,
                  color: context.iconTheme.color,
                ),
              );
            },
          ),
          suffixIconConstraints: BoxConstraints.loose(Size.square(20.w)),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(12),
          FilteringTextInputFormatter.allow(RegExp(r'\d')),
        ],
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return _fieldWrapper(
      child: TextField(
        enabled: !context.select<_LoginNotifier, bool>(
          (_LoginNotifier p) => p.isRequesting,
        ),
        obscureText: context.select<_LoginNotifier, bool>(
          (_LoginNotifier p) => p.isObscure,
        ),
        onChanged: (String value) => _loginModel.password = value,
        decoration: InputDecoration(
          border: _inputBorder(context),
          enabledBorder: _inputBorder(context),
          hintText: ' 密码',
          hintStyle: const TextStyle(fontWeight: FontWeight.normal),
          suffixIcon: () {
            if (context.select<_LoginNotifier, bool>(
              (_LoginNotifier p) => p.isRequesting,
            )) {
              return const SizedBox.shrink();
            }
            final bool isObscure = context.select<_LoginNotifier, bool>(
              (_LoginNotifier p) => p.isObscure,
            );
            return Tapper(
              onTap: () => _loginModel.isObscure = !isObscure,
              child: SvgPicture.asset(
                isObscure
                    ? R.ASSETS_ICONS_NOT_OBSCURE_SVG
                    : R.ASSETS_ICONS_OBSCURE_SVG,
                color: isObscure ? context.iconTheme.color : defaultLightColor,
              ),
            );
          }(),
          suffixIconConstraints: BoxConstraints.loose(Size.square(20.w)),
        ),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _agreementButton(BuildContext context) {
    return Row(
      children: <Widget>[
        Selector<_LoginNotifier, bool>(
          selector: (_, _LoginNotifier p) => p.isAgreed,
          builder: (BuildContext context, bool isAgreed, __) => Tapper(
            onTap: () {
              _loginModel.isAgreed = !isAgreed;
            },
            child: SvgPicture.asset(
              isAgreed
                  ? R.ASSETS_ICONS_AGREEMENT_AGREED_SVG
                  : R.ASSETS_ICONS_AGREEMENT_SVG,
              width: 20.w,
              height: 20.w,
              color: !isAgreed ? context.theme.dividerColor : null,
            ),
          ),
        ),
        Gap(10.w),
        Expanded(child: _agreementTips),
      ],
    );
  }

  Widget get _agreementTips {
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          const TextSpan(text: '我已阅读并同意'),
          TextSpan(
            text: '《用户协议》',
            style: TextStyle(
              color: context.themeColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                API.launchWeb(
                  url: '${API.homePage}/license.html',
                  title: '用户协议',
                );
              },
          ),
        ],
      ),
      style: context.textTheme.caption!.copyWith(fontSize: 14.sp),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Selector<_LoginNotifier, bool>(
      selector: (_, _LoginNotifier p) => p.isEnabled,
      builder: (BuildContext context, bool isEnabled, _) => ThemeTextButton(
        onPressed: isEnabled ? login : null,
        text: '登录',
        child: () {
          if (context.select<_LoginNotifier, bool>(
            (_LoginNotifier p) => p.isRequesting,
          )) {
            return SizedBox(
              width: 30.w,
              child: PlatformProgressIndicator(
                alignment: Alignment.center,
                size: Size.square(22.w),
                color: Colors.white,
                strokeWidth: 3,
              ),
            );
          }
          return null;
        }(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_LoginNotifier>.value(
      value: _loginModel,
      builder: (BuildContext context, _) => WillPopScope(
        onWillPop: () async => false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '欢迎体验全新 JMU Tools',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '请先登录您的账号',
                      style: context.textTheme.caption!.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    VGap(30.w),
                    _userField(context),
                    _passwordField(context),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(child: _agreementButton(context)),
                          _loginButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginNotifier extends ChangeNotifier {
  _LoginNotifier({
    String? username,
    String? password,
    bool isAgreed = false,
    bool isRequesting = false,
    bool isObscure = true,
  }) {
    _username = username ?? SettingsUtil.getUserWorkId() ?? '';
    _password = password ?? '';
    _isAgreed = isAgreed;
    _isRequesting = isRequesting;
    _isObscure = isObscure;
  }

  String _username = '';

  String get username => _username;

  set username(String value) {
    if (value == _username) {
      return;
    }
    _username = value;
    notifyListeners();
  }

  String _password = '';

  String get password => _password;

  set password(String value) {
    if (value == _password) {
      return;
    }
    _password = value;
    notifyListeners();
  }

  bool _isAgreed = false;

  bool get isAgreed => _isAgreed;

  set isAgreed(bool value) {
    if (value == _isAgreed) {
      return;
    }
    _isAgreed = value;
    notifyListeners();
  }

  bool get isEnabled =>
      _username.isNotEmpty &&
      _password.isNotEmpty &&
      _isAgreed &&
      !_isRequesting;

  bool _isRequesting = false;

  bool get isRequesting => _isRequesting;

  set isRequesting(bool value) {
    if (value == _isRequesting) {
      return;
    }
    _isRequesting = value;
    notifyListeners();
  }

  bool _isObscure = true;

  bool get isObscure => _isObscure;

  set isObscure(bool value) {
    if (value == _isObscure) {
      return;
    }
    _isObscure = value;
    notifyListeners();
  }
}
