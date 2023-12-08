import 'package:flutter/widgets.dart' hide protected;
import 'package:meta/meta.dart';
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
abstract base class OgHrefBuilder extends StatefulWidget {
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

  /// Create a builder for retiving received [url] and
  /// update content when the value changes on parent [Widget].
  factory OgHrefBuilder.updatable(Uri url,
      {required MetaInfoRetrivedBuilder onRetrived,
      required MetaInfoFetchFailedBuilder onFetchFailed,
      WidgetBuilder? onLoading,
      VoidCallback? onOpenLinkFailed,
      OpenLinkConfirmation? openLinkConfirmation,
      MultiMetaInfoHandler? multiInfoHandler,
      Key? key}) = _UpdatableOgHrefBuilder;

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
  State<OgHrefBuilder> createState();
}

/// [State] implementation of [OgHrefBuilder] with additional functions
/// provided for rendering content of rich information link.
///
/// [build] has been implemented [FutureBuilder] and binded
/// [metaInfo] as [FutureBuilder.future] and [AsyncWidgetBuilder]
/// already. It is possible to override it but requied calling super
/// which should be assumed as child of [Widget].
abstract base class OgHrefBuilderState<T extends OgHrefBuilder>
    extends State<T> {
  /// An instance of getting [MetaInfo] in [FutureBuilder.future].
  ///
  /// [FutureBuilder] will rebuilding [Widget] by assigning new
  /// [Future] into it.
  @protected
  Future<MetaInfo> get metaInfo;

  /// Activate opening browser and located [OgHrefBuilder.url].
  ///
  /// This can be called once [context] is offered anywhere.
  @nonVirtual
  void launchUrl(BuildContext context) async {
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

  /// Constructing [MetaInfo] from [OgHrefBuilder.url].
  ///
  /// If [OgHrefBuilder.multiInfoHandler] provided, it returns the
  /// selected result from all metadata protocols uses in
  /// [MetaFetch.fetchAllFromHttp]. Otherwise, it proxies
  /// [MetaFetch.fetchFromHttp].
  ///
  /// Ideally, it should be used for assigning [metaInfo]
  /// to trigger rebuild.
  @protected
  @nonVirtual
  Future<MetaInfo> constructInfo() {
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
          context, snapshot.error!, () => launchUrl(context));
    } else if (!snapshot.hasData ||
        snapshot.connectionState == ConnectionState.waiting) {
      return (widget.onLoading ?? (_) => const SizedBox())(context);
    }

    return widget.onRetrived(context, snapshot.data!, () => launchUrl(context));
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return FutureBuilder<MetaInfo>(future: metaInfo, builder: _buildHref);
  }
}

final class _UpdatableOgHrefBuilder extends OgHrefBuilder {
  _UpdatableOgHrefBuilder(super.url,
      {required super.onRetrived,
      required super.onFetchFailed,
      super.onLoading,
      super.onOpenLinkFailed,
      super.openLinkConfirmation,
      super.multiInfoHandler,
      super.key});

  @override
  State<_UpdatableOgHrefBuilder> createState() =>
      _UpdatableOgHrefBuilderState();
}

final class _UpdatableOgHrefBuilderState
    extends OgHrefBuilderState<_UpdatableOgHrefBuilder> {
  @override
  late Future<MetaInfo> metaInfo;

  @override
  void initState() {
    super.initState();
    _bindMemorizer();
  }

  @override
  void didUpdateWidget(covariant _UpdatableOgHrefBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bindMemorizer();
    }
  }

  void _bindMemorizer() {
    metaInfo = constructInfo();
  }
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

final class _RunOnceOgHrefBuilderState
    extends OgHrefBuilderState<_RunOnceOgHrefBuilder> {
  @override
  late final Future<MetaInfo> metaInfo;

  @override
  void initState() {
    super.initState();
    metaInfo = constructInfo();
  }
}
