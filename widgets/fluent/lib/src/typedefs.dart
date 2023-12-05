import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

typedef BeforeOpenLinkConfirmation = FutureOr<bool> Function(
    BuildContext context, Uri targetUrl);
