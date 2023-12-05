import 'dart:async';

import 'package:flutter/material.dart';

typedef BeforeOpenLinkConfirmation = FutureOr<bool> Function(
    BuildContext context, Uri targetUrl);
