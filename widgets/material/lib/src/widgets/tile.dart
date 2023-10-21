import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oghref_builder/oghref_builder.dart'
    show OgHrefBuilder, MetaFetch;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;

import '../launch_failed_snackbar.dart';
import '../width_size_calculator.dart';
import '../typedefs.dart';

base class OgHrefMaterialTile extends StatelessWidget
    with LaunchFailedSnackBarHandler, ResponsiveWidthSizeCalculator {
  final Uri url;
  final TextStyle? tileTitleTextStyle;
  final TextStyle? tileDescriptionTextStyle;
  final bool preferHTTPS;
  final WidgetBuilder? onLoading;
  final double? imagePreviewDimension;
  final BeforeOpenLinkConfirmation? confirmation;

  @override
  final String launchFailedMessage;

  const OgHrefMaterialTile(this.url,
      {this.preferHTTPS = true,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.onLoading,
      this.launchFailedMessage = "Unable to open URL.",
      this.imagePreviewDimension,
      required this.confirmation,
      super.key});

  Widget _buildImagePreview(
      BuildContext context, List<oghref.ImageInfo> images) {
    double dimension =
        imagePreviewDimension ?? calculateResponsiveWidth(context) / 12;

    if (dimension < 36) {
      dimension = 36;
    }

    double iconSize = dimension / 10;
    if (iconSize < 16) {
      iconSize = 16;
    }

    if (images.isNotEmpty) {
      oghref.ImageInfo appliedImage = images.first;

      Uri imgUri = appliedImage.url!;

      if (preferHTTPS && appliedImage.secureUrl != null) {
        imgUri = appliedImage.secureUrl!;
      }

      return SizedBox.square(
        dimension: dimension,
        child: CachedNetworkImage(
            imageUrl: "$imgUri",
            fit: BoxFit.cover,
            httpHeaders: {"user-agent": MetaFetch.userAgentString},
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.broken_image_outlined)),
            placeholder: (context, url) => const Center(
                child: SizedBox.square(
                    dimension: 14, child: CircularProgressIndicator()))),
      );
    }

    return Container(
        width: dimension,
        height: dimension,
        color: Theme.of(context).disabledColor.withAlpha(16),
        child: Center(
          child: Icon(Icons.broken_image_outlined, size: iconSize),
        ));
  }

  void _openLinkConfirm(BuildContext context, VoidCallback openLink) async {
    if (confirmation != null) {
      bool allowOpen = await confirmation!(context, url);

      if (!allowOpen) {
        return;
      }
    }

    openLink();
  }

  @override
  Widget build(BuildContext context) {
    return OgHrefBuilder(url,
        onRetrived: (context, metaInfo, openLink) {
          return ListTile(
              leading: _buildImagePreview(context, metaInfo.images),
              title: Text(
                  metaInfo.title ??
                      metaInfo.siteName ??
                      metaInfo.url?.toString() ??
                      "$url",
                  style: tileTitleTextStyle,
                  overflow: TextOverflow.ellipsis),
              subtitle: metaInfo.description == null
                  ? null
                  : Text(metaInfo.description!,
                      style: tileDescriptionTextStyle,
                      overflow: TextOverflow.ellipsis),
              onTap: () => _openLinkConfirm(context, openLink));
        },
        onFetchFailed: (context, exception, openLink) => ListTile(
            title: Text("$url",
                style: tileTitleTextStyle, overflow: TextOverflow.ellipsis),
            onTap: () => _openLinkConfirm(context, openLink)),
        onLoading: onLoading == null
            ? null
            : (context) => Padding(
                padding: const EdgeInsets.all(12), child: onLoading!(context)),
        onOpenLinkFailed: () => showLaunchFailedSnackbar(context));
  }
}
