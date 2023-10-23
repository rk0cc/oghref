import '../buffer/metainfo.dart';
import 'property_parser.dart';

final class TwitterCardParser extends MetaPropertyParser {
  final bool legacyDomain;

  const TwitterCardParser({this.legacyDomain = true});

  @override
  String get propertyNamePrefix => "twitter";

  @override
  void resolveMetaTags(MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair) {
    final Uri twitterSite = Uri.https("${legacyDomain ? 'twitter' : 'x'}.com");
    final ImageInfoParser imgParser = ImageInfoParser();
    final VideoInfoParser vidParser = VideoInfoParser();

    for (PropertyPair metaTag in propertyPair) {
      var (property, value) = metaTag;

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

    if (imgParser.url != null) {
      assigner.images.add(imgParser.compile());
    }

    if (vidParser.url != null) {
      assigner.videos.add(vidParser.compile());
    }
  }
}