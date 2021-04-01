///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-02 00:09
///
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:jmu_tools/utils/log_util.dart';
import 'package:uuid/uuid.dart';

class DeviceUtil {
  const DeviceUtil._();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static dynamic deviceInfo;

  static String deviceModel = 'OpenJMU Device';
  static String? devicePushToken;
  static late final String deviceUuid;

  static Future<void> initDeviceInfo() {
    return Future.wait(<Future<void>>[
      getModel(),
      // getDevicePushToken(),
      getDeviceUuid(),
    ]);
  }

  static Future<void> getModel() async {
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

  static Future<void> getDeviceUuid() async {
    // if (HiveFieldUtils.getDeviceUuid() != null) {
    //   deviceUuid = HiveFieldUtils.getDeviceUuid();
    // } else {
    //   if (Platform.isIOS) {
    //     deviceUuid = (deviceInfo as IosDeviceInfo).identifierForVendor;
    //   } else {
    //     await HiveFieldUtils.setDeviceUuid(const Uuid().v4());
    //   }
    // }
    deviceUuid = const Uuid().v4();
    LogUtil.d('deviceUuid: $deviceUuid');
  }
}
