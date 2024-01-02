import 'package:flutter/material.dart' hide protected, immutable;
import 'package:meta/meta.dart';

/// Activate [SnackBar] appearance when given link no longer be
/// accessible.
/// 
/// This mixin must be mixed with [State], [StatelessWidget] or
/// classes with `build` function.
@internal
mixin LaunchFailedSnackBarHandler {
  /// Message content when launch failed.
  String get launchFailedMessage;

  /// Toggle display [SnackBar] if unable to open link.
  @protected
  void showLaunchFailedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(launchFailedMessage)));
  }
}
