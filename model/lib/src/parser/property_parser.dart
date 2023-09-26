import 'dart:collection';

import 'package:html/dom.dart';
import 'package:meta/meta.dart';

import '../model/metainfo.dart';
import '../buffer/metainfo.dart';

abstract base class MetaPropertyParser {
  const MetaPropertyParser();

  String get propertyNamePrefix;

  @protected
  void resolveMetaTags(
      MetaInfoAssigner assigner, List<Element> metaPropertyTags);

  MetaInfo parse(Element htmlHead) {
    final MetaInfoParser metaParser = MetaInfoParser()..markInitalized();
    final metaTags = htmlHead.querySelectorAll(
        r'meta[property^="' + propertyNamePrefix + r':"][content]');

    resolveMetaTags(metaParser, UnmodifiableListView(metaTags));

    return metaParser.compile();
  }
}
