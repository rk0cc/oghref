import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

/// Declare confirmation before opening [targetUrl].
///
/// This features must returns [bool] via user interaction
/// (i.e. [showDialog]).
typedef BeforeOpenLinkConfirmation = FutureOr<bool> Function(
    BuildContext context, Uri targetUrl);
