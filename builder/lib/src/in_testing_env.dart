import 'package:meta/meta.dart';

/// Determine is running in test.
///
/// If call it from Dart VM, it will check [Map.containsKey]
/// from environment. Otherwise, return `false`.
@internal
bool get runningInTest => false;
