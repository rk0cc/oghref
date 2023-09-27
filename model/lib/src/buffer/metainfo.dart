import 'package:meta/meta.dart';

import '../model/metainfo.dart';
import '../parser/property_parser.dart' show MetaPropertyParser;
import 'immutable_buffer.dart';

export 'audio.dart';
export 'image.dart';
export 'video.dart';

/// Manage all values of [MetaInfo] during data apply state.
/// 
/// It is only available in [MetaPropertyParser.resolveMetaTags]
/// which appeared as a parameter.
abstract final class MetaInfoAssigner {
  /// Title of [MetaInfo].
  String? title;

  /// URL of [MetaInfo]
  Uri? url;

  /// Description of [MetaInfo]
  String? description;

  /// Site name of [MetaInfo]
  String? siteName;
  
  /// Provided [ImageInfo] for this [MetaInfo]. 
  final List<ImageInfo> images = [];

  /// Provided [VideoInfo] for this [MetaInfo]. 
  final List<VideoInfo> videos = [];

  /// Provided [AudioInfo] for this [MetaInfo]. 
  final List<AudioInfo> audios = [];

  MetaInfoAssigner._();
}

/// Actual parser of [MetaInfo].
/// 
/// This object should be marked as [internal] that
/// it should be offered as [MetaInfoAssigner]
/// already in [MetaPropertyParser.resolveMetaTags].
@internal
final class MetaInfoParser extends MetaInfoAssigner
    with ImmutableBuffer<MetaInfo> {
  /// Construct new parser for [MetaInfo]
  MetaInfoParser() : super._();

  @override
  MetaInfo compile() {
    return MetaInfo(
        title: title,
        url: url,
        description: description,
        siteName: siteName,
        images: List.of(images),
        videos: List.of(videos),
        audios: List.of(audios));
  }

  @override
  void reset() {
    title = null;
    url = null;
    description = null;
    siteName = null;
    for (List l in [images, videos, audios]) {
      l.clear();
    }
  }
}
