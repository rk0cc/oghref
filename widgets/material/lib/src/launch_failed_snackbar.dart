import 'package:flutter/material.dart' hide protected, immutable;
import 'package:meta/meta.dart';

@internal
mixin LaunchFailedSnackBarHandler {
  String get launchFailedMessage;
  @protected
  void showLaunchFailedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(launchFailedMessage)));
  }
}
