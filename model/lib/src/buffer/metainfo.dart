import 'package:meta/meta.dart';

import '../model/metainfo.dart';
import 'immutable_buffer.dart';

export 'audio.dart';
export 'image.dart';
export 'video.dart';

abstract final class MetaInfoAssigner {
  String? title;
  Uri? url;
  String? description;
  String? siteName;
  final List<ImageInfo> images = [];
  final List<VideoInfo> videos = [];
  final List<AudioInfo> audios = [];

  MetaInfoAssigner._();
}

@internal
final class MetaInfoParser extends MetaInfoAssigner
    with ImmutableBuffer<MetaInfo> {
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
