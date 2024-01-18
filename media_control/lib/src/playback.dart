import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:http/http.dart' show Response, Client;

import 'client.dart';
import 'testing_mode.dart' if (dart.library.io) 'testing_mode_io.dart';
import 'ua.dart' if (dart.library.html) 'ua_web.dart';

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
  ///
  /// It should not be built during widget test due to
  /// behavourial of [Dart's built in client](https://api.dart.dev/stable/dart-io/HttpClient-class.html).
  /// Therefore, [UnsupportedError] will be thrown if attempted to
  /// build it.
  MediaPlayback(Iterable<Uri> resources,
      {required this.onLoadFailed,
      this.onLoading,
      this.configuration = const PlayerConfiguration(
          muted: true, protocolWhitelist: _protocolWhitelist),
      this.videoCtrlConfiguration,
      super.key})
      : resources = List.unmodifiable(resources) {
    if (isTesting) {
      throw UnsupportedError(
          "No real network interaction allowed during test, and it should never be built.");
    }
  }

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
  void didUpdateWidget(covariant MediaPlayback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!const ListEquality().equals(oldWidget.resources, widget.resources)) {
      allPlayable = _playableCond();
    }
  }

  Future<bool> _playableCond() async {
    final Client c = OgHrefMediaClient();

    Stream<Response> resps =
        Stream.fromFutures(widget.resources.map((e) => c.head(e)));

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
    }).then((value) {
      c.close();
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: allPlayable,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return widget.onLoadFailed(context);
          } else if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return (widget.onLoading ?? (_) => const SizedBox())(context);
          }

          return snapshot.data!
              ? _MediaPlaybackRender(widget.resources)
              : widget.onLoadFailed(context);
        });
  }
}

final class _MediaPlaybackRender extends StatefulWidget {
  final List<Uri> resources;

  // ignore: unused_element
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
    player = Player(
        configuration: PlayerConfiguration(
            muted: true,
            ready: () async {
              await player.pause();
            }));
    vidCtrl = VideoController(player);

    Map<String, String> header = {};
    String? ua = requestUserAgent;

    if (ua != null) {
      header["user-agent"] = ua;
    }

    player.open(Playlist(widget.resources
        .map((e) => Media(e.toString(), httpHeaders: header))
        .toList()));
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
