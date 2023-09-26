import '../model/media.dart';

abstract mixin class MediaInfoAssigner implements MediaInfo {
  @override
  String? type;
}

abstract mixin class ScalableInfoAssigner implements ScalableInfo {
  @override
  double? width;
  @override
  double? height;
}
