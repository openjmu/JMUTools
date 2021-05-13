///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 20:58
///
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

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
    await Boxes.upBox.clear();
    await Boxes.upBox.add(UPModel(username, password));
    try {
      final String? webVpnFailedReason = await webVpnLogin();
      if (webVpnFailedReason != null) {
        showToast('校内网络通道连接失败 (0 WV $webVpnFailedReason)');
        HttpUtil.shouldUseWebVPN = false;
      }
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
    } on DioError catch (dioError) {
      showErrorToast('登录失败 (${dioError.response?.data['msg']})');
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
  static Future<void> checkSessionValid() async {
    HttpUtil.dio.lock();
    try {
      await updateUserInfo(useTokenDio: true, renewSession: true);
    } catch (e) {
      await updateSession();
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
        useTokenDio: true,
      );
      loginModel = _loginModel!.merge(res);
      await Future.wait(<Future<void>>[
        HttpUtil.updateDomainsCookies(API.jmuHosts),
        HttpUtil.initializeWebViewCookie(),
      ]);
      return await updateUserInfo(useTokenDio: true);
    } catch (e) {
      LogUtil.e('Error when updating session: $e');
      navigatorState.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (_) => false,
      );
      showErrorToast('身份已失效');
      return false;
    }
  }

  static Future<bool> updateUserInfo({
    bool useTokenDio = false,
    bool renewSession = false,
  }) async {
    try {
      final UserModel user = await HttpUtil.fetchModel(
        FetchType.get,
        url: API.userInfo,
        queryParameters: <String, String>{'uid': _loginModel!.uid.toString()},
        useTokenDio: useTokenDio,
      );
      userModel = user;
      if (renewSession) {
        LogUtil.d('Session is valid: ${loginModel!.sid}');
        await webVpnLogin();
        return true;
      }
      return true;
    } catch (e) {
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
    if (Platform.isAndroid || Platform.isIOS) {
      HttpUtil.webViewCookieManager.deleteAllCookies();
    }
    final String workId = SettingsUtil.getUserWorkId()!;
    userModel = null;
    await Boxes.settingsBox.clear();
    await SettingsUtil.setUserWorkId(workId);
    showToast('退出登录成功');
  }

  static Future<String?> webVpnIsLogin() async {
    try {
      final String r = await HttpUtil.fetch(
        FetchType.get,
        url: API.webVpnHost,
        useTokenDio: true,
      );
      // 解析返回内容。如果包含「退出登录」，同时不包含「登录 Login」，即为已登录。
      if (r.contains('退出登录') && !r.contains('登录 Login')) {
        return null;
      }
      return r;
    } catch (e) {
      LogUtil.e('Error when testing WebVPN login status: $e');
      return '';
    }
  }

  /// Return `null` if succeed, and failed reason if failed.
  static Future<String?> webVpnLogin() async {
    try {
      final String? r = await webVpnIsLogin();
      if (r == null) {
        return null;
      }
      // 获取 DOM 中 <input name="authenticity_token" ... /> 的值。
      final dom.Document document = parse(r);
      final dom.Element tokenElement = document.querySelector(
        'input[name="authenticity_token"]',
      )!;
      final String token = tokenElement.attributes['value']!;
      // 将 token 保存，而后可以用 token 继续请求。
      await SettingsUtil.setWebVpnToken(token);

      final UPModel upModel = Boxes.upBox.getAt(0)!;
      final Response<String> loginRes = await HttpUtil.getResponse(
        FetchType.post,
        url: API.webVpnLogin,
        queryParameters: <String, String>{
          'utf8': '✓',
          'authenticity_token': token,
          'user[login]': upModel.u,
          'user[password]': upModel.p,
          'user[dymatice_code]': 'unknown',
          'user[otp_with_capcha]': 'false',
          'commit': '登录 Login',
        },
        contentType: 'application/x-www-form-urlencoded',
        useTokenDio: true,
      );
      // 直接解析返回内容中的头部内容。
      await _setVPNsValues(loginRes);
      return null;
    } on DioError catch (dioError) {
      // 当状态码为 302 时，代表登录成功，此时继续调用刷新接口，获取 session。
      if (dioError.response?.statusCode == HttpStatus.found) {
        return await webVpnUpdate();
      } else {
        LogUtil.e('Failed to login WebVPN: $dioError');
        await _clearVPNsValues();
        return dioError.toString();
      }
    } catch (e) {
      LogUtil.e('Error when login to WebVPN: $e');
      await _clearVPNsValues();
      return e.toString();
    }
  }

  static Future<String?> webVpnUpdate() async {
    try {
      final Response<String> res = await HttpUtil.getResponse(
        FetchType.get,
        url: API.webVpnUpdate,
        contentType: 'application/x-www-form-urlencoded',
        useTokenDio: true,
      );
      await _setVPNsValues(res);
      return null;
    } on DioError catch (dioError) {
      if (dioError.response?.statusCode == HttpStatus.found) {
        await _setVPNsValues(dioError.response!);
        return null;
      } else {
        await _clearVPNsValues();
        LogUtil.e('Failed to login WebVPN: $dioError');
        return dioError.toString();
      }
    } catch (e) {
      await _clearVPNsValues();
      LogUtil.e('Error when login to WebVPN: $e');
      return e.toString();
    }
  }

  static Future<void> _setVPNsValues(Response<dynamic> res) async {
    final List<Cookie> cookies = <Cookie>[
      ...res.headers['set-cookie']!
          .map((String s) => Cookie.fromSetCookieValue(s))
          .toList(),
      Cookie('SERVERID', 'Server1'),
    ];
    await Future.wait(<Future<void>>[
      HttpUtil.updateDomainsCookies(
        <String>['https://webvpn.jmu.edu.cn/'],
        cookies,
      ),
      if (Platform.isAndroid || Platform.isIOS)
        for (final Cookie cookie in cookies)
          HttpUtil.webViewCookieManager.setCookie(
            url: Uri.parse('https://webvpn.jmu.edu.cn/'),
            name: cookie.name,
            value: cookie.value,
            domain: 'webvpn.jmu.edu.cn',
            isSecure: cookie.secure,
          ),
    ]);
  }

  static Future<void> _clearVPNsValues() => SettingsUtil.setWebVpnToken(null);
}
