import 'dart:collection';

import 'package:flutter/widgets.dart' hide protected;
import 'package:meta/meta.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch;

abstract base class MediaPlayback extends StatefulWidget {
  final List<Uri> playlists;

  MediaPlayback(Iterable<Uri> playlists, {super.key})
      : playlists = List.unmodifiable(playlists);

  @override
  MediaPlaybackStateMixin<MediaPlayback> createState();
}

base mixin MediaPlaybackStateMixin<T extends MediaPlayback> on State<T> {
  @protected
  late final Player player;

  @protected
  PlayerConfiguration? get playerConfiguration;

  @override
  void initState() {
    super.initState();
    player = Player(
        configuration: playerConfiguration ?? const PlayerConfiguration());
    _setPlayable();
  }

  void _setPlayable() async {
    final Map<String, String> requestHeader =
        UnmodifiableMapView({"User-agent": MetaFetch.userAgentString});

    if (widget.playlists.isNotEmpty) {
      await player.open(Playlist(widget.playlists
          .map((e) => Media("$e", httpHeaders: requestHeader))
          .toList()));
    }
  }

  void _playerDisposeSync() async {
    await player.dispose();
  }

  @override
  void dispose() {
    _playerDisposeSync();
    super.dispose();
  }
}

base mixin VideoPlaybackStateMixin<T extends MediaPlayback>
    on MediaPlaybackStateMixin<T> {
  @protected
  late final VideoController videoController;

  @protected
  VideoControllerConfiguration? get videoControllerConfiguration;

  @override
  void initState() {
    super.initState();
    videoController = VideoController(player,
        configuration: videoControllerConfiguration ??
            const VideoControllerConfiguration());
  }
}
