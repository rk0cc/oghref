import 'dart:async';

import 'package:flutter/material.dart' hide immutable;
import 'package:meta/meta.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch, MetaInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

import 'img_builders.dart';

enum ImageCarouselPageIndication { text, dot }

/// Define preferences for visualizing [ImageCarousel].
@immutable
class ImageCarouselPreferences {
  /// Define size of control icon for changing pages.
  ///
  /// Default value is `18`.
  final double controlIconSize;

  /// Specify spaces of control buttons from nearest sides.
  ///
  /// Default defines as `5`.
  final double controlButtonsSpacing;

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
  final Color? controlIconColour;

  final Duration showControlDuration;

  final Curve showControlCurve;

  final Duration controlVisibleDuration;

  final ImageCarouselPageIndication pageIndication;

  /// Create preference of visualizing [ImageCarousel].
  const ImageCarouselPreferences(
      {this.controlIconSize = 18,
      this.controlButtonsSpacing = 5,
      this.pageChangeDuration = const Duration(milliseconds: 500),
      this.pageChangeCurve = Curves.easeInOut,
      this.showControlDuration = const Duration(milliseconds: 250),
      this.showControlCurve = Curves.easeOutSine,
      this.controlVisibleDuration = const Duration(seconds: 5),
      this.pageIndication = ImageCarouselPageIndication.dot,
      this.controlIconColour});
}

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

  final ImageCarouselPreferences preferences;

  /// Construct a new carousel [Widget] for displaying [images].
  ImageCarousel(this.images,
      {this.preferHTTPS = true,
      this.preferences = const ImageCarouselPreferences(),
      super.key});

  @override
  State<ImageCarousel> createState() {
    return _ImageCarouselState();
  }
}

enum _ShowControlMode {
  mouseHover(true),
  tapping(true),
  none(false);

  final bool showControl;

  const _ShowControlMode(this.showControl);
}

final class _ImageCarouselState extends State<ImageCarousel>
    with TickerProviderStateMixin {
  late final PageController controller;
  late final Future<PageController> deferredCtrl;
  late _ShowControlMode _showControlMode;
  Timer? _tappedFadeoutCallback;

  @override
  void initState() {
    _showControlMode = _ShowControlMode.none;
    controller = PageController();
    super.initState();
    deferredCtrl = Future.value(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void movePrevious() async {
    await controller.previousPage(
        duration: widget.preferences.pageChangeDuration,
        curve: widget.preferences.pageChangeCurve);
    setState(() {});
  }

  void moveNext() async {
    await controller.nextPage(
        duration: widget.preferences.pageChangeDuration,
        curve: widget.preferences.pageChangeCurve);
    setState(() {});
  }

  Widget _buildSingleImage(BuildContext context, oghref.ImageInfo imgInfo) {
    Uri? destination = imgInfo.url;

    if (widget.preferHTTPS && imgInfo.secureUrl != null) {
      destination = imgInfo.secureUrl;
    }

    return Image.network(destination!.toString(),
        fit: BoxFit.contain,
        headers: {"user-agent": MetaFetch.userAgentString},
        errorBuilder: errorImageMaterial,
        loadingBuilder: loadingImageMaterial,
        semanticLabel: imgInfo.alt);
  }

  FutureBuilder<PageController> _buildWithDeferredCtrl(BuildContext context,
      {required AsyncWidgetBuilder<PageController> builder}) {
    return FutureBuilder(future: deferredCtrl, builder: builder);
  }

  AnimatedOpacity _buildControlWidgets(BuildContext context,
      {required Widget child}) {
    return AnimatedOpacity(
        opacity: _showControlMode.showControl ? 1 : 0,
        duration: widget.preferences.showControlDuration,
        curve: widget.preferences.showControlCurve,
        child: child);
  }

  Stack _buildCarouselContext(BuildContext context, int maxImgIdx) {
    return Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
      // Images
      PageView.builder(
          controller: controller,
          itemBuilder: (context, index) =>
              _buildSingleImage(context, widget.images[index]),
          itemCount: widget.images.length),
      // Page indicator
      Positioned(
          bottom: 10,
          child: _buildControlWidgets(context,
              child:
                  _buildWithDeferredCtrl(context, builder: (context, snapshot) {
                final currentTheme = Theme.of(context);

                if (snapshot.hasData) {
                  final ctrl = snapshot.data!;

                  if (ctrl.hasClients) {
                    int currentPage = ctrl.page!.round();

                    switch (widget.preferences.pageIndication) {
                      case ImageCarouselPageIndication.text:
                        return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(currentTheme.useMaterial3 ? 12 : 4),
                                color: currentTheme.scaffoldBackgroundColor
                                .withOpacity(0.7)),
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
                            child: Text(
                              "${currentPage + 1} / ${maxImgIdx + 1}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 10),
                              textAlign: TextAlign.center,
                            ));
                      case ImageCarouselPageIndication.dot:
                        return PageViewDotIndicator(
                            currentItem: currentPage,
                            count: maxImgIdx + 1,
                            unselectedColor: currentTheme.disabledColor,
                            selectedColor: currentTheme.highlightColor);
                    }
                  }
                }

                return const SizedBox();
              }))),
      // Move previous page button
      Positioned(
          left: widget.preferences.controlIconSize,
          child: _buildControlWidgets(context,
              child:
                  _buildWithDeferredCtrl(context, builder: (context, snapshot) {
                VoidCallback? pressEvent;

                if (snapshot.hasData) {
                  pressEvent = (snapshot.data!.page?.floor() ?? 0) == 0
                      ? null
                      : movePrevious;
                }

                return IconButton(
                    onPressed: pressEvent,
                    color: widget.preferences.controlIconColour,
                    icon: Icon(Icons.arrow_back_ios_outlined,
                        size: widget.preferences.controlIconSize));
              }))),
      // Move next page button
      Positioned(
          right: widget.preferences.controlIconSize,
          child: _buildControlWidgets(context,
              child:
                  _buildWithDeferredCtrl(context, builder: (context, snapshot) {
                VoidCallback? pressEvent;

                if (snapshot.hasData) {
                  pressEvent =
                      (snapshot.data!.page?.ceil() ?? maxImgIdx) == maxImgIdx
                          ? null
                          : moveNext;
                }

                return IconButton(
                    onPressed: pressEvent,
                    color: widget.preferences.controlIconColour,
                    icon: Icon(Icons.arrow_forward_ios_outlined,
                        size: widget.preferences.controlIconSize));
              })))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final int maxImgIdx = widget.images.length - 1;

    return FocusableActionDetector(
        onShowHoverHighlight: (isHover) {
          // If fadeout function callback is assigned, cancel immediately.
          _tappedFadeoutCallback?.cancel();
          setState(() {
            _showControlMode =
                isHover ? _ShowControlMode.mouseHover : _ShowControlMode.none;
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
                _tappedFadeoutCallback =
                    Timer(widget.preferences.controlVisibleDuration, () {
                  setState(() {
                    _showControlMode = _ShowControlMode.none;
                  });
                });
              });
            },
            child: _buildCarouselContext(context, maxImgIdx)));
  }
}
