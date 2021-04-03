///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/30/20 1:31 PM
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputUtils {
  const InputUtils._();

  /// Method for insert text into provided [TextEditingController].
  /// 在提供的 [TextEditingController] 中插入指定文字的方法
  ///
  /// [state] After text was inserted, check if the [State] needs to update.
  /// 如果 [state] 有提供，将在插入文字后判断是否需要更新状态。
  ///
  /// [selectionOffset] Selection offset after text was inserted compare to the
  /// origin one.
  /// 插入文字后，可手动设置光标相对原本光标的偏移量。默认为文字长度。
  static int insertText({
    required String text,
    required TextEditingController controller,
    State<dynamic>? state,
    int? selectionOffset,
  }) {
    final TextEditingValue value = controller.value;
    final int start = value.selection.baseOffset;
    final int end = value.selection.extentOffset;

    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
      }
      controller.value = value.copyWith(
        text: newText,
        selection: value.selection.copyWith(
          baseOffset: end + (selectionOffset ?? text.length),
          extentOffset: end + (selectionOffset ?? text.length),
        ),
      );
      if (state?.mounted ?? false) {
        // ignore: invalid_use_of_protected_member
        state?.setState(() {});
      }
    }
    return controller.text.length;
  }

  /// Method for showing keyboard.
  /// 显示键盘方法
  static Future<void> showKeyboard() =>
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');

  /// Method for hiding keyboard.
  /// 隐藏键盘方法
  static Future<void> hideKeyboard() =>
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}
