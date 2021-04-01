///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/1/21 4:49 PM
///
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dartx/dartx.dart';
import 'package:jmu_tools/exports/utils.dart';

class Constants {
  const Constants._();

  /// Fow news list.
  static final int appId = Platform.isIOS ? 274 : 273;
  static const String apiKey = 'c2bd7a89a377595c1da3d49a0ca825d5';
  static const String cloudId = 'jmu';
  static final String deviceType = Platform.isIOS ? 'iPhone' : 'Android';
  static const int marketTeamId = 430;
  static const String unitCode = 'jmu';
  static const int unitId = 55;

  static Map<String, dynamic> get loginClientInfo => <String, dynamic>{
        'appid': appId,
        if (Platform.isIOS) 'packetid': '',
        'platform': Platform.isIOS ? 40 : 30,
        'platformver': Platform.isIOS ? '2.3.2' : '2.3.1',
        'deviceid': DeviceUtil.deviceUuid,
        'devicetype': deviceType,
        'systype': '$deviceType OS',
        'sysver': Platform.isIOS ? '12.2' : '9.0',
      };

  static Map<String, dynamic> loginParams({
    required String blowfish,
    String? username,
    String? password,
    String? ticket,
  }) {
    return <String, dynamic>{
      'appid': appId,
      'blowfish': blowfish,
      if (ticket != null) 'ticket': ticket,
      if (username != null) 'account': username,
      if (password != null) 'password': '${sha1.convert(password.toUtf8())}',
      if (password != null) 'encrypt': 1,
      if (username != null) 'unitid': unitId,
      if (username != null) 'unitcode': 'jmu',
      'clientinfo': jsonEncode(loginClientInfo),
    };
  }
}
