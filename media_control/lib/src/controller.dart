import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:meta/meta.dart';

enum Replay {
  none,
  all,
  once
}

@immutable
final class MediaInfo {
  final Duration length;
  final String? label;

  const MediaInfo({required this.length, this.label});
}

final class MediaPlaybackController extends ChangeNotifier {
  
}