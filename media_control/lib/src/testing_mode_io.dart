import 'dart:io' show Platform;

import 'package:meta/meta.dart';

@internal
bool get isTesting => Platform.environment.containsKey("FLUTTER_TEST");