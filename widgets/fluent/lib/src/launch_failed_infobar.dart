import 'package:fluent_ui/fluent_ui.dart' hide protected, immutable;
import 'package:meta/meta.dart';

@internal
mixin LaunchFailedInfoBarHandler {
  String get launchFailedMessage;
  
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
