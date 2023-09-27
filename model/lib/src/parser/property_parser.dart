import 'dart:collection';

import 'package:html/dom.dart';
import 'package:meta/meta.dart';

import '../model/metainfo.dart';
import '../buffer/metainfo.dart';

/// A parser for constructing [MetaInfo] given [Document]
/// in HTML.
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
  String get propertyNamePrefix;

  /// Actual implementation of assigning [MetaInfo] given all `<meta>`
  /// [Element] with corresponded [propertyNamePrefix].
  /// 
  /// By resolving content from [metaPropertyTags] which is unmodifiable
  /// [List] into [assigner] and uses for generating [MetaInfo] in
  /// [parse].
  /// 
  /// If necessary, [AudioInfoParser], [ImageInfoParser] and [VideoInfoParser]
  /// can be created under this method for resolving multimedia
  /// metadata content.
  @protected
  void resolveMetaTags(
      MetaInfoAssigner assigner, List<Element> metaPropertyTags);

  /// Resolve rich information metadata from given [htmlHead] which
  /// is `<head>` [Element] in HTML.
  /// 
  /// This method should not be [override]. Instead, all data apply
  /// must be done under [resolveMetaTags].
  @nonVirtual
  MetaInfo parse(Element htmlHead) {
    final MetaInfoParser metaParser = MetaInfoParser()..markInitalized();
    final metaTags = htmlHead.querySelectorAll(
        r'meta[property^="' + propertyNamePrefix + r':"][content]');

    resolveMetaTags(metaParser, UnmodifiableListView(metaTags));

    return metaParser.compile();
  }
}
