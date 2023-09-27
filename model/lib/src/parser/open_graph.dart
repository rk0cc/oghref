import 'package:html/dom.dart';

import '../buffer/metainfo.dart';

import 'property_parser.dart';

final class OpenGraphPropertyParser extends MetaPropertyParser {
  const OpenGraphPropertyParser();
  
  @override
  String get propertyNamePrefix => "og";

  @override
  void resolveMetaTags(
      MetaInfoAssigner assigner, List<Element> metaPropertyTags) {
    final ImageInfoParser imgParser = ImageInfoParser();
    final VideoInfoParser vidParser = VideoInfoParser();
    final AudioInfoParser audParser = AudioInfoParser();

    for (Element metaTag in metaPropertyTags) {
      String property = metaTag.attributes['property']!,
          content = metaTag.attributes['content']!;

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
          if (imgParser.isInitalized) {
            audParser.secureUrl = Uri.tryParse(content);
          }
          break;
        case "og:audio:type":
          if (imgParser.isInitalized) {
            audParser.type = content;
          }
          break;
      }
    }
  }
}
