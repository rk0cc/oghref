import '../model/media.dart';

/// A mixin for assigning [MediaInfo] implemented parser.
abstract mixin class MediaInfoAssigner {
  /// Define MIME type.
  String? type;
}

/// A mixin for assigning [ScalableInfo] implemented parser.
abstract mixin class ScalableInfoAssigner {
  /// Define width.
  double? width;

  /// Define height.
  double? height;
}
