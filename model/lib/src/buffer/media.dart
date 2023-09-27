import '../model/media.dart';

/// A mixin for assigning [MediaInfo] implemented parser.
abstract mixin class MediaInfoAssigner implements MediaInfo {
  @override
  String? type;
}

/// A mixin for assigning [ScalableInfo] implemented parser.
abstract mixin class ScalableInfoAssigner implements ScalableInfo {
  @override
  double? width;
  @override
  double? height;
}
