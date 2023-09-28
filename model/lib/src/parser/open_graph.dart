import '../buffer/metainfo.dart';
import '../fetch.dart';

import 'property_parser.dart';

/// [Open Graph Protocol](https://ogp.me/) implementations of
/// [MetaPropertyParser].
///
/// This parser will handle `<meta>` property which starting with
/// `og:`
///
/// Open Graph Protocol is created by Facebook and become
/// the major rich information metadata protocol for various
/// social platform.
final class OpenGraphPropertyParser extends MetaPropertyParser {
  /// Create parser for Open Graph Protocol.
  ///
  /// Usually it should be attached into [MetaFetch.register]
  /// directly.
  const OpenGraphPropertyParser();

  @override
  String get propertyNamePrefix => "og";

  @override
  void resolveMetaTags(
      MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair) {
    final ImageInfoParser imgParser = ImageInfoParser();
    final VideoInfoParser vidParser = VideoInfoParser();
    final AudioInfoParser audParser = AudioInfoParser();

    for (PropertyPair metaTag in propertyPair) {
      var (property, content) = metaTag;

      switch (property) {
        case "og:title":
          assigner.title = content;
          break;
        case "og:url":
          assigner.url = Uri.tryParse(content);
          break;
        case "og:description":
          assigner.description = content;
          break;
        case "og:site_name":
          assigner.siteName = content;
          break;
        case "og:image":
        case "og:imagae:url":
          if (imgParser.isInitalized) {
            assigner.images.add(imgParser.compile());
            imgParser.reset();
          } else {
            imgParser.markInitalized();
          }

          imgParser.url = Uri.tryParse(content);
          break;
        case "og:image:secure_url":
          if (imgParser.isInitalized) {
            imgParser.secureUrl = Uri.tryParse(content);
          }
          break;
        case "og:image:type":
          if (imgParser.isInitalized) {
            imgParser.type = content;
          }
          break;
        case "og:image:width":
          if (imgParser.isInitalized) {
            imgParser.width = double.tryParse(content);
          }
          break;
        case "og:image:height":
          if (imgParser.isInitalized) {
            imgParser.height = double.tryParse(content);
          }
          break;
        case "og:image:alt":
          if (imgParser.isInitalized) {
            imgParser.alt = content;
          }
          break;
        case "og:video":
        case "og:video:url":
          if (vidParser.isInitalized) {
            assigner.videos.add(vidParser.compile());
            vidParser.reset();
          } else {
            vidParser.markInitalized();
          }

          vidParser.url = Uri.tryParse(content);
          break;
        case "og:video:secure_url":
          if (vidParser.isInitalized) {
            vidParser.secureUrl = Uri.tryParse(content);
          }
          break;
        case "og:video:type":
          if (vidParser.isInitalized) {
            vidParser.type = content;
          }
          break;
        case "og:video:width":
          if (vidParser.isInitalized) {
            vidParser.width = double.tryParse(content);
          }
          break;
        case "og:video:height":
          if (vidParser.isInitalized) {
            vidParser.height = double.tryParse(content);
          }
          break;
        case "og:audio":
        case "og:audio:url":
          if (audParser.isInitalized) {
            assigner.audios.add(audParser.compile());
            audParser.reset();
          } else {
            audParser.markInitalized();
          }

          audParser.url = Uri.tryParse(content);
          break;
        case "og:audio:secure_url":
          if (audParser.isInitalized) {
            audParser.secureUrl = Uri.tryParse(content);
          }
          break;
        case "og:audio:type":
          if (audParser.isInitalized) {
            audParser.type = content;
          }
          break;
      }
    }

    if (imgParser.url != null) {
      assigner.images.add(imgParser.compile());
    }

    if (vidParser.url != null) {
      assigner.videos.add(vidParser.compile());
    }

    if (audParser.url != null) {
      assigner.audios.add(audParser.compile());
    }
  }
}
