import 'dart:io' show Platform;

import 'package:meta/meta.dart';

@internal
bool get runningInTest => Platform.environment.containsKey("FLUTTER_TEST");
