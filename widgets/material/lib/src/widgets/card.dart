import 'package:flutter/material.dart';
import 'package:oghref_builder/oghref_builder.dart'
    hide ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref
    show ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_media_control/oghref_media_control.dart';
import 'package:oghref_model/buffer_parser.dart';

import '../launch_failed_snackbar.dart';
import '../width_size_calculator.dart';
import '../components/carousel.dart';
import '../typedefs.dart';

/// Rich information link preview under [Card] implementation.
///
/// If the given [url] marked metadata with recognizable from [MetaFetch],
/// it will shows informations that provided in markup language including
/// but not limited to images, audios and videos.
///
/// When the [url] does not provides any supported rich link metadata, it
/// will display placeholder icon with entire [url] to ensure functional
/// whatever the metadata is provide or not.
base class OgHrefMaterialCard extends StatelessWidget
    with LaunchFailedSnackBarHandler, ResponsiveWidthSizeCalculator {
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
  /// ### Issues for previewing YouTube or other non-video / non-audio file URL property in `og:video` / `og:audio`
  ///
  /// Since playback feature is based on [media_kit](https://github.com/media-kit/media-kit) which only supported
  /// playing "actual media file" only, it no longer be functional for providing URL is not linked to video or
  /// audio files. As a result, it is strongly suggest to disable [multimedia] if failed to play due to
  /// unsatified file format of URL.
  final bool multimedia;

  /// [TextStyle] for displaying link title.
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
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

  /// A message will be display in [SnackBar] if [Uri] launch failed.
  @override
  final String launchFailedMessage;

  /// Decides the preferred [MetaInfo] from various prefix if applied.
  final MultiMetaInfoHandler? multiMetaInfoHandler;

  /// Create rich information link [Card] by given [url].
  ///
  /// If either [mediaWidth] or [mediaHeight] omitted, it will
  /// calculate reasonable value in responsive view.
  const OgHrefMaterialCard(this.url,
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
      super.key});

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

    final ImageCarousel carousel = ImageCarousel(
        List.unmodifiable(images.where((element) => element.url != null)),
        preferHTTPS: preferHTTPS);

    if (multimedia && multimediaResources.isNotEmpty) {
      // Get media playback if enabled multimedia features with provided resources.
      return MediaPlayback(multimediaResources,
          onLoading: (context) =>
              const Center(child: CircularProgressIndicator()),
          onLoadFailed: (context) => carousel);
    } else if (images.isNotEmpty) {
      // Get images either no multimedia resources provided or disabled multimedia features.
      return carousel;
    }

    // Get Icon for placeholder
    double disableIconSize =
        (mediaWidth ?? calculateResponsiveWidth(context)) / 10;
    if (disableIconSize < 18) {
      disableIconSize = 18;
    }

    // Last resort widget. Display broken image icon.
    return Container(
        color: Theme.of(context).disabledColor.withAlpha(16),
        child: Center(
            child: Icon(Icons.broken_image_outlined, size: disableIconSize)));
  }

  ListTile _buildTile(BuildContext context, String title,
      {String? description, required VoidCallback openLink}) {
    Text? descTxt;

    if (description != null) {
      descTxt = Text(description,
          style: tileDescriptionTextStyle, overflow: TextOverflow.ellipsis);
    }

    return ListTile(
        title: Text(title,
            style: tileTitleTextStyle, overflow: TextOverflow.ellipsis),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Media frame
        SizedBox(
            width: preferredWidth,
            height: mediaHeight ?? preferredWidth * 9 / 16,
            child: _buildMediaFrame(context, images, videos, audios)),
        // Tile link
        SizedBox(
            width: preferredWidth,
            child: _buildTile(context, title,
                openLink: openLink, description: description))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double preferredWidth = mediaWidth ?? calculateResponsiveWidth(context);

      return SizedBox(
          width: preferredWidth,
          child: Card(
              child: OgHrefBuilder(url,
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
                  onOpenLinkFailed: () => showLaunchFailedSnackbar(context))));
    });
  }
}
