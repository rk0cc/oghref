import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

/// Replicate Material's divider in Cupertino themes.
@internal
final class CupertinoDivider extends StatelessWidget {
  /// Create divider.
  const CupertinoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    const double height = 5;
    const double thickness = 1.25;

    return SizedBox(
        height: height,
        child: Center(
            child: Container(
                height: thickness,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(thickness / 2)),
                    border: Border(
                        bottom: BorderSide(
                            color: CupertinoColors.inactiveGray.withAlpha(128),
                            width: thickness))))));
    // Tile link
  }
}
