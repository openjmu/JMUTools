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

  static const String _userWorkId = 'user_work_id';

  static const String _brightnessDark = 'theme_brightness';
  static const String _colorThemeIndex = 'theme_colorThemeIndex';

  static const String _settingFontScale = 'setting_font_scale';
  static const String _settingHomeSplashIndex = 'setting_home_splash_index';
  static const String _settingLaunchWebAppFromSystem =
      'setting_launch_web_app_from_system';

  static const String _devicePushToken = 'device_push_token';
  static const String _deviceUUID = 'device_uuid';

  static const String _webVpnToken = 'webvpn_token';

  /// 获取上一次登录的工号
  static String? getUserWorkId() => _box.get(_userWorkId) as String?;

  /// 设置当前登录的工号
  static Future<void> setUserWorkId(String value) =>
      _box.put(_userWorkId, value);

  /// 获取设置的夜间模式
  static bool getBrightnessDark() =>
      _box.get(_brightnessDark) as bool? ?? false;

  /// 设置选择的夜间模式
  static Future<void> setBrightnessDark(bool value) =>
      _box.put(_brightnessDark, value);

  /// 获取设置的主题色
  static int getColorThemeIndex() => _box.get(_colorThemeIndex) as int? ?? 0;

  /// 设置选择的主题色
  static Future<void> setColorThemeIndex(int value) =>
      _box.put(_colorThemeIndex, value);

  /// 获取字体缩放设置
  static double? getFontScale() => _box.get(_settingFontScale) as double?;

  /// 设置字体缩放
  static Future<void> setFontScale(double scale) =>
      _box.put(_settingFontScale, scale);

  /// 获取默认启动页index
  static int? getHomeSplashIndex() => _box.get(_settingHomeSplashIndex) as int?;

  /// 设置首页的初始页
  static Future<void> setHomeSplashIndex(int index) =>
      _box.put(_settingHomeSplashIndex, index);

  /// 获取是否通过系统浏览器打开网页
  static bool? getLaunchWebAppFromSystem() =>
      _box.get(_settingLaunchWebAppFromSystem) as bool?;

  /// 设置是否通过系统浏览器打开网页
  static Future<void> setLaunchWebAppFromSystem(bool enable) =>
      _box.put(_settingLaunchWebAppFromSystem, enable);

  /// 获取设备 PushToken
  static String? getDevicePushToken() => _box.get(_devicePushToken) as String?;

  /// 写入 PushToken
  static Future<void> setDevicePushToken(String value) {
    DeviceUtil.devicePushToken = value;
    return _box.put(_devicePushToken, value);
  }

  /// 获取设备 UUID
  static String? getDeviceUUID() => _box.get(_deviceUUID) as String?;

  /// 写入 UUID
  static Future<void> setDeviceUUID(String value) =>
      _box.put(_deviceUUID, value);

  /// 获取 WebVPN Token
  static String getWebVpnToken() => _box.get(_webVpnToken) as String;

  /// 写入 WebVPN Token
  static Future<void> setWebVpnToken(String value) =>
      _box.put(_webVpnToken, value);
}
