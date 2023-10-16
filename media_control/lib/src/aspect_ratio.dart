import 'package:flutter/widgets.dart' show AspectRatio, Widget;
import 'package:meta/meta.dart';

/// Define aspect ratio of player.
@immutable
final class AspectRatioValue {
  /// Definition of high definition ratio (16:9).
  static const AspectRatioValue standardHD = AspectRatioValue._(16, 9);

  /// Definition of standard defition ratio (4:3).
  static const AspectRatioValue standardSD = AspectRatioValue._(4, 3);

  /// Definition of square ratio which all sides length are equals (1:1).
  static const AspectRatioValue square = AspectRatioValue._(1, 1);

  /// Length ratio in horizontal.
  final double width;

  /// Length ratio in vertical.
  final double height;

  /// Create [AspectRatioValue] can be defined under constant.
  const AspectRatioValue._(this.width, this.height);

  /// Create custom value of [AspectRatioValue].
  /// 
  /// The applied [width] and [height] must be [double.isFinite].
  /// Applying non-finite value will lead to throw [ArgumentError].
  factory AspectRatioValue(double width, double height) {
    if (!width.isFinite || !height.isFinite) {
      throw ArgumentError("Width and height should be a finite number.");
    }

    return AspectRatioValue._(width, height);
  }

  /// Calculate height value from given [width].
  double calcHeightFromWidth(double width) {
    return width * height / this.width;
  }

  /// Calculate width value from given [height].
  double calcWidthFromHeight(double height) {
    return height * width / this.height;
  }

  /// Swap [width] and [height] such that the ratio will formed as
  /// portrait if origin [width] is bigger than [height] and
  /// landscape if vice versa.
  AspectRatioValue swapRatio() => AspectRatioValue._(height, width);

  /// Get divided value of [width] : [height]
  double get value => width / height;

  static String _approximateDoubleNotation(double value) {
    if (value % 1 == 0) {
      return "${value.toInt()}";
    }

    return value.toStringAsPrecision(3);
  }

  @override
  String toString() {
    return "${_approximateDoubleNotation(width)}:${_approximateDoubleNotation(height)}";
  }
}

/// Wrap [AspectRatioValue.value] into [AspectRatio].
@internal
extension AspectRatioWidgetExtension on AspectRatioValue {
  /// Apply current [value] into [AspectRatio] and wrap with
  /// [child].
  AspectRatio applyToWidget({required Widget child}) {
    return AspectRatio(aspectRatio: value, child: child);
  }
}
