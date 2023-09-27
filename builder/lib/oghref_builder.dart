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

typedef MetaInfoRetrivedBuilder = Widget Function(
    BuildContext context, MetaInfo metaInfo, VoidCallback openLink);
typedef MetaInfoFetchFailedBuilder = Widget Function(
    BuildContext context, Object exception, VoidCallback openLink);

class OgHrefBuilder extends StatefulWidget {
  final Uri url;
  final MetaInfoRetrivedBuilder onRetrived;
  final MetaInfoFetchFailedBuilder onFetchFailed;
  final WidgetBuilder? onLoading;
  final VoidCallback? onOpenLinkFailed;

  OgHrefBuilder(this.url,
      {required this.onRetrived,
      required this.onFetchFailed,
      this.onLoading,
      this.onOpenLinkFailed});

  @override
  State<OgHrefBuilder> createState() => _OgHrefBuilderState();
}

final class _OgHrefBuilderState extends State<OgHrefBuilder> {
  late final AsyncMemoizer<MetaInfo> metaInfoMemorizer;

  @override
  void initState() {
    metaInfoMemorizer = AsyncMemoizer();
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MetaInfo>(
        future: metaInfoMemorizer
            .runOnce(() => MetaFetch().fetchFromHttp(widget.url)),
        builder: _buildHref);
  }
}
