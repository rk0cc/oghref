// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:meta/meta.dart';

@internal
String? get requestUserAgent => window.navigator.userAgent;