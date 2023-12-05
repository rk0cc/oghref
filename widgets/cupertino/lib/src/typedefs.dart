import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef BeforeOpenLinkConfirmation = FutureOr<bool> Function(
    BuildContext context, Uri targetUrl);
