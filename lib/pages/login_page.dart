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
  /// 是否允许登陆
  final ValueNotifier<bool> _loginButtonEnabled = ValueNotifier<bool>(false);

  /// 是否开启密码显示
  final ValueNotifier<bool> _isObscure = ValueNotifier<bool>(true);

  /// 是否正在登陆
  final ValueNotifier<bool> _isRequesting = ValueNotifier<bool>(false);

  /// 是否已勾选同意协议
  final ValueNotifier<bool> _isAgreed = ValueNotifier<bool>(false);

  late final TextEditingController _usernameTEC = TextEditingController(
    text: SettingsUtil.getUserWorkId(),
  );
  final TextEditingController _passwordTEC = TextEditingController();

  String get _username => _usernameTEC.text;

  String get _password => _passwordTEC.text;

  @override
  void dispose() {
    _loginButtonEnabled.dispose();
    _isObscure.dispose();
    _isRequesting.dispose();
    _isAgreed.dispose();
    _usernameTEC.dispose();
    _passwordTEC.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_isRequesting.value) {
      return;
    }
    _isRequesting.value = true;
    if (await UserAPI.login(_username, _password)) {
      navigatorState.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainPage()),
      );
      return;
    }
    _isRequesting.value = false;
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
      child: ValueListenableBuilder<bool>(
        valueListenable: _isRequesting,
        builder: (_, bool isRequesting, __) => TextField(
          controller: _usernameTEC,
          enabled: !isRequesting,
          decoration: InputDecoration(
            border: _inputBorder(context),
            enabledBorder: _inputBorder(context),
            hintText: ' 工号/学号',
            hintStyle: const TextStyle(fontWeight: FontWeight.normal),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _usernameTEC,
              builder: (_, TextEditingValue value, __) {
                if (isRequesting || value.text.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Tapper(
                  onTap: _usernameTEC.clear,
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
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return _fieldWrapper(
      child: ValueListenableBuilder2<bool, bool>(
        firstNotifier: _isRequesting,
        secondNotifier: _isObscure,
        builder: (_, bool isRequesting, bool isObscure, __) => TextField(
          controller: _passwordTEC,
          enabled: !isRequesting,
          obscureText: isObscure,
          decoration: InputDecoration(
            border: _inputBorder(context),
            enabledBorder: _inputBorder(context),
            hintText: ' 密码',
            hintStyle: const TextStyle(fontWeight: FontWeight.normal),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _usernameTEC,
              builder: (_, TextEditingValue value, __) {
                if (isRequesting) {
                  return const SizedBox.shrink();
                }
                return Tapper(
                  onTap: () => _isObscure.value = !isObscure,
                  child: SvgPicture.asset(
                    isObscure
                        ? R.ASSETS_ICONS_NOT_OBSCURE_SVG
                        : R.ASSETS_ICONS_OBSCURE_SVG,
                    color:
                        isObscure ? context.iconTheme.color : defaultLightColor,
                  ),
                );
              },
            ),
            suffixIconConstraints: BoxConstraints.loose(Size.square(20.w)),
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _agreementButton(BuildContext context) {
    return Row(
      children: <Widget>[
        ValueListenableBuilder<bool>(
          valueListenable: _isAgreed,
          builder: (_, bool value, __) => Tapper(
            onTap: () {
              _isAgreed.value = !value;
            },
            child: SvgPicture.asset(
              value
                  ? R.ASSETS_ICONS_AGREEMENT_AGREED_SVG
                  : R.ASSETS_ICONS_AGREEMENT_SVG,
              width: 20.w,
              height: 20.w,
              color: !value ? context.theme.dividerColor : null,
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
    return ValueListenableBuilder2<bool, bool>(
      firstNotifier: _loginButtonEnabled,
      secondNotifier: _isRequesting,
      builder: (_, bool enabled, bool isRequesting, __) => ThemeTextButton(
        onPressed: enabled ? login : null,
        text: '登录',
        child: isRequesting
            ? SizedBox(
                width: 30.w,
                child: PlatformProgressIndicator(
                  alignment: Alignment.center,
                  size: Size.square(22.w),
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : null,
      ),
    );
  }

  /// This is pretty much a magic by checking fields using VLBs, and calls the
  /// value update at post frame, without add listeners to controllers.
  Widget get _fieldsCheck {
    return ValueListenableBuilder3<bool, TextEditingValue, TextEditingValue>(
      firstNotifier: _isAgreed,
      secondNotifier: _usernameTEC,
      thirdNotifier: _passwordTEC,
      builder: (
        _,
        bool isAgreed,
        TextEditingValue uValue,
        TextEditingValue pValue,
        Widget? child,
      ) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _loginButtonEnabled.value =
              isAgreed && uValue.text.isNotEmpty && pValue.text.isNotEmpty;
        });
        return child!;
      },
      child: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: currentIsDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
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
                  _fieldsCheck,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
