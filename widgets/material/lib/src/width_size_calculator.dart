import 'package:flutter/material.dart' hide protected, immutable;
import 'package:meta/meta.dart';

@internal
mixin ResponsiveWidthSizeCalculator {

  @protected
  double calculateResponsiveWidth(BuildContext context) {
    final double currentWidth = MediaQuery.sizeOf(context).width;

    if (currentWidth < 576) {
      return currentWidth;
    } else if  (currentWidth < 768) {
      return currentWidth / 1.5;
    } else if (currentWidth < 1200) {
      return currentWidth / 2;
    }

    return currentWidth / 2.25;
  }
}