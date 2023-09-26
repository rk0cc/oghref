import 'dart:collection';

import 'package:html/dom.dart';
import 'package:oghref_model/src/model/metainfo.dart';

import 'parser/property_parser.dart';

final class MetaFetch {
  static final MetaFetch _instance = MetaFetch._();
  final Set<MetaPropertyParser> _parsers = HashSet(
      equals: (p0, p1) => p0.propertyNamePrefix == p1.propertyNamePrefix,
      hashCode: (p0) => p0.propertyNamePrefix.hashCode);

  MetaFetch._();

  factory MetaFetch() => _instance;

  static bool Function(MetaPropertyParser) _prefixEquals(String prefix) =>
      (mpp) => mpp.propertyNamePrefix == prefix;

  MetaPropertyParser _findCorrespondedParser(String prefix) {
    return _parsers.singleWhere(_prefixEquals(prefix));
  }

  bool register(MetaPropertyParser parser) {
    return _parsers.add(parser);
  }

  bool hasBeenRegistered(Object identifier) {
    try {
      if (identifier is String) {
        _findCorrespondedParser(identifier);
      } else if (identifier is MetaPropertyParser) {
        _findCorrespondedParser(identifier.propertyNamePrefix);
      }

      return true;
    } on StateError {
      // Non-single case
    }

    return false;
  }

  bool deregister(String prefix) {
    final int originLength = _parsers.length;
    _parsers.removeWhere(_prefixEquals(prefix));

    return _parsers.length < originLength;
  }

  MetaInfo buildMetaInfo(Document htmlDocument) {
    final offeredPropPrefix = htmlDocument.head
        ?.querySelectorAll("meta[property][content]")
        .map((e) => e.attributes["property"]!.split(":").first)
        .toSet();

    MetaInfo parsedResult = MetaInfo();

    if (offeredPropPrefix != null) {
      for (String prefix in offeredPropPrefix) {
        try {
          var parser = _findCorrespondedParser(prefix);
          parsedResult = parser.parse(htmlDocument.head!);
          break;
        } on StateError {
          continue;
        }
      }
    }

    return parsedResult;
  }
}
