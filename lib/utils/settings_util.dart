///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-02 22:58
///
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:jmu_tools/constants/boxes.dart';
import 'package:jmu_tools/constants/instances.dart';
import 'package:jmu_tools/exports/providers.dart';
import 'package:jmu_tools/utils/device_util.dart';

class SettingsUtil {
  const SettingsUtil._();

  static Box<dynamic> get _box => Boxes.settingsBox;

  static SettingsProvider get provider => Provider.of<SettingsProvider>(
        currentContext,
        listen: false,
      );

  static const String userWorkId = 'user_work_id';

  static const String brightnessDark = 'theme_brightness';
  static const String colorThemeIndex = 'theme_colorThemeIndex';

  static const String settingFontScale = 'setting_font_scale';
  static const String settingHomeSplashIndex = 'setting_home_splash_index';
  static const String settingLaunchWebAppFromSystem =
      'setting_launch_web_app_from_system';

  static const String devicePushToken = 'device_push_token';
  static const String deviceUUID = 'device_uuid';

  static const String webVpnKey = 'webvpn_key';
  static const String webVpnSession = 'webvpn_session';
  static const String webVpnToken = 'webvpn_token';
  static const String webVpnUsername = 'webvpn_username';

  /// 获取上一次登录的工号
  static String? getUserWorkId() => _box.get(userWorkId) as String?;

  /// 设置当前登录的工号
  static Future<void> setUserWorkId(String value) =>
      _box.put(userWorkId, value);

  /// 获取设置的夜间模式
  static bool getBrightnessDark() => _box.get(brightnessDark) as bool? ?? false;

  /// 设置选择的夜间模式
  static Future<void> setBrightnessDark(bool value) =>
      _box.put(brightnessDark, value);

  /// 获取设置的主题色
  static int getColorThemeIndex() => _box.get(colorThemeIndex) as int? ?? 0;

  /// 设置选择的主题色
  static Future<void> setColorThemeIndex(int value) =>
      _box.put(colorThemeIndex, value);

  /// 获取字体缩放设置
  static double? getFontScale() => _box.get(settingFontScale) as double?;

  /// 设置字体缩放
  static Future<void> setFontScale(double scale) =>
      _box.put(settingFontScale, scale);

  /// 获取默认启动页index
  static int? getHomeSplashIndex() => _box.get(settingHomeSplashIndex) as int?;

  /// 设置首页的初始页
  static Future<void> setHomeSplashIndex(int index) =>
      _box.put(settingHomeSplashIndex, index);

  /// 获取是否通过系统浏览器打开网页
  static bool? getLaunchWebAppFromSystem() =>
      _box.get(settingLaunchWebAppFromSystem) as bool?;

  /// 设置是否通过系统浏览器打开网页
  static Future<void> setLaunchWebAppFromSystem(bool enable) =>
      _box.put(settingLaunchWebAppFromSystem, enable);

  /// 获取设备 PushToken
  static String getDevicePushToken() => _box.get(devicePushToken) as String;

  /// 写入 PushToken
  static Future<void> setDevicePushToken(String value) {
    DeviceUtil.devicePushToken = value;
    return _box.put(devicePushToken, value);
  }

  /// 获取设备 UUID
  static String getDeviceUuid() => _box.get(deviceUUID) as String;

  /// 写入 UUID
  static Future<void> setDeviceUuid(String value) {
    DeviceUtil.deviceUUID = value;
    return _box.put(deviceUUID, value);
  }

  /// 获取 WebVPN Token
  static String getWebVpnToken() => _box.get(webVpnToken) as String;

  /// 写入 WebVPN Token
  static Future<void> setWebVpnToken(String value) =>
      _box.put(webVpnToken, value);
}
