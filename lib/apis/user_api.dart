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
