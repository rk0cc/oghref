import 'package:flutter/cupertino.dart' hide protected, immutable;
import 'package:meta/meta.dart';

/// A mixin class which mixes [StatelessWidget] or [State] to handle
/// URL launch failed event which popping [CupertinoAlertDialog] up
/// which is one and only method can be notified user in Cupertino
/// [Widget] library.
@internal
mixin LaunchFailedDialogHandler {
  /// Message display in [CupertinoAlertDialog] to inform about launch
  /// failure.
  String get launchFailedMessage;

  /// A [String] for showing [Text] of [CupertinoDialogAction]
  /// that user has been acknowledge and close dialog when
  /// pressed.
  String get okText;

  /// Activate showing [CupertinoAlertDialog] if failed to
  /// launch website.
  @protected
  void showLaunchFailedDialog(BuildContext context) async {
    await showCupertinoDialog<void>(
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
