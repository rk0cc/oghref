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

base class OgHrefMaterialCard extends StatelessWidget
    with LaunchFailedSnackBarHandler, ResponsiveWidthSizeCalculator {
  final Uri url;
  final double? width;
  final double? height;
  final bool multimedia;
  final TextStyle? tileTitleTextStyle;
  final TextStyle? tileDescriptionTextStyle;
  final AspectRatioValue mediaAspectRatio;
  final bool preferHTTPS;

  @override
  final String launchFailedMessage;

  const OgHrefMaterialCard(this.url,
      {this.width,
      this.height,
      this.multimedia = true,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.launchFailedMessage = "Unable to open URL.",
      this.mediaAspectRatio = AspectRatioValue.standardHD,
      this.preferHTTPS = true,
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

    double disableIconSize = MediaQuery.sizeOf(context).width / 10;
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
        onTap: openLink);
  }

  Column _buildOgHerfContext(BuildContext context,
      {required String title,
      String? description,
      List<oghref.ImageInfo> images = const [],
      List<oghref.VideoInfo> videos = const [],
      List<oghref.AudioInfo> audios = const [],
      required VoidCallback openLink}) {
    return Column(children: [
      Expanded(child: _buildMediaFrame(context, images, videos, audios)),
      _buildTile(context, title, openLink: openLink)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double usesWidth = width ?? calculateResponsiveWidth(context);
      double usesHeight =
          height ?? mediaAspectRatio.calcHeightFromWidth(usesWidth);

      return SizedBox(
          width: usesWidth,
          height: usesHeight,
          child: Card(
            child: OgHrefBuilder(url,
              onRetrived: (context, metaInfo, openLink) => _buildOgHerfContext(
                  context,
                  title: metaInfo.title ?? metaInfo.siteName ?? "$url",
                  openLink: openLink,
                  description: metaInfo.description,
                  audios: metaInfo.audios,
                  images: metaInfo.images,
                  videos: metaInfo.videos),
              onFetchFailed: (context, exception, openLink) =>
                  _buildOgHerfContext(context,
                      title: "$url", openLink: openLink),
              onOpenLinkFailed: () => showLaunchFailedSnackbar(context))
          ));
    });
  }
}
