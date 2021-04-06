///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-02 00:09
///
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'log_util.dart';
import 'settings_util.dart';

class DeviceUtil {
  const DeviceUtil._();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static dynamic deviceInfo;

  static String deviceModel = 'OpenJMU Device';
  static String? devicePushToken;
  static late final String deviceUUID;

  static Future<void> initDeviceInfo() {
    return Future.wait(<Future<void>>[
      initModel(),
      // getDevicePushToken(),
      initDeviceUuid(),
    ]);
  }

  static Future<void> initModel() async {
    if (Platform.isAndroid) {
      deviceInfo = await _deviceInfoPlugin.androidInfo;
      final AndroidDeviceInfo androidInfo = deviceInfo as AndroidDeviceInfo;

      final String model = '${androidInfo.brand} ${androidInfo.product}';
      deviceModel = model;
    } else if (Platform.isIOS) {
      deviceInfo = await _deviceInfoPlugin.iosInfo;
      final IosDeviceInfo iosInfo = deviceInfo as IosDeviceInfo;

      final String model =
          '${iosInfo.model} ${iosInfo.utsname.machine} ${iosInfo.systemVersion}';
      deviceModel = model;
    }

    LogUtil.d('deviceModel: $deviceModel');
  }

  static Future<void> getDevicePushToken() async {
    // if (Platform.isIOS) {
    //   final String? _savedToken = HiveFieldUtils.getDevicePushToken();
    //   // final String _tempToken = await ChannelUtils.iOSGetPushToken();
    //   if (_savedToken != null) {
    //     if (_savedToken != _tempToken) {
    //       await HiveFieldUtils.setDevicePushToken(_tempToken);
    //     } else {
    //       devicePushToken = HiveFieldUtils.getDevicePushToken();
    //     }
    //   } else {
    //     await HiveFieldUtils.setDevicePushToken(_tempToken);
    //   }
    //   LogUtil.d('devicePushToken: $devicePushToken');
    // }
  }

  static Future<void> initDeviceUuid() async {
    if (SettingsUtil.getDeviceUUID() != null) {
      deviceUUID = SettingsUtil.getDeviceUUID()!;
    } else {
      final dynamic info = deviceInfo;
      if (info is IosDeviceInfo && info.identifierForVendor != null) {
        deviceUUID = info.identifierForVendor!;
      } else {
        deviceUUID = const Uuid().v4();
      }
    }
    LogUtil.d('deviceUuid: $deviceUUID');
    await SettingsUtil.setDeviceUUID(deviceUUID);
  }
}
