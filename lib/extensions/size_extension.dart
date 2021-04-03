///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/9/7 16:56
///
// import 'package:flutter_screenutil/flutter_screenutil.dart' hide SizeExtension;
import '../constants/screens.dart';

/// dp => px
extension DP2PXExtension on double {
  int get px => (this * Screens.scale).toInt();
}

/// px => dp
extension PX2DPExtension on int {
  double get dp => this / Screens.scale;
}

/// 避免报错
// TODO(Alex): 如果需要等比例适配，将其移除。
extension SizeDoubleExtension on num {
  double get w => toDouble();

  double get h => toDouble();

  double get sp => toDouble();

  double get ssp => toDouble();

  double get nsp => toDouble();

  double get wp => toDouble();

  double get hp => toDouble();
}

// /// ScreenUtil 的封装，用于快速等比例缩放
// ///
// /// 通过使用扩展方法，我们可以直接将适配应用到数值上。
// /// 例如：`10.w`，代表以 10 逻辑像素对内容做适配。
// TODO(Alex): 尚不清楚是否需要等比例适配，暂时禁用。
// extension SizeDoubleExtension on num {
//   /// [ScreenUtil.setWidth]
//   double get w => ScreenUtil().setWidth(this).toDouble();
//
// //   /// [ScreenUtil.setHeight]
// //   ///
// //   /// 通常我们不会使用这个方法，因为项目一般是锁定竖屏的，只需要用 [w] 进行定位即可
// //   double get h => ScreenUtil().setHeight(this).toDouble();
//
//   /// [ScreenUtil.setSp]
//   double get sp => ScreenUtil().setSp(this).toDouble();
//
//   /// [ScreenUtil.setSp]
//   double get ssp => ScreenUtil()
//       .setSp(
//         this,
//         allowFontScalingSelf: true,
//       )
//       .toDouble();
//
//   /// [ScreenUtil.setSp]
//   double get nsp => ScreenUtil()
//       .setSp(
//         this,
//         allowFontScalingSelf: false,
//       )
//       .toDouble();
//
//   /// 屏幕宽度的倍数
//   /// Multiple of screen width.
//   double get wp => (ScreenUtil.screenWidth * this).toDouble();
//
//   /// 屏幕高度的倍数
//   /// Multiple of screen height.
//   double get hp => (ScreenUtil.screenHeight * this).toDouble();
// }
