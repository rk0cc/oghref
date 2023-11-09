import 'package:flutter/widgets.dart' hide protected;
import 'package:meta/meta.dart';

/// Calculating the ideal width under responsive
mixin WidthSizeMeasurement {
  /// Determine width of implemented widget.
  @protected
  double calculateResponsiveWidth(BuildContext context) {
    double measuredWidth = MediaQuery.sizeOf(context).width;

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
