import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:oghref_model/model.dart' as oghref;

import '../image_loading_event.dart';
import 'style.dart';

/// Reviewing multiple images provided from [oghref.ImageInfo] and
/// display all images in a single carousel [Widget].
///
/// Every images appeared in [ImageCarousel] will be cached already
/// that reducing duration of redownloading assets when same images
/// content will be displayed again.
abstract base class ImageCarousel extends StatefulWidget {
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

  /// Determine render preferences applied into this [ImageCarousel].
  final ImageCarouselPreferences preferences;

  /// Construct a new carousel [Widget] for displaying [images].
  ImageCarousel(
    this.images, {
    this.preferHTTPS = true,
    this.preferences = const ImageCarouselPreferences(),
    super.key,
  });

  @override
  State<ImageCarousel> createState();
}

enum _ShowControlMode {
  mouseHover(true),
  tapping(true),
  none(false);

  final bool showControl;

  const _ShowControlMode(this.showControl);
}

/// [State] of [ImageCarousel] for implemeting carousel widget under various UI design.
///
///
abstract base class ImageCarouselState<T extends ImageCarousel> extends State<T>
    implements ImageLoadingEvent {
  /// A controller uses for changing carousel content.
  late final PageController controller;

  /// A [Future] wrapper of [controller] that it avoids build error due to multiple build request.
  ///
  /// The value of this [Future] object is identical with [controller].
  @protected
  late final Future<PageController> deferredCtrl;

  late _ShowControlMode _showControlMode;

  Timer? _tappedFadeoutCallback;

  @mustCallSuper
  @override
  void initState() {
    controller = PageController();
    super.initState();
    _showControlMode = _ShowControlMode.none;
    deferredCtrl = Future.value(controller);
  }

  @mustCallSuper
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void movePrevious() async {
    await controller.previousPage(
      duration: widget.preferences.pageChangeDuration,
      curve: widget.preferences.pageChangeCurve,
    );
    setState(() {});
  }

  void moveNext() async {
    await controller.nextPage(
      duration: widget.preferences.pageChangeDuration,
      curve: widget.preferences.pageChangeCurve,
    );
    setState(() {});
  }

  @protected
  @nonVirtual
  Widget buildSingleImage(BuildContext context, oghref.ImageInfo imgInfo) {
    Uri? destination = imgInfo.url;

    if (widget.preferHTTPS && imgInfo.secureUrl != null) {
      destination = imgInfo.secureUrl;
    }

    return Image.network(
      destination!.toString(),
      fit: BoxFit.contain,
      headers: {"user-agent": oghref.MetaFetch.userAgentString},
      errorBuilder: onErrorImageLoading,
      loadingBuilder: onLoadingImage,
      semanticLabel: imgInfo.alt,
    );
  }

  @protected
  AnimatedOpacity buildControlWidgets(
    BuildContext context, {
    required Widget child,
  }) {
    return AnimatedOpacity(
      opacity: _showControlMode.showControl ? 1 : 0,
      duration: widget.preferences.showControlDuration,
      curve: widget.preferences.showControlCurve,
      child: child,
    );
  }

  @protected
  FutureBuilder<PageController> buildWithDeferredCtrl(
    BuildContext context, {
    required AsyncWidgetBuilder<PageController> builder,
  }) {
    return FutureBuilder(future: deferredCtrl, builder: builder);
  }

  @protected
  Widget buildCarouselContext(BuildContext context, int maxImgIdx);

  @override
  Widget build(BuildContext context) {
    final int maxImgIdx = widget.images.length - 1;

    return FocusableActionDetector(
      onShowHoverHighlight: (isHover) {
        // If fadeout function callback is assigned, cancel immediately.
        _tappedFadeoutCallback?.cancel();
        setState(() {
          _showControlMode = isHover
              ? _ShowControlMode.mouseHover
              : _ShowControlMode.none;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (_showControlMode == _ShowControlMode.mouseHover) {
            // Do not process if shown due to mouse hovering.
            return;
          }

          _tappedFadeoutCallback?.cancel();
          setState(() {
            _showControlMode = _ShowControlMode.tapping;
            _tappedFadeoutCallback = Timer(
              widget.preferences.controlVisibleDuration,
              () {
                setState(() {
                  _showControlMode = _ShowControlMode.none;
                });
              },
            );
          });
        },
        child: buildCarouselContext(context, maxImgIdx),
      ),
    );
  }
}
