import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oghref_builder/oghref_builder.dart'
    hide ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref
    show ImageInfo, VideoInfo, AudioInfo;
import 'package:oghref_media_control/media_control.dart';
import 'package:oghref_model/buffer_parser.dart';

import '../launch_failed_snackbar.dart';
import '../width_size_calculator.dart';
import '../components/carousel.dart';
import '../typedefs.dart';

base class OgHrefMaterialCard extends StatelessWidget
    with LaunchFailedSnackBarHandler, ResponsiveWidthSizeCalculator {
  final Uri url;
  final double? mediaWidth;
  final double? mediaHeight;
  final bool multimedia;
  final TextStyle? tileTitleTextStyle;
  final TextStyle? tileDescriptionTextStyle;
  final AspectRatioValue mediaAspectRatio;
  final bool preferHTTPS;
  final WidgetBuilder? onLoading;
  final BeforeOpenLinkConfirmation? confirmation;

  @override
  final String launchFailedMessage;

  const OgHrefMaterialCard(this.url,
      {this.mediaWidth,
      this.mediaHeight,
      this.multimedia = true,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.launchFailedMessage = "Unable to open URL.",
      this.mediaAspectRatio = AspectRatioValue.standardHD,
      this.preferHTTPS = true,
      this.onLoading,
      this.confirmation,
      super.key});

  Widget _buildMediaFrame(BuildContext context, List<oghref.ImageInfo> images,
      List<oghref.VideoInfo> videos, List<oghref.AudioInfo> audios) {
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
      return MediaPlayback(multimediaResources,
          aspectRatio: mediaAspectRatio,
          configuration: const PlayerConfiguration(
              muted: true, protocolWhitelist: ["http", "https"]),
          controlsBuilder: AdaptiveVideoControls);
    } else if (images.isNotEmpty) {
      return ImageCarousel(
          List.unmodifiable(images.where((element) => element.url != null)),
          preferHTTPS: preferHTTPS);
    }

    double disableIconSize = (mediaWidth ?? calculateResponsiveWidth(context)) / 10;
    if (disableIconSize < 18) {
      disableIconSize = 18;
    }

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
        SizedBox(
            width: preferredWidth,
            height: mediaHeight ??
                mediaAspectRatio.calcHeightFromWidth(preferredWidth),
            child: _buildMediaFrame(context, images, videos, audios)),
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
                onOpenLinkFailed: () => showLaunchFailedSnackbar(context))),
      );
    });
  }
}
