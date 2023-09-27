import 'package:meta/meta.dart';

import '../buffer/metainfo.dart';
import 'property_parser.dart';

@experimental
final class TwitterCardPropertyParser extends MetaPropertyParser {
  const TwitterCardPropertyParser();

  @override
  String get propertyNamePrefix => "twitter";

  @override
  void resolveMetaTags(MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair) {
    // TODO: implement resolveMetaTags
  }
}