import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:oghref_builder/oghref_builder.dart'
    show OgHrefBuilder, MetaFetch, MultiMetaInfoHandler, MetaInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;

import '../launch_failed_dialog.dart';
import '../width_size_calculator.dart';
import '../typedefs.dart';

/// Create [CupertinoListTile] based widget for displaying rich information link.
///
/// It only shows image preview only no matter the given [url]
/// offered multimedia resources. At the same times, the image preview
/// widget only offered as square frame only.
base class OgHrefCupertinoTile extends StatelessWidget
    with LaunchFailedDialogHandler, ResponsiveWidthSizeCalculator {
  /// URL of the link.
  final Uri url;

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

  /// Dimension of image preview widget.
  final double? imagePreviewDimension;

  /// Confirm user for opening link before proceed.
  ///
  /// Although it is nullable, it still marked as required property for
  /// security reason.
  final BeforeOpenLinkConfirmation? confirmation;

  /// Decides the preferred [MetaInfo] from various prefix if applied.
  final MultiMetaInfoHandler? multiMetaInfoHandler;

  /// A message will be display in [CupertinoAlertDialog] if [Uri] launch failed.
  @override
  final String launchFailedMessage;

  @override
  final String okText;

  /// Create rich information link [CupertinoListTile] by given [url].
  ///
  /// If [imagePreviewDimension] is omitted, it will uses calculated
  /// dimension based on calculated value in responsive view.
  const OgHrefCupertinoTile(this.url,
      {this.preferHTTPS = true,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.onLoading,
      this.launchFailedMessage = "Unable to open URL.",
      this.okText = "OK",
      this.imagePreviewDimension,
      required this.confirmation,
      this.multiMetaInfoHandler,
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
                const Center(child: Icon(CupertinoIcons.xmark_rectangle)),
            placeholder: (context, url) => const Center(
                child: SizedBox.square(
                    dimension: 14, child: CupertinoActivityIndicator()))),
      );
    }

    return Container(
        width: dimension,
        height: dimension,
        color: CupertinoColors.inactiveGray.withAlpha(16),
        child: Center(
          child: Icon(CupertinoIcons.xmark_rectangle, size: iconSize),
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
        multiInfoHandler: multiMetaInfoHandler,
        onRetrived: (context, metaInfo, openLink) {
          return CupertinoListTile(
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
        onFetchFailed: (context, exception, openLink) => CupertinoListTile(
            title: Text("$url",
                style: tileTitleTextStyle, overflow: TextOverflow.ellipsis),
            onTap: () => _openLinkConfirm(context, openLink)),
        onLoading: onLoading == null
            ? null
            : (context) => Padding(
                padding: const EdgeInsets.all(12), child: onLoading!(context)),
        onOpenLinkFailed: () => showLaunchFailedDialog(context));
  }
}