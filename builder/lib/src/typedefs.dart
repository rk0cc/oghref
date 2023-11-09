import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:oghref_model/model.dart' show MetaInfo;

/// Handle various [MetaInfo] from various protocols into a single object.
///
/// It suppose returns [MetaInfo.merge] result.
typedef MultiMetaInfoHandler = MetaInfo Function(
    Map<String, MetaInfo> metaInfos);

/// A handler for popping up dialog to enquire user to open [url].
typedef OpenLinkConfirmation = FutureOr<bool> Function(
    BuildContext context, Uri url);

/// A builder when rich information link metadata has been retrived.
///
/// It retrived [metaInfo] of corresponded metadata and [openLink]
/// for opening website.
typedef MetaInfoRetrivedBuilder = Widget Function(
    BuildContext context, MetaInfo metaInfo, VoidCallback openLink);

/// A builder for handling failure of loading rich information link.
///
/// It retrived [exception] of error occured and [openLink]
/// for opening website.
typedef MetaInfoFetchFailedBuilder = Widget Function(
    BuildContext context, Object exception, VoidCallback openLink);
