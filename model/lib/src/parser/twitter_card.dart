import '../model/metainfo.dart';
import '../buffer/metainfo.dart';
import 'property_parser.dart';

/// Twitter card implementations of [MetaPropertyParser].
///
/// This parser will handle `<meta>` property which starting with
/// `twitter:`.
///
/// Twitter card is created by Twitter (now known as X) which
/// uses for display rich information link in Twitter.
///
/// The [MetaInfo.url] will be linked to corresponded user name or it's ID
/// in X and it does not offered any [AudioInfo] in [MetaInfo.audios].
///
/// ### Note for embedded player property
///
/// Since OgHref media player only recognizes raw video files,
/// unless `twitter:player:stream` is offered with raw video
/// content URL, it will apply iframe player URL first and removed
/// when constructing [MetaInfo].
final class TwitterCardPropertyParser extends MetaPropertyParser {
  /// Uses `twitter.com` instead of `x.com` when constructing
  /// link to X's profile.
  ///
  /// By default, it is disabled.
  @Deprecated("twitter.com is used for redirect to x.com now.")
  final bool legacyDomain;

  @override
  final String propertyNamePrefix = "twitter";

  /// Construct a parser of Twitter Card with decision of
  /// using [legacyDomain].
  const TwitterCardPropertyParser(
      {@Deprecated("twitter.com is used for redirect to x.com now.")
      this.legacyDomain = false});

  @override
  void resolveMetaTags(
      MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair) {
    // ignore: deprecated_member_use_from_same_package
    final Uri twitterSite = Uri.https("${legacyDomain ? 'twitter' : 'x'}.com");
    final ImageInfoParser imgParser = ImageInfoParser();
    final VideoInfoParser vidParser = VideoInfoParser();

    try {
      for (var (property, value) in propertyPair) {
        switch (property) {
          case "twitter:site":
            assigner.url ??= twitterSite.resolve("/${value.substring(1)}");
            break;
          case "twitter:site:id":
            assigner.url ??= twitterSite.resolve("/i/user/$value");
            break;
          case "twitter:description":
            assigner.description = value;
            break;
          case "twitter:title":
            assigner.title = value;
            break;
          case "twitter:image":
            if (imgParser.isInitalized) {
              assigner.images.add(imgParser.compile());
              imgParser.reset();
            } else {
              imgParser.markInitalized();
            }

            imgParser.url = Uri.tryParse(value);
            break;
          case "twitter:image:alt":
            imgParser.alt = value;
            break;
          case "twitter:player":
            if (vidParser.isInitalized) {
              assigner.videos.add(vidParser.compile());
              vidParser.reset();
            } else {
              vidParser.markInitalized();
            }

            vidParser.url = Uri.tryParse(value);
            break;
          case "twitter:player:width":
            vidParser.width = double.tryParse(value);
            break;
          case "twitter:player:height":
            vidParser.height = double.tryParse(value);
            break;
          case "twitter:player:stream":
            Uri? resolvedStream = Uri.tryParse(value);
            if (resolvedStream != null && vidParser.url != null) {
              // Uses raw file if provided instead of relying iframe.
              vidParser.url = resolvedStream;
            }
            break;
        }
      }
    } finally {
      if (imgParser.url != null) {
        assigner.images.add(imgParser.compile());
      }

      if (vidParser.url != null) {
        assigner.videos.add(vidParser.compile());
      }
    }
  }
}
