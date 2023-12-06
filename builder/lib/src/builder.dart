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

import 'typedefs.dart';

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

  /// An event for getting consent of opening [url] by user which
  /// commonly launch a dialog to inform user.
  final OpenLinkConfirmation? openLinkConfirmation;

  /// Merge multiple protocols from [MetaFetch.fetchAllFromHttp] into
  /// single [MetaInfo].
  ///
  /// It it does not provided, the given [MetaInfo] will based on result of
  /// [MetaFetch.fetchFromHttp].
  final MultiMetaInfoHandler? multiInfoHandler;

  /// Create a builder for retriving metadata from [url].
  OgHrefBuilder(this.url,
      {required this.onRetrived,
      required this.onFetchFailed,
      this.onLoading,
      this.onOpenLinkFailed,
      this.openLinkConfirmation,
      this.multiInfoHandler,
      super.key});

  /// Create a builder for retiving the first received [url]
  /// and remain unchanged once it constructed until it removes
  /// from widget trees.
  factory OgHrefBuilder.runOnce(Uri url,
      {required MetaInfoRetrivedBuilder onRetrived,
      required MetaInfoFetchFailedBuilder onFetchFailed,
      WidgetBuilder? onLoading,
      VoidCallback? onOpenLinkFailed,
      OpenLinkConfirmation? openLinkConfirmation,
      MultiMetaInfoHandler? multiInfoHandler,
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
      super.openLinkConfirmation,
      super.multiInfoHandler,
      super.key});

  @override
  State<_RunOnceOgHrefBuilder> createState() => _RunOnceOgHrefBuilderState();
}

base mixin _OgHrefBuilderStateMixin<T extends OgHrefBuilder> on State<T> {
  void _launchUrl(BuildContext context) async {
    if (widget.openLinkConfirmation != null) {
      if (!await widget.openLinkConfirmation!(context, widget.url)) {
        return;
      }
    }

    if (await url_launcher.canLaunchUrl(widget.url)) {
      url_launcher.launchUrl(widget.url, mode: LaunchMode.externalApplication);
    } else {
      if (widget.onOpenLinkFailed != null) {
        widget.onOpenLinkFailed!();
      }
    }
  }

  Future<MetaInfo> _constructInfo() {
    if (widget.multiInfoHandler == null) {
      return MetaFetch().fetchFromHttp(widget.url);
    }

    return MetaFetch()
        .fetchAllFromHttp(widget.url)
        .then(widget.multiInfoHandler!);
  }

  Widget _buildHref(BuildContext context, AsyncSnapshot<MetaInfo> snapshot) {
    if (snapshot.hasError) {
      return widget.onFetchFailed(
          context, snapshot.error!, () => _launchUrl(context));
    } else if (!snapshot.hasData) {
      return (widget.onLoading ?? (_) => const SizedBox())(context);
    }

    return widget.onRetrived(
        context, snapshot.data!, () => _launchUrl(context));
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
    metaInfoFetch = _constructInfo();
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
        future: metaInfoMemorizer.runOnce(_constructInfo), builder: _buildHref);
  }
}
