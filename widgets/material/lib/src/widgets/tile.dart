import 'package:flutter/material.dart' hide immutable;
import 'package:meta/meta.dart';
import 'package:oghref_builder/oghref_builder.dart'
    show OgHrefBuilder, MetaFetch, MultiMetaInfoHandler, WidthSizeMeasurement;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;

import '../components/img_builders.dart';
import '../launch_failed_snackbar.dart';
import '../typedefs.dart';

/// Define style prefences for rendering [OgHrefMaterialTile].
@immutable
class OgHrefMaterialTileStyle {
  /// [TextStyle] for displaying link title.
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
  final TextStyle? tileDescriptionTextStyle;

  /// Construct style prefence for rendering [OgHrefMaterialTile].
  const OgHrefMaterialTileStyle(
      {this.tileTitleTextStyle, this.tileDescriptionTextStyle});
}

/// Create [ListTile] based widget for displaying rich information link.
///
/// It only shows image preview only no matter the given [url]
/// offered multimedia resources. At the same times, the image preview
/// widget only offered as square frame only.
base class OgHrefMaterialTile extends StatelessWidget
    with LaunchFailedSnackBarHandler, WidthSizeMeasurement {
  /// URL of the link.
  final Uri url;

  /// Specify style of [OgHrefMaterialTile].
  final OgHrefMaterialTileStyle? style;

  /// [TextStyle] for displaying link title.
  @Deprecated(
      "This feature is integrated into OgHrefMaterialTileStyle, and will be removed at 3.0.0 and beyond.")
  final TextStyle? tileTitleTextStyle;

  /// [TextStyle] for displaying description.
  @Deprecated(
      "This feature is integrated into OgHrefMaterialTileStyle, and will be removed at 3.0.0 and beyond.")
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

  /// A message will be display in [SnackBar] if [Uri] launch failed.
  @override
  final String launchFailedMessage;

  /// Create rich information link [ListTile] by given [url].
  ///
  /// If [imagePreviewDimension] is omitted, it will uses calculated
  /// dimension based on calculated value in responsive view.
  const OgHrefMaterialTile(this.url,
      {this.preferHTTPS = true,
      this.style,
      this.tileTitleTextStyle,
      this.tileDescriptionTextStyle,
      this.onLoading,
      this.launchFailedMessage = "Unable to open URL.",
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
          child: Image.network("$imgUri",
              fit: BoxFit.cover,
              headers: {"user-agent": MetaFetch.userAgentString},
              errorBuilder: errorImageMaterial,
              loadingBuilder: loadingImageMaterial,
              semanticLabel: appliedImage.alt));
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
    return OgHrefBuilder.updatable(url,
        multiInfoHandler: multiMetaInfoHandler,
        onRetrived: (context, metaInfo, openLink) {
          return ListTile(
              leading: _buildImagePreview(context, metaInfo.images),
              title: Text(
                  metaInfo.title ??
                      metaInfo.siteName ??
                      metaInfo.url?.toString() ??
                      "$url",
                  style: style?.tileTitleTextStyle,
                  overflow: TextOverflow.ellipsis),
              subtitle: metaInfo.description == null
                  ? null
                  : Text(metaInfo.description!,
                      style: style?.tileDescriptionTextStyle ??
                          // ignore: deprecated_member_use_from_same_package
                          tileDescriptionTextStyle,
                      overflow: TextOverflow.ellipsis),
              onTap: () => _openLinkConfirm(context, openLink));
        },
        onFetchFailed: (context, exception, openLink) => ListTile(
            leading: const Icon(Icons.web),
            title: Text("$url",
                // ignore: deprecated_member_use_from_same_package
                style: style?.tileTitleTextStyle ?? tileTitleTextStyle,
                overflow: TextOverflow.ellipsis),
            onTap: () => _openLinkConfirm(context, openLink)),
        onLoading: onLoading == null
            ? null
            : (context) => Padding(
                padding: const EdgeInsets.all(12), child: onLoading!(context)),
        onOpenLinkFailed: () => showLaunchFailedSnackbar(context));
  }
}
