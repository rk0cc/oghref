import 'package:flutter/cupertino.dart';
import 'package:oghref_builder/oghref_builder.dart'
    hide ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref
    show ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_builder/widgets.dart';
import 'package:oghref_media_control/oghref_media_control.dart';
import 'package:oghref_model/buffer_parser.dart';

import '../launch_failed_dialog.dart';
import '../components/carousel.dart';
import '../components/divider.dart';
import '../typedefs.dart';

/// An [OgHrefCupertinoCard] style preference which onoy
final class OgHrefCupertinoCardStyle {
  /// Background colour applied in [OgHrefCupertinoCard].
  final Color? backgroundColour;

  /// [TextStyle] for displaying link title.
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
  final TextStyle? tileDescriptionTextStyle;

  /// Specify preferences for visualizing image carousel content.
  final ImageCarouselPreferences imageCarouselPreferences;

  /// Create preference of [OgHrefCupertinoCard] style.
  const OgHrefCupertinoCardStyle(
      {this.backgroundColour,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.imageCarouselPreferences = const ImageCarouselPreferences()});
}

/// Rich information link preview under card implementation.
///
/// If the given [url] marked metadata with recognizable from [MetaFetch],
/// it will shows informations that provided in markup language including
/// but not limited to images, audios and videos.
///
/// When the [url] does not provides any supported rich link metadata, it
/// will display placeholder icon with entire [url] to ensure functional
/// whatever the metadata is provide or not.
base class OgHrefCupertinoCard extends StatelessWidget
    with LaunchFailedDialogHandler, WidthSizeMeasurement {
  /// URL of the link which may be show rich link information if provided.
  final Uri url;

  /// Specified witdth of media frame.
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
      "This feature is integrated into OgHrefCupertinoCardStyle, and will be removed at 3.0.0 and beyond.")
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
  @Deprecated(
      "This feature is integrated into OgHrefCupertinoCardStyle, and will be removed at 3.0.0 and beyond.")
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

  /// A message will be display in [CupertinoAlertDialog] if [Uri] launch failed.
  @override
  final String launchFailedMessage;

  /// A [String] display `OK` button in [CupertinoAlertDialog] when launch URL failed.
  @override
  final String okText;

  /// Decides the preferred [MetaInfo] from various prefix if applied.
  final MultiMetaInfoHandler? multiMetaInfoHandler;

  /// Specify styles for this widget.
  final OgHrefCupertinoCardStyle? style;

  /// Configure preferences when handling media playback.
  ///
  /// This preference will be applied if [multimedia] is enabled.
  final MediaPlaybackPreference? mediaPlaybackPreference;

  /// Create rich information link card by given [url].
  ///
  /// If either [mediaWidth] or [mediaHeight] omitted, it will
  /// calculate reasonable value in responsive view.
  const OgHrefCupertinoCard(this.url,
      {this.mediaWidth,
      this.mediaHeight,
      this.multimedia = false,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.launchFailedMessage = "Unable to open URL.",
      this.okText = "OK",
      this.preferHTTPS = true,
      this.onLoading,
      required this.confirmation,
      this.multiMetaInfoHandler,
      this.style,
      this.mediaPlaybackPreference,
      super.key});

  ImageCarousel _buildCarousel(
      BuildContext context, List<oghref.ImageInfo> images) {
    assert(images.isNotEmpty);
    return CupertinoImageCarousel(
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
        color: CupertinoColors.quaternarySystemFill.withAlpha(16),
        child: Center(
            child:
                Icon(CupertinoIcons.xmark_rectangle, size: disableIconSize)));
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
              const Center(child: CupertinoActivityIndicator()),
          onLoadFailed: (context) => _onNonPlayback(context, images),
          preference:
              mediaPlaybackPreference ?? const MediaPlaybackPreference());
    }

    return _onNonPlayback(context, images);
  }

  CupertinoListTile _buildTile(BuildContext context, String title,
      {String? description, required VoidCallback openLink}) {
    Text? descTxt;

    if (description != null) {
      descTxt = Text(description,
          // ignore: deprecated_member_use_from_same_package
          style: style?.tileDescriptionTextStyle ?? tileDescriptionTextStyle,
          overflow: TextOverflow.ellipsis);
    }

    return CupertinoListTile(
        title: Text(title,
            // ignore: deprecated_member_use_from_same_package
            style: style?.tileTitleTextStyle ?? tileTitleTextStyle,
            overflow: TextOverflow.ellipsis),
        subtitle: descTxt,
        onTap: () async {
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
    const double tileTopPadding = 4;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Media frame
      SizedBox(
          width: preferredWidth,
          height: mediaHeight ?? preferredWidth * 9 / 16,
          child: _buildMediaFrame(context, images, videos, audios)),
      // Divider
      const CupertinoDivider(),
      SizedBox(
          width: preferredWidth,
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: tileTopPadding, bottom: tileTopPadding * 2),
                  child: _buildTile(context, title,
                      openLink: openLink, description: description))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double preferredWidth = mediaWidth ??
          calculateResponsiveWidth(context, constraints: constraints);

      return Container(
          width: preferredWidth,
          constraints: BoxConstraints(minHeight: mediaHeight ?? 0),
          decoration: BoxDecoration(
              color: style?.backgroundColour ??
                  CupertinoTheme.of(context).barBackgroundColor.withAlpha(255),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: OgHrefBuilder.updatable(url,
              multiInfoHandler: multiMetaInfoHandler,
              onLoading: onLoading == null
                  ? null
                  : (context) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: onLoading!(context)),
              onRetrived: (context, metaInfo, openLink) => _buildInteraction(
                  context,
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
              onOpenLinkFailed: () => showLaunchFailedDialog(context)));
    });
  }
}
