import 'package:flutter/material.dart' hide protected, immutable;
import 'package:meta/meta.dart';

@internal
mixin ResponsiveWidthSizeCalculator {
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
