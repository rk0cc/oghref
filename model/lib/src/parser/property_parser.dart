import 'dart:collection';
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:meta/meta.dart';

import '../buffer/metainfo.dart';
import '../fetch/fetch.dart' show MetaFetch;
import '../model/metainfo.dart';

/// A [String] pair [Record] represents `property` and `content` attribute
/// in `<meta>` tag.
typedef PropertyPair = (String name, String content);

/// A parser for constructing [MetaInfo] given [Document]
/// in HTML.
@doNotStore
abstract base mixin class MetaPropertyParser {
  /// Create new [MetaInfoParser] for resolving property name
  /// with [propertyNamePrefix].
  const MetaPropertyParser();

  /// Prefix of property's name which identify which rich information
  /// provider is used.
  ///
  /// Reference of values:
  /// |     Providers     |Prefix of property name|    Example   |
  /// |:-----------------:|:---------------------:|:------------:|
  /// |Open Graph Protocol|         `og`          |  `og:title`  |
  /// |   Twitter Card    |      `twitter`        |`twitter:card`|
  ///
  /// This property must return non-empty [String] to recognise corresponded
  /// parser in [MetaFetch]. If offered it empty, majority operations
  /// done in [MetaFetch] will throw [ArgumentError].
  String get propertyNamePrefix;

  /// Actual implementation of assigning [MetaInfo] given all `<meta>`
  /// [Element] with corresponded [propertyNamePrefix].
  ///
  /// By resolving [propertyPair] which is unmodifiable
  /// [List] into [assigner] and uses for generating [MetaInfo] in
  /// [parse].
  ///
  /// If necessary, [AudioInfoParser], [ImageInfoParser] and [VideoInfoParser]
  /// can be created under this method for resolving multimedia
  /// metadata content.
  @protected
  void resolveMetaTags(
      MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair);

  /// Resolve rich information metadata from given [htmlHead] which
  /// is `<head>` [Element] in HTML.
  ///
  /// This method should not be [override]. Instead, all data apply
  /// must be done under [resolveMetaTags].
  @nonVirtual
  MetaInfo parse(Element htmlHead) {
    final MetaInfoParser metaParser = MetaInfoParser()..markInitalized();
    final Iterable<PropertyPair> metaTagsProp = htmlHead
        .querySelectorAll(
            r'meta[property^="' + propertyNamePrefix + r':"][content]')
        .map((e) {
      final attr = e.attributes;

      String ctx = attr['content']!;

      try {
        ctx = utf8.decode(ctx.runes.toList());
      } on FormatException {
        // If not work, leave origin ctx.
      }

      return (attr['property']!, ctx);
    });

    resolveMetaTags(metaParser, UnmodifiableListView(metaTagsProp));

    return metaParser.compile();
  }
}
