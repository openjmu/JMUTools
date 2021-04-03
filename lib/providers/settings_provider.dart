///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-03 00:46
///
part of '../exports/providers.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _fontScale = SettingsUtil.getFontScale() ?? _fontScale;
    _homeSplashIndex = SettingsUtil.getHomeSplashIndex() ?? _homeSplashIndex;
    _launchWebAppFromSystem =
        SettingsUtil.getLaunchWebAppFromSystem() ?? _launchWebAppFromSystem;
  }

  void reset() {
    _fontScale = DeviceUtil.deviceModel.contains('iPad') ? 0.5 : 1.0;
    _homeSplashIndex = 0;
    _launchWebAppFromSystem = false;
    notifyListeners();
  }

  List<double> fontScaleRange = DeviceUtil.deviceModel.contains('iPad')
      ? <double>[0.3, 0.7]
      : <double>[0.8, 1.2];
  double _fontScale = DeviceUtil.deviceModel.contains('iPad') ? 0.5 : 1.0;

  double get fontScale => _fontScale;

  set fontScale(double value) {
    if (_fontScale == value) {
      return;
    }
    _fontScale = value;
    SettingsUtil.setFontScale(value);
    rebuildAllChildren(Instances.appKey.currentContext);
    notifyListeners();
  }

  /// 启动的页面索引
  int _homeSplashIndex = 0;

  int get homeSplashIndex => _homeSplashIndex;

  set homeSplashIndex(int value) {
    if (_homeSplashIndex == value) {
      return;
    }
    _homeSplashIndex = value;
    SettingsUtil.setHomeSplashIndex(value);
    notifyListeners();
  }

  /// 是否通过
  bool _launchWebAppFromSystem = false;

  bool get launchWebAppFromSystem => _launchWebAppFromSystem;

  set launchWebAppFromSystem(bool value) {
    if (_launchWebAppFromSystem == value) {
      return;
    }
    _launchWebAppFromSystem = value;
    SettingsUtil.setLaunchWebAppFromSystem(value);
    notifyListeners();
  }
}
