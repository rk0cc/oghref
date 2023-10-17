import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch;

import 'aspect_ratio.dart';

/// A [Widget] for handling media playback.
///
/// This widget has unbounded constraint that it causes build error
/// if parent [Widget] cannot provide either width or height.
final class MediaPlayback extends StatefulWidget {
  /// Video, audio or both resources in URL.
  ///
  /// If the given resources is audio type, it retains
  /// an empty [Widget] but still functional when hovering
  /// this area for changing media position.
  final List<Uri> resources;

  /// Define behaviour of player.
  final PlayerConfiguration? configuration;

  /// Define behaviour of video controller.
  final VideoControllerConfiguration? videoCtrlConfiguration;

  /// Aspect ratio for wrapping playback widgets.
  final AspectRatioValue aspectRatio;

  /// Specify video control [Widget] will be rendered in video
  /// frame.
  final VideoControlsBuilder controlsBuilder;

  /// Construct a playback widgets with given resources.
  MediaPlayback(Iterable<Uri> resources,
      {required this.controlsBuilder,
      this.configuration,
      this.videoCtrlConfiguration,
      this.aspectRatio = AspectRatioValue.standardHD,
      super.key})
      : resources = List.unmodifiable(resources);

  /// Locate [VideoController] for take control of playback state externally.
  static VideoController? of(BuildContext context) {
    return context.findAncestorStateOfType<_MediaPlaybackState>()?.videoCtrl;
  }

  @override
  State<MediaPlayback> createState() {
    return _MediaPlaybackState();
  }
}

final class _MediaPlaybackState extends State<MediaPlayback> {
  late final Player player;
  late final VideoController videoCtrl;

  @override
  void initState() {
    super.initState();
    player = Player(
        configuration: widget.configuration ?? const PlayerConfiguration());
    videoCtrl = VideoController(player,
        configuration: widget.videoCtrlConfiguration ??
            const VideoControllerConfiguration());

    _openMedia();
  }

  void _openMedia() {
    final Map<String, String> httpHeaders = {
      "user-agent": MetaFetch.userAgentString
    };

    List<Media> medias = widget.resources
        .map((e) => Media("$e", httpHeaders: httpHeaders))
        .toList(growable: false);

    player.open(Playlist(medias), play: false);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.aspectRatio.applyToWidget(
        child: Video(controller: videoCtrl, controls: widget.controlsBuilder));
  }
}
