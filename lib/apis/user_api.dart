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

  static bool get isLogin => notifier.value != null;

  static UserModel get user => notifier.value!;

  static LoginModel? loginModel;

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
      loginModel = loginData;
      await HttpUtil.updateDomainsCookies(API.jmuHosts);
      final UserModel user = await HttpUtil.fetchModel(
        FetchType.get,
        url: API.userInfo,
        queryParameters: <String, String>{'uid': loginData.uid.toString()},
      );
      notifier.value = user;
      showToast('登录成功');
      HttpUtil.initializeWebViewCookie();
      return true;
    } catch (e) {
      showErrorToast('登录失败 ($e)');
      return false;
    }
  }

  static Future<bool> getTicket() async {
    return false;
    // try {
    //   LogUtil.d('Fetch new ticket with: ${_settingsBox.get(spTicket)}');
    //   final Map<String, dynamic> params = Constants.loginParams(
    //     blowfish: _settingsBox.get(spBlowfish) as String,
    //     ticket: _settingsBox.get(spTicket) as String,
    //   );
    //   final DateTime _start = currentTime;
    //   final Map<String, dynamic> response =
    //       (await NetUtils.tokenDio.post<Map<String, dynamic>>(
    //         API.loginTicket,
    //         data: params,
    //       ))
    //           .data;
    //   final DateTime _end = currentTime;
    //   LogUtil.d('Done request new ticket in: ${_end.difference(_start)}');
    //   updateSid(response); // Using 99.
    //   await NetUtils.updateDomainsCookies(API.ndHosts);
    //   await getUserInfo();
    //   return true;
    // } catch (e) {
    //   LogUtil.e('Error when getting ticket: $e');
    //   return false;
    // }
  }
}
