import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:http/http.dart' show Response, Client;
import 'package:oghref_model/verifiers.dart';

import 'client.dart';
import 'testing_mode.dart' if (dart.library.io) 'testing_mode_io.dart';
import 'ua.dart' if (dart.library.js_interop) 'ua_web.dart';

/// Define sizes of video frame in [MediaPlayback].
typedef VideoSize = ({int? width, int? height});

/// Cofigure preference for [MediaPlayback].
@immutable
final class MediaPlaybackPreference {
  /// Determine media playback is muted initially.
  final bool muted;

  /// Allow [MediaPlayback] play media once all context has been loaded already.
  final bool autoplay;

  /// Determine fixed sizes of video playback.
  final VideoSize videoSize;

  /// Scale of video frame.
  final double videoScale;

  /// Create preference
  const MediaPlaybackPreference({
    this.muted = true,
    this.autoplay = true,
    this.videoSize = (width: null, height: null),
    this.videoScale = 1.0,
  });
}

/// A [Widget] for handle audio and video playback if offered.
final class MediaPlayback extends StatefulWidget {
  /// Video, audio or both resources in URL.
  ///
  /// If the given resources is audio type, it retains
  /// an empty [Widget] but still functional when hovering
  /// this area for changing media position.
  final List<Uri> resources;

  /// Preference of [MediaPlayback] behaviours.
  final MediaPlaybackPreference preference;

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
  MediaPlayback(
    Iterable<Uri> resources, {
    required this.onLoadFailed,
    this.onLoading,
    this.preference = const MediaPlaybackPreference(),
    super.key,
  }) : resources = List.unmodifiable(resources) {
    if (isTesting) {
      throw UnsupportedError(
        "No real network interaction allowed during test, and it should never be built.",
      );
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

    Stream<Response> resps = Stream.fromFutures(
      widget.resources.map((e) => c.head(e)),
    );

    return resps
        .every(
          (r) => switch (r.contentTypeCategory) {
            ContentTypeCategory.audio || ContentTypeCategory.video => true,
            _ => false,
          },
        )
        .then((value) {
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
            ? _MediaPlaybackRender()
            : widget.onLoadFailed(context);
      },
    );
  }
}

final class _MediaPlaybackRender extends StatefulWidget {
  // ignore: unused_element_parameter
  _MediaPlaybackRender({super.key});

  @override
  _MediaPlaybackRenderState createState() => _MediaPlaybackRenderState();
}

final class _MediaPlaybackRenderState extends State<_MediaPlaybackRender> {
  static const List<String> _protocolWhitelist = ["http", "https"];

  late final Player player;
  late final VideoController vidCtrl;

  @override
  void initState() {
    super.initState();

    final MediaPlayback playbackWidget = context
        .findAncestorStateOfType<_MediaPlaybackState>()!
        .widget;

    final MediaPlaybackPreference preference = playbackWidget.preference;

    player = Player(
      configuration: PlayerConfiguration(
        protocolWhitelist: _protocolWhitelist,
        muted: preference.muted,
        title: "OgHref media playback component",
      ),
    );

    vidCtrl = VideoController(
      player,
      configuration: VideoControllerConfiguration(
        width: preference.videoSize.width,
        height: preference.videoSize.height,
        scale: preference.videoScale,
      ),
    );

    player.open(
      Playlist(
        playbackWidget.resources
            .map(
              (e) => Media(
                e.toString(),
                httpHeaders: {"user-agent": requestUserAgent},
              ),
            )
            .toList(),
      ),
      play: preference.autoplay,
    );
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
