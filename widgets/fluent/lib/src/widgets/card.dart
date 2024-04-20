import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:oghref_builder/oghref_builder.dart'
    hide ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref
    show ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_media_control/oghref_media_control.dart';
import 'package:oghref_model/buffer_parser.dart';

import '../launch_failed_infobar.dart';
import '../components/carousel.dart';
import '../typedefs.dart';

/// An [OgHrefFluentCard] style preference related to [Card]
/// which related to [Color]s and [ShapeBorder].
final class OgHrefFluentCardStyle {
  /// [Card] background colour applied in [OgHrefMaterialCard].
  ///
  /// This value will redirect to [Card.backgroundColor].
  final Color? backgroundColour;

  /// Shadow colour applied for [Card].
  ///
  /// This value will redirect to [Card.borderColor].
  final Color? borderColour;

  /// [TextStyle] for displaying link title.
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
  final TextStyle? tileDescriptionTextStyle;

  /// Specify preferences for visualizing image carousel content.
  final ImageCarouselPreferences imageCarouselPreferences;

  /// Create preference of [OgHrefFluentCard] style.
  const OgHrefFluentCardStyle(
      {this.backgroundColour,
      this.borderColour,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.imageCarouselPreferences = const ImageCarouselPreferences()});
}

/// Rich information link preview under [Card] implementation.
///
/// If the given [url] marked metadata with recognizable from [MetaFetch],
/// it will shows informations that provided in markup language including
/// but not limited to images, audios and videos.
///
/// When the [url] does not provides any supported rich link metadata, it
/// will display placeholder icon with entire [url] to ensure functional
/// whatever the metadata is provide or not.
base class OgHrefFluentCard extends StatelessWidget
    with LaunchFailedInfoBarHandler, WidthSizeMeasurement {
  /// URL of the link which may be show rich link information if provided.
  final Uri url;

  /// Specified witdth of media frame.
  ///
  /// This also be applied to entire [Card].
  ///
  /// If it is null, it will calculate the suitable width according
  /// to [MediaQuery.sizeOf].
  final double? mediaWidth;

  /// Specified height of media frame.
  ///
  /// If it is null, it will calculate corresponded height based
  /// on calculated width in 16:9 ratio.
  final double? mediaHeight;

  /// Enable playing video and audio support if applied.
  ///
  /// To activate multimedia functions, the given [url] must contains
  /// metadata related to audios, videos or both with supported data type
  /// from response of `HEAD` request for each denoted resources URL.
  /// If no audio or video available or at least one resources responded
  /// invalid content type, this feature will not available and fallback to
  /// [ImageCarousel].
  final bool multimedia;

  /// [TextStyle] for displaying link title.
  @Deprecated(
      "This feature is integrated into OgHrefFluentCardStyle, and will be removed at 3.0.0 and beyond.")
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
  @Deprecated(
      "This feature is integrated into OgHrefFluentCardStyle, and will be removed at 3.0.0 and beyond.")
  final TextStyle? tileDescriptionTextStyle;

  /// Uses `HTTPS` [Uri] resources instead of the default value
  /// (if applied).
  ///
  /// It is strongly suggest to enable and disable for those website
  /// is using HTTPS and HTTP accordingly to prevent malfunction
  /// owing to cross origin security.
  ///
  /// Although it take no affects for VM environments, it is prefer
  /// to retain enable.
  final bool preferHTTPS;

  /// Display [Widget] when loading context.
  final WidgetBuilder? onLoading;

  /// Confirm user for opening link before proceed.
  ///
  /// Although it is nullable, it still marked as required property for
  /// security reason.
  final BeforeOpenLinkConfirmation? confirmation;

  /// A message will be display in [InfoBar] if [Uri] launch failed.
  @override
  final String launchFailedMessage;

  /// Decides the preferred [MetaInfo] from various prefix if applied.
  final MultiMetaInfoHandler? multiMetaInfoHandler;

  /// Specify style preferences for rendering [OgHrefFluentCard].
  final OgHrefFluentCardStyle? style;

  /// Apply margin uses to leave a blank space of [OgHrefFluentCard].
  final EdgeInsetsGeometry? margin;

  /// Configure preferences when handling media playback.
  ///
  /// This preference will be applied if [multimedia] is enabled.
  final MediaPlaybackPreference? mediaPlaybackPreference;

  /// Create rich information link [Card] by given [url].
  ///
  /// If either [mediaWidth] or [mediaHeight] omitted, it will
  /// calculate reasonable value in responsive view.
  const OgHrefFluentCard(this.url,
      {this.mediaWidth,
      this.mediaHeight,
      this.multimedia = false,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.launchFailedMessage = "Unable to open URL.",
      this.preferHTTPS = true,
      this.onLoading,
      required this.confirmation,
      this.multiMetaInfoHandler,
      this.style,
      this.margin,
      this.mediaPlaybackPreference,
      super.key});

  ImageCarousel _buildCarousel(
      BuildContext context, List<oghref.ImageInfo> images) {
    assert(images.isNotEmpty);
    return ImageCarousel(
        List.unmodifiable(images.where((element) => element.url != null)),
        preferHTTPS: preferHTTPS,
        preferences: style?.imageCarouselPreferences ??
            const ImageCarouselPreferences());
  }

  Widget _buildFallback(BuildContext context) {
    // Get Icon for placeholder
    double disableIconSize =
        (mediaWidth ?? calculateResponsiveWidth(context)) / 10;
    if (disableIconSize < 18) {
      disableIconSize = 18;
    }

    // Last resort widget. Display broken image icon.
    return Container(
        color: FluentTheme.of(context).inactiveColor.withAlpha(16),
        child: Center(
            child: Icon(FluentIcons.image_off_48_regular, size: disableIconSize)));
  }

  Widget _onNonPlayback(BuildContext context, List<oghref.ImageInfo> images) =>
      images.isEmpty
          ? _buildFallback(context)
          : _buildCarousel(context, images);

  Widget _buildMediaFrame(BuildContext context, List<oghref.ImageInfo> images,
      List<oghref.VideoInfo> videos, List<oghref.AudioInfo> audios) {
    // Get multimedia resources which provided.
    List<Uri> multimediaResources = List.unmodifiable(<UrlInfo>[
      ...videos,
      ...audios
    ].where((element) => element.url != null).map((e) {
      if (preferHTTPS && e.secureUrl != null) {
        return e.secureUrl!;
      }

      return e.url!;
    }));

    if (multimedia && multimediaResources.isNotEmpty) {
      // Get media playback if enabled multimedia features with provided resources.
      return MediaPlayback(multimediaResources,
          onLoading: (context) =>
              const Center(child: ProgressRing()),
          onLoadFailed: (context) => _onNonPlayback(context, images),
          preference:
              mediaPlaybackPreference ?? const MediaPlaybackPreference());
    }

    return _onNonPlayback(context, images);
  }

  ListTile _buildTile(BuildContext context, String title,
      {String? description, required VoidCallback openLink}) {
    Text? descTxt;

    if (description != null) {
      descTxt = Text(description,
          // ignore: deprecated_member_use_from_same_package
          style: style?.tileDescriptionTextStyle ?? tileDescriptionTextStyle,
          overflow: TextOverflow.ellipsis);
    }

    return ListTile(
        title: Text(title,
            // ignore: deprecated_member_use_from_same_package
            style: style?.tileTitleTextStyle ?? tileTitleTextStyle,
            overflow: TextOverflow.ellipsis),
        subtitle: descTxt,
        onPressed: () async {
          if (confirmation != null) {
            bool allowOpen = await confirmation!(context, url);

            if (!allowOpen) {
              return;
            }
          }

          openLink();
        });
  }

  Column _buildInteraction(BuildContext context,
      {required double preferredWidth,
      required String title,
      String? description,
      required VoidCallback openLink,
      List<oghref.ImageInfo> images = const [],
      List<oghref.VideoInfo> videos = const [],
      List<oghref.AudioInfo> audios = const []}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Media frame
      SizedBox(
          width: preferredWidth,
          height: mediaHeight ?? preferredWidth * 9 / 16,
          child: _buildMediaFrame(context, images, videos, audios)),
      // Tile link
      SizedBox(
          width: preferredWidth,
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: _buildTile(context, title,
                  openLink: openLink, description: description)))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double preferredWidth = mediaWidth ??
          calculateResponsiveWidth(context, constraints: constraints);

      return SizedBox(
          width: preferredWidth,
          child: Card(
              backgroundColor: style?.backgroundColour,
              borderColor: style?.borderColour,
              margin: margin,
              child: OgHrefBuilder.updatable(url,
                  multiInfoHandler: multiMetaInfoHandler,
                  onLoading: onLoading == null
                      ? null
                      : (context) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: onLoading!(context)),
                  onRetrived: (context, metaInfo, openLink) =>
                      _buildInteraction(context,
                          preferredWidth: preferredWidth,
                          title: metaInfo.title ??
                              metaInfo.siteName ??
                              metaInfo.url?.toString() ??
                              url.toString(),
                          description: metaInfo.description,
                          openLink: openLink,
                          images: metaInfo.images,
                          videos: metaInfo.videos,
                          audios: metaInfo.audios),
                  onFetchFailed: (context, exception, openLink) =>
                      _buildInteraction(context,
                          preferredWidth: preferredWidth,
                          title: url.toString(),
                          openLink: openLink),
                  onOpenLinkFailed: () => showLaunchFailedInfoBar(context))));
    });
  }
}
