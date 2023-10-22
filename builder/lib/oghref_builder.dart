/// An abstrct [Widget] builder for constructing [Widget] of rich
/// information link.
library builder;

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:oghref_model/model.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher
    show canLaunchUrl, launchUrl;
import 'package:url_launcher/url_launcher.dart'
    hide
        canLaunchUrl,
        launchUrl,
        launch,
        closeInAppWebView,
        canLaunch,
        closeWebView;

export 'package:oghref_model/model.dart';

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

/// A utility for building [Widget] from [url] retrived [MetaInfo].
///
/// [MetaInfo] only retrive once such that the metadata may not load
/// correctly without retry.
class OgHrefBuilder extends StatefulWidget {
  /// URL of website.
  ///
  /// It must be HTTP or HTTPS.
  final Uri url;

  /// A [Widget] builder for handling [MetaInfo] retrived.
  ///
  /// [MetaInfo] may contains empty properties if
  /// failed to resolved.
  final MetaInfoRetrivedBuilder onRetrived;

  /// A [Widget] builder for handling errors during
  /// parsing [url] to [MetaInfo].
  final MetaInfoFetchFailedBuilder onFetchFailed;

  /// A [Widget] builder during fetching data.
  final WidgetBuilder? onLoading;

  /// A callback when the given [url] cannot opened.
  final VoidCallback? onOpenLinkFailed;

  /// Create a builder for retriving metadata from [url].
  OgHrefBuilder(this.url,
      {required this.onRetrived,
      required this.onFetchFailed,
      this.onLoading,
      this.onOpenLinkFailed,
      super.key});

  /// Create a builder for retiving the first received [url]
  /// and remain unchanged once it constructed until it removes
  /// from widget trees.
  factory OgHrefBuilder.runOnce(Uri url,
      {required MetaInfoRetrivedBuilder onRetrived,
      required MetaInfoFetchFailedBuilder onFetchFailed,
      WidgetBuilder? onLoading,
      VoidCallback? onOpenLinkFailed,
      Key? key}) = _RunOnceOgHrefBuilder;

  @override
  State<OgHrefBuilder> createState() => _OgHrefBuilderState();
}

final class _RunOnceOgHrefBuilder extends OgHrefBuilder {
  _RunOnceOgHrefBuilder(super.url,
      {required super.onRetrived,
      required super.onFetchFailed,
      super.onLoading,
      super.onOpenLinkFailed,
      super.key});

  @override
  State<_RunOnceOgHrefBuilder> createState() => _RunOnceOgHrefBuilderState();
}

base mixin _OgHrefBuilderStateMixin<T extends OgHrefBuilder> on State<T> {
  void _launchUrl() async {
    if (await url_launcher.canLaunchUrl(widget.url)) {
      url_launcher.launchUrl(widget.url, mode: LaunchMode.externalApplication);
    } else {
      if (widget.onOpenLinkFailed != null) {
        widget.onOpenLinkFailed!();
      }
    }
  }

  Widget _buildHref(BuildContext context, AsyncSnapshot<MetaInfo> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.active:
        if (snapshot.hasError) {
          return widget.onFetchFailed(context, snapshot.error!, _launchUrl);
        }
      case ConnectionState.done:
        if (snapshot.hasData) {
          return widget.onRetrived(context, snapshot.data!, _launchUrl);
        }
      default:
        break;
    }

    return (widget.onLoading ?? (_) => const SizedBox())(context);
  }
}

final class _OgHrefBuilderState extends State<OgHrefBuilder>
    with _OgHrefBuilderStateMixin {
  late Future<MetaInfo> metaInfoFetch;

  @override
  void initState() {
    super.initState();
    _bindMemorizer();
  }

  @override
  void didUpdateWidget(OgHrefBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bindMemorizer();
    }
  }

  void _bindMemorizer() {
    metaInfoFetch = MetaFetch().fetchFromHttp(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MetaInfo>(future: metaInfoFetch, builder: _buildHref);
  }
}

final class _RunOnceOgHrefBuilderState extends State<_RunOnceOgHrefBuilder>
    with _OgHrefBuilderStateMixin {
  late final AsyncMemoizer<MetaInfo> metaInfoMemorizer;

  @override
  void initState() {
    metaInfoMemorizer = AsyncMemoizer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MetaInfo>(
        future: metaInfoMemorizer
            .runOnce(() => MetaFetch().fetchFromHttp(widget.url)),
        builder: _buildHref);
  }
}
