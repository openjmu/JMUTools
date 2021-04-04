///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 20:58
///
import 'package:flutter/material.dart';

import 'package:jmu_tools/exports/export.dart';
import 'package:jmu_tools/pages/login_page.dart';

class UserAPI {
  const UserAPI._();

  static bool get isLogin => _loginModel != null && _userModel != null;

  static LoginModel? _loginModel;

  static LoginModel? get loginModel => _loginModel;

  static set loginModel(LoginModel? value) {
    if (value == _loginModel) {
      return;
    }
    _loginModel = value;
    if (value == null) {
      Boxes.loginBox.clear();
      return;
    }
    Boxes.loginBox.put(0, value);
  }

  static UserModel? _userModel;

  static UserModel get user => _userModel!;

  static set userModel(UserModel? value) {
    if (value == _userModel) {
      return;
    }
    _userModel = value;
    if (value == null) {
      Boxes.userBox.clear();
      return;
    }
    Boxes.userBox.put(0, value);
  }

  static void recoverLoginInfo() {
    _loginModel = Boxes.loginBox.get(0);
    _userModel = Boxes.userBox.get(0);
  }

  /// 使用 [username] 和 [password] 登录
  static Future<bool> login(String username, String password) async {
    final String blowfish = const Uuid().v4();
    final Map<String, dynamic> params = Constants.loginParams(
      username: username,
      password: password,
      blowfish: blowfish,
    );
    try {
      final LoginModel loginData = await HttpUtil.fetchModel(
        FetchType.post,
        url: API.login,
        body: params,
        useTokenDio: true,
      );
      if (loginData.isTeacher) {
        showErrorToast('抱歉，暂不支持教师使用');
        return false;
      }
      loginModel = loginData.copyWith(blowfish: blowfish);
      await HttpUtil.updateDomainsCookies(API.jmuHosts);
      if (await updateUserInfo()) {
        // 存储学工号
        SettingsUtil.setUserWorkId(username);
        // 根据信息初始化 WebView 的 Cookie
        HttpUtil.initializeWebViewCookie();
        showToast('登录成功');
        return true;
      }
      return false;
    } catch (e) {
      showErrorToast('登录失败 ($e)');
      return false;
    }
  }

  /// 检查已保存的 session 是否还可以使用
  ///
  /// 如果可用，不需要更新 session。
  /// 如果不可用，先尝试更新 session，成功则返回 `true`，否则为 `false`。
  static Future<bool> checkSessionValid() async {
    HttpUtil.dio.lock();
    try {
      await updateUserInfo(useTokenDio: true);
      LogUtil.d('Session is valid: ${UserAPI.loginModel!.sid}');
      return true;
    } catch (e) {
      // TODO(Alex): 在这里查看状态码，区分什么时候是真失效，什么时候是网络环境差，用于后续的离线支持。
      return await updateSession();
    } finally {
      HttpUtil.dio.unlock();
    }
  }

  /// 更新用户的 session
  static Future<bool> updateSession() async {
    if (_loginModel == null) {
      LogUtil.e('Ticket and blowfish does not exist.');
      return false;
    }
    final String ticket = _loginModel!.ticket!;
    final String blowfish = _loginModel!.blowfish!;
    try {
      LogUtil.d('Fetch new session with: $ticket');
      final LoginModel res = await HttpUtil.fetchModel(
        FetchType.post,
        url: API.loginTicket,
        body: Constants.loginParams(blowfish: blowfish, ticket: ticket),
      );
      loginModel = _loginModel!.merge(res);
      if (await updateUserInfo()) {
        await Future.wait(<Future<void>>[
          HttpUtil.updateDomainsCookies(API.jmuHosts),
          HttpUtil.initializeWebViewCookie(),
        ]);
        return true;
      }
      return false;
    } catch (e) {
      LogUtil.e('Error when updating session: $e');
      return false;
    }
  }

  static Future<bool> updateUserInfo({bool useTokenDio = false}) async {
    try {
      final UserModel user = await HttpUtil.fetchModel(
        FetchType.get,
        url: API.userInfo,
        queryParameters: <String, String>{'uid': _loginModel!.uid.toString()},
        useTokenDio: useTokenDio,
      );
      userModel = user;
      return true;
    } catch (e) {
      LogUtil.e('Error when updating user info: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    navigatorState.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
    currentContext.read<CoursesProvider>().unloadCourses();
    // currentContext.read<ScoresProvider>().unloadScore();
    Future<void>.delayed(250.milliseconds, () {
      currentContext.read<ThemesProvider>().resetTheme();
      currentContext.read<SettingsProvider>().reset();
    });
    await HttpUtil.fetch<dynamic>(FetchType.post, url: API.logout);
    HttpUtil.dio.clear();
    HttpUtil.tokenDio.clear();
    HttpUtil.cookieJar.deleteAll();
    HttpUtil.tokenCookieJar.deleteAll();
    HttpUtil.webViewCookieManager.deleteAllCookies();
    final String workId = SettingsUtil.getUserWorkId()!;
    userModel = null;
    await Boxes.settingsBox.clear();
    await SettingsUtil.setUserWorkId(workId);
    showToast('退出登录成功');
  }
}
