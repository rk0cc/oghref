import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:http/http.dart' as http show head;
import 'package:http/http.dart' show Response;

/// A [Widget] for handle audio and video playback if offered.
final class MediaPlayback extends StatefulWidget {
  static const List<String> _protocolWhitelist = <String>["http", "https"];

  /// Video, audio or both resources in URL.
  ///
  /// If the given resources is audio type, it retains
  /// an empty [Widget] but still functional when hovering
  /// this area for changing media position.
  final List<Uri> resources;

  /// Define behaviour of player.
  final PlayerConfiguration configuration;

  /// Define behaviour of video controller.
  final VideoControllerConfiguration? videoCtrlConfiguration;

  /// Display context when content is loading.
  final WidgetBuilder? onLoading;

  /// Display another [Widget] that either containing at least one
  /// non-playable [resources] or failed to retrive MIME by HTTP
  /// HEAD request.
  final WidgetBuilder onLoadFailed;

  /// Construct [MediaPlayback] with predefined preferences.
  MediaPlayback(Iterable<Uri> resources,
      {required this.onLoadFailed,
      this.onLoading,
      this.configuration = const PlayerConfiguration(
          muted: true, protocolWhitelist: _protocolWhitelist),
      this.videoCtrlConfiguration,
      super.key})
      : resources = List.unmodifiable(resources);

  @override
  State<StatefulWidget> createState() => _MediaPlaybackState();
}

final class _MediaPlaybackState extends State<MediaPlayback> {
  late Future<bool> allPlayable;

  @override
  void initState() {
    super.initState();
    allPlayable = _playableCond();
  }

  @override
  void didUpdateWidget(MediaPlayback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!const ListEquality().equals(oldWidget.resources, widget.resources)) {
      allPlayable = _playableCond();
    }
  }

  Future<bool> _playableCond() async {
    Stream<Response> resps =
        Stream.fromFutures(widget.resources.map((e) => http.head(e)));

    return resps.every((r) {
      String? mime = r.headers["content-type"]?.split(';').first;

      if (mime != null) {
        return RegExp(
                r"^(audio|video)\/((?:x-)?(?:[\w-]+\.)*[\w-]+(?:\+[\w-]+)?)$",
                dotAll: true,
                caseSensitive: false)
            .hasMatch(mime);
      }

      return false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(future: allPlayable, builder: (context, snapshot) {
      if (snapshot.hasError) {
        return widget.onLoadFailed(context);
      } else if (!snapshot.hasData) {
        return (widget.onLoading ?? () => const SizedBox())();
      }

      return snapshot.data! ? _MediaPlaybackRender(widget.resources) : widget.onLoadFailed(context);
    });
  }
}

final class _MediaPlaybackRender extends StatefulWidget {
  final List<Uri> resources;

  _MediaPlaybackRender(this.resources, {super.key});
  
  @override
  _MediaPlaybackRenderState createState() => _MediaPlaybackRenderState();
}

final class _MediaPlaybackRenderState extends State<_MediaPlaybackRender> {
  late final Player player;
  late final VideoController vidCtrl;

  @override
  void initState() {
    super.initState();
    player = Player(configuration: PlayerConfiguration(
      muted: true,
      ready: () async {
        await player.pause();
      }
    ));
    vidCtrl = VideoController(player);

    player.open(Playlist(widget.resources.map((e) => Media(e.toString())).toList()));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Video(controller: vidCtrl, controls: AdaptiveVideoControls);
  }
}