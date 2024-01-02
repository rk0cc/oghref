import 'package:fluent_ui/fluent_ui.dart' hide protected, immutable;
import 'package:meta/meta.dart';

/// A mixin class which mixes [StatelessWidget] or [State] to handle
/// URL launch failed event which popping [InfoBar] up.
@internal
mixin LaunchFailedInfoBarHandler {
  /// Message display in [InfoBar] to inform user about launching error.
  String get launchFailedMessage;

  /// Activate display [InfoBar] if unable to open link.
  @protected
  void showLaunchFailedInfoBar(BuildContext context) {
    displayInfoBar(context,
        duration: const Duration(seconds: 10),
        builder: (context, close) => InfoBar(
            title: Text(launchFailedMessage),
            severity: InfoBarSeverity.error,
            action: IconButton(
                icon: const Icon(FluentIcons.clear), onPressed: close)));
  }
}
