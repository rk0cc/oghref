import 'package:flutter/widgets.dart' hide protected;
import 'package:meta/meta.dart';

/// Calculating the ideal width under responsive
mixin WidthSizeMeasurement {
  /// Determine width of implemented widget.
  ///
  /// This method will measure width in [BoxConstraints.maxWidth] if
  /// [constraints] offered and [MediaQuery.sizeOf] when [constraints]
  /// does not offered or returned [double.infinity] which causes
  /// throw [AssertionError] due to unbounded widgets.
  @protected
  double calculateResponsiveWidth(BuildContext context,
      {BoxConstraints? constraints}) {
    // Try to get constraint max width or apply as unbounded width
    double measuredWidth = constraints?.maxWidth ?? double.infinity;

    if (measuredWidth.isInfinite) {
      // Uses width of devices or window instead if measured unbounded.
      measuredWidth = MediaQuery.sizeOf(context).width;
    }

    if (measuredWidth >= 1200) {
      measuredWidth /= 2.25;
    } else if (measuredWidth >= 992) {
      measuredWidth /= 2;
    } else if (measuredWidth >= 768) {
      measuredWidth /= 1.5;
    } else if (measuredWidth >= 564) {
      measuredWidth /= 1.125;
    }

    return measuredWidth;
  }
}
