import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

abstract base class MediaPlayback extends StatefulWidget {
  final List<Uri> playlists;

  MediaPlayback(Iterable<Uri> playlists, {super.key}) : playlists = List.unmodifiable(playlists);

  @override
  MediaPlaybackStateMixin<MediaPlayback> createState();
}

mixin MediaPlaybackStateMixin<T extends MediaPlayback> on State<T> {
  late final Player player;
  

  @override
  void initState() {
    
    super.initState();
  }
}

