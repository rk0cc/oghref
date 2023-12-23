import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch, MetaInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;

import 'button_states.dart';
import 'img_builders.dart';

/// Reviewing multiple images provided from [oghref.ImageInfo] and
/// display all images in a single carousel [Widget].
///
/// Every images appeared in [ImageCarousel] will be cached already
/// that reducing duration of redownloading assets when same images
/// content will be displayed again.
base class ImageCarousel extends StatefulWidget {
  /// Images metadata from [MetaInfo.images] in a single site.
  final List<oghref.ImageInfo> images;

  /// Uses [oghref.ImageInfo.secureUrl] instead of default value if available.
  ///
  /// This options is enabled by default in case with fulfillment
  /// of browsers' security policy when deploying Flutter web with
  /// `HTTPS` hosting. Eventhough there is no difference for running
  /// in native platform, it is recommended that keep this options
  /// enabled to prevents man-in-middle attack.
  final bool preferHTTPS;

  /// Define size of control icon for changing pages.
  ///
  /// Default value is `18`.
  final double controlIconSize;

  /// Specify [Duration] of animating page changes when event
  /// triggered.
  ///
  /// Default value is `500 ms`.
  final Duration pageChangeDuration;

  /// Define animation behaviour during [pageChangeDuration].
  ///
  /// By default, it uses [Curves.easeInOut].
  final Curve pageChangeCurve;

  /// Override a [Color] for displaying control icons if applied.
  final Color? iconColour;

  /// Construct a new carousel [Widget] for displaying [images].
  ImageCarousel(this.images,
      {this.preferHTTPS = true,
      this.controlIconSize = 18,
      this.pageChangeDuration = const Duration(milliseconds: 500),
      this.pageChangeCurve = Curves.easeInOut,
      this.iconColour,
      super.key});

  @override
  State<ImageCarousel> createState() {
    return _ImageCarouselState();
  }
}

final class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController controller;
  late final Future<PageController> deferredCtrl;

  late ButtonStyle appliedBtnStyle;

  @override
  void initState() {
    controller = PageController();
    super.initState();
    deferredCtrl = Future.value(controller);
    _bindBtnStyle();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void movePrevious() async {
    await controller.previousPage(
        duration: widget.pageChangeDuration, curve: widget.pageChangeCurve);
    setState(() {});
  }

  void moveNext() async {
    await controller.nextPage(
        duration: widget.pageChangeDuration, curve: widget.pageChangeCurve);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.iconColour != widget.iconColour) {
      _bindBtnStyle();
    }
  }

  void _bindBtnStyle() {
    appliedBtnStyle = ButtonStyle(
        foregroundColor: SingleButtonState<Color?>(widget.iconColour));
  }

  Widget _buildSingleImage(BuildContext context, oghref.ImageInfo imgInfo) {
    Uri? destination = imgInfo.url;

    if (widget.preferHTTPS && imgInfo.secureUrl != null) {
      destination = imgInfo.secureUrl;
    }

    return Image.network(destination!.toString(),
        fit: BoxFit.contain,
        headers: {"user-agent": MetaFetch.userAgentString},
        errorBuilder: errorImageFluent,
        loadingBuilder: loadingImageFluent,
        semanticLabel: imgInfo.alt);
  }

  FutureBuilder<PageController> _buildWithDeferredCtrl(BuildContext context,
      {required AsyncWidgetBuilder<PageController> builder}) {
    return FutureBuilder(future: deferredCtrl, builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
      // Images
      PageView.builder(
          controller: controller,
          itemBuilder: (context, index) =>
              _buildSingleImage(context, widget.images[index]),
          itemCount: widget.images.length),
      // Move previous page button
      Positioned(
          left: 0,
          child: _buildWithDeferredCtrl(context, builder: (context, snapshot) {
            VoidCallback? pressEvent;

            if (snapshot.hasData) {
              pressEvent = (snapshot.data!.page?.floor() ?? 0) == 0
                  ? null
                  : movePrevious;
            }

            return IconButton(
                onPressed: pressEvent,
                style: appliedBtnStyle,
                icon: Icon(FluentIcons.arrow_previous_16_regular,
                    size: widget.controlIconSize));
          })),
      // Move next page button
      Positioned(
          right: 0,
          child: _buildWithDeferredCtrl(context, builder: (context, snapshot) {
            final int maxLen = widget.images.length - 1;
            VoidCallback? pressEvent;

            if (snapshot.hasData) {
              pressEvent = (snapshot.data!.page?.ceil() ?? maxLen) == maxLen
                  ? null
                  : moveNext;
            }

            return IconButton(
                onPressed: pressEvent,
                style: appliedBtnStyle,
                icon: Icon(FluentIcons.arrow_next_16_regular,
                    size: widget.controlIconSize));
          }))
    ]);
  }
}
