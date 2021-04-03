///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 20:58
///
import 'package:flutter/foundation.dart';
import 'package:jmu_tools/exports/export.dart';

class UserAPI {
  const UserAPI._();

  static final ValueNotifier<UserModel?> notifier =
      ValueNotifier<UserModel?>(null);

  static bool get isLogin => _loginModel != null;

  static UserModel get user => notifier.value!;

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

  static void recoverLoginInfo() {
    _loginModel = Boxes.loginBox.get(0);
  }

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
      loginModel = loginData.copyWith(blowfish: blowfish);
      await HttpUtil.updateDomainsCookies(API.jmuHosts);
      final UserModel user = await HttpUtil.fetchModel(
        FetchType.get,
        url: API.userInfo,
        queryParameters: <String, String>{'uid': loginData.uid.toString()},
      );
      notifier.value = user;
      // 存储 blowfish 和学工号
      SettingsUtil.setUserWorkId(username);
      // 根据信息初始化 WebView 的 Cookie
      HttpUtil.initializeWebViewCookie();
      showToast('登录成功');
      return true;
    } catch (e) {
      showErrorToast('登录失败 ($e)');
      return false;
    }
  }

  static Future<bool> getTicket() async {
    if (_loginModel == null) {
      LogUtil.e('Ticket and blowfish does not exist.');
      return false;
    }
    final String ticket = _loginModel!.ticket!;
    final String blowfish = _loginModel!.blowfish!;
    try {
      LogUtil.d('Fetch new ticket with: $ticket');
      final LoginModel res = await HttpUtil.fetchModel(
        FetchType.post,
        url: API.loginTicket,
        body: Constants.loginParams(blowfish: blowfish, ticket: ticket),
      );
      loginModel = _loginModel!.merge(res);
      await HttpUtil.updateDomainsCookies(API.jmuHosts);
      return true;
    } catch (e) {
      LogUtil.e('Error when getting ticket: $e');
      return false;
    }
  }
}
