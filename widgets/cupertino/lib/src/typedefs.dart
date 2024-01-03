import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Declare confirmation before opening [targetUrl].
///
/// This features must returns [bool] via user interaction
/// (i.e. [showCupertinoDialog]).
typedef BeforeOpenLinkConfirmation = FutureOr<bool> Function(
    BuildContext context, Uri targetUrl);
