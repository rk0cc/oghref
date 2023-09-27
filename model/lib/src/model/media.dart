/// Denote this information represents as multimedia form.
abstract interface class MediaInfo {
  /// MIME type of given media.
  String? get type;
}

/// Define the media size when display visual media.
abstract interface class ScalableInfo {
  /// Width of visual.
  double? get width;

  /// Height of visual.
  double? get height;
}
