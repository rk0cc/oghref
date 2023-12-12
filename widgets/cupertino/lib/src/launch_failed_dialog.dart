import 'package:flutter/cupertino.dart' hide protected, immutable;
import 'package:meta/meta.dart';

@internal
mixin LaunchFailedDialogHandler {
  String get launchFailedMessage;
  String get okText;

  @protected
  void showLaunchFailedDialog(BuildContext context) {
    showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
                content: Text(launchFailedMessage),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop<void>(context);
                      },
                      isDefaultAction: true,
                      child: Text(okText))
                ]));
  }
}
