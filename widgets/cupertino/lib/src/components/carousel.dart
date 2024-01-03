import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as mdc;
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch, MetaInfo;
import 'package:oghref_builder/oghref_builder.dart' as oghref show ImageInfo;
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

import 'img_builders.dart';

/// An enumerable class for specifying preference of indicator in [ImageCarousel].
///
/// It inherited by two classes with custom definitions of [style]
/// to satisify apperences which namely [DotPageIndication]
/// and [TextPageIndication]. Then, assign one of them into
/// [ImageCarouselPreferences.pageIndication].
@immutable
sealed class ImageCarouselPageIndication<
    T extends ImageCarouselPageIndicationStyle> {
  /// Style preference of applied indication widgets.
  ///
  /// Generic parameter [T] must be extended from [ImageCarouselPageIndicationStyle].
  final T style;

  const ImageCarouselPageIndication._(this.style);
}

/// Specify styles apperences for specific [ImageCarouselPageIndication].
///
/// It only comes with two nullable [Color] properties
/// depending on applied preferences according to
/// child classes documentations.
@immutable
abstract final class ImageCarouselPageIndicationStyle {
  /// A [Color] used for indicating activated or foreground colour.
  final Color? primaryColour;

  /// A [Color] used for indicating inactive or background colour.
  final Color? secondaryColour;

  /// Construct foundation preferences themeing for [ImageCarouselPageIndication].
  const ImageCarouselPageIndicationStyle(
      {this.primaryColour, this.secondaryColour});
}

/// One of the [ImageCarouselPageIndication] preference which display pages
/// indication as dot view.
///
/// When it assigned into [ImageCarouselPreferences.pageIndication],
/// the indicator which rendered at the bottom of [ImageCarousel]
/// will be adopted by [PageViewDotIndicator].
final class DotPageIndication
    extends ImageCarouselPageIndication<DotPageIndicationStyle> {
  /// Specify [ImageCarousel] to render page indicator with
  /// [PageViewDotIndicator] with applied [style].
  ///
  /// For applied [Color] in given [style], [DotPageIndicationStyle.primaryColour]
  /// uses as [PageViewDotIndicator.selectedColor] and
  /// [DotPageIndicationStyle.secondaryColour] uses as [PageViewDotIndicator.unselectedColor]
  /// respectedly.
  const DotPageIndication(
      {DotPageIndicationStyle style = const DotPageIndicationStyle()})
      : super._(style);
}

/// Style preference for [DotPageIndication] which applied from
/// [PageViewDotIndicator].
final class DotPageIndicationStyle extends ImageCarouselPageIndicationStyle {
  static const Size _DEFAULT_SIZE = Size(12, 12);

  /// Determine the indicator's edges should be faded.
  final bool fadeEdges;

  /// Specify shape of indicator.
  final BoxShape shape;

  /// Set [Size] of indicator when reaching current index.
  ///
  /// Default value is `12*12`.
  final Size activeSize;

  /// Set [Size] of indicator when not in active.
  ///
  /// /// Default value is `12*12`.
  final Size inactiveSize;

  /// Define radius of indicators.
  final BorderRadius? radius;

  /// Apply theme preference in [DotPageIndication].
  const DotPageIndicationStyle(
      {super.primaryColour,
      super.secondaryColour,
      this.shape = BoxShape.circle,
      this.fadeEdges = true,
      this.activeSize = _DEFAULT_SIZE,
      this.inactiveSize = _DEFAULT_SIZE,
      this.radius});
}

/// One of the [ImageCarouselPageIndication] preference which display pages
/// indication as dot view.
///
/// When it assigned into [ImageCarouselPreferences.pageIndication],
/// the indicator which rendered at the bottom of [ImageCarousel]
/// will be adopted by [Text] which wrapped by [Container] for
/// additional theme preferences.
final class TextPageIndication
    extends ImageCarouselPageIndication<TextPageIndicationStyle> {
  /// Specify [ImageCarousel] to render page indicator with
  /// [Text] and [Container] with applied [style].
  ///
  /// For applied [Color] in given [style], [TextPageIndicationStyle.primaryColour]
  /// uses as [TextStyle.color] of the [Text] and
  /// [DotPageIndicationStyle.secondaryColour] uses as
  /// background colour of [Container].
  const TextPageIndication(
      {TextPageIndicationStyle style = const TextPageIndicationStyle()})
      : super._(style);
}

/// Style preference for [TextPageIndication] which applied from
/// [PageViewDotIndicator].
final class TextPageIndicationStyle extends ImageCarouselPageIndicationStyle {
  /// Determine size of the font.
  ///
  /// Default value is `10`.
  final double fontSize;

  /// Specify weight of the font.
  ///
  /// Default value is [FontWeight.w300].
  final FontWeight fontWeight;

  /// Opacity of [Container].
  ///
  /// If the original [Color] applied [Color.withOpacity] already,
  /// it will be overridden to [opacity] value.
  ///
  /// Default value is `0.7`.
  final double opacity;

  /// Specify padding of [Text] inside the [Container].
  final EdgeInsetsGeometry padding;

  /// Apply theme preference in [TextPageIndication].
  const TextPageIndicationStyle(
      {super.primaryColour,
      super.secondaryColour,
      this.fontSize = 10,
      this.fontWeight = FontWeight.w300,
      this.opacity = 0.7,
      this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 4)});
}

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

  /// Set [Duration] for perform animations to show or hide
  /// control widgets.
  ///
  /// Default value is 250 miliseconds.
  final Duration showControlDuration;

  /// Determine [Curve] of fading control widgets.
  ///
  /// Default value is [Curves.easeOutSine].
  final Curve showControlCurve;

  /// Determine visible [Duration] of control widgets if
  /// it triggered by tapping [ImageCarousel] area.
  ///
  /// Default value is 5 seconds.
  final Duration controlVisibleDuration;

  /// Determine which widget used for displaying
  /// page indication.
  ///
  /// The possible value is either [DotPageIndication] (as default)
  /// or [TextPageIndication].
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
      this.pageIndication = const DotPageIndication(),
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

  /// Determine render preferences applied into this [ImageCarousel].
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

final class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController controller;
  late final Future<PageController> deferredCtrl;
  late _ShowControlMode _showControlMode;
  Timer? _tappedFadeoutCallback;

  @override
  void initState() {
    controller = PageController();
    super.initState();
    _showControlMode = _ShowControlMode.none;
    deferredCtrl = Future.value(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void movePrevious() async {
    await controller.previousPage(
        duration: widget.preferences.pageChangeDuration, curve: widget.preferences.pageChangeCurve);
    setState(() {});
  }

  void moveNext() async {
    await controller.nextPage(
        duration: widget.preferences.pageChangeDuration, curve: widget.preferences.pageChangeCurve);
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
        errorBuilder: errorImageCupertino,
        loadingBuilder: loadingImageCupertino,
        semanticLabel: imgInfo.alt);
  }

  AnimatedOpacity _buildControlWidgets(BuildContext context,
      {required Widget child}) {
    return AnimatedOpacity(
        opacity: _showControlMode.showControl ? 1 : 0,
        duration: widget.preferences.showControlDuration,
        curve: widget.preferences.showControlCurve,
        child: child);
  }

  FutureBuilder<PageController> _buildWithDeferredCtrl(BuildContext context,
      {required AsyncWidgetBuilder<PageController> builder}) {
    return FutureBuilder(future: deferredCtrl, builder: builder);
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
                final currentTheme = CupertinoTheme.of(context);

                if (snapshot.hasData) {
                  final ctrl = snapshot.data!;

                  if (ctrl.hasClients) {
                    int currentPage = ctrl.page!.round();
                    final indication = widget.preferences.pageIndication;

                    switch (indication) {
                      case TextPageIndication():
                        return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: (indication.style.secondaryColour ??
                                        currentTheme.scaffoldBackgroundColor)
                                    .withOpacity(indication.style.opacity)),
                            padding: indication.style.padding,
                            child: Text(
                              "${currentPage + 1} / ${maxImgIdx + 1}",
                              style: TextStyle(
                                  fontWeight: indication.style.fontWeight,
                                  fontSize: indication.style.fontSize,
                                  color: indication.style.primaryColour),
                              textAlign: TextAlign.center,
                            ));
                      case DotPageIndication():
                        // Must be wrapped into Material widget since dot indicator uses material library
                        final materialTheme = mdc.ThemeData(cupertinoOverrideTheme: currentTheme);

                        return mdc.Material(
                          child: PageViewDotIndicator(
                            currentItem: currentPage,
                            count: maxImgIdx + 1,
                            fadeEdges: indication.style.fadeEdges,
                            boxShape: indication.style.shape,
                            borderRadius: indication.style.radius,
                            size: indication.style.activeSize,
                            unselectedSize: indication.style.inactiveSize,
                            unselectedColor: indication.style.secondaryColour ??
                                materialTheme.highlightColor,
                            selectedColor: indication.style.primaryColour ??
                                materialTheme.disabledColor)
                        );
                    }
                  }
                }

                return const SizedBox();
              }))),
      // Move previous page button
      Positioned(
          left: 0,
          child: _buildControlWidgets(context,
              child: _buildWithDeferredCtrl(context, builder: (context, snapshot) {
            VoidCallback? pressEvent;

            if (snapshot.hasData) {
              pressEvent = (snapshot.data!.page?.floor() ?? 0) == 0
                  ? null
                  : movePrevious;
            }

            return CupertinoButton(
                onPressed: pressEvent,
                color: widget.preferences.controlIconColour,
                child: Icon(CupertinoIcons.back, size: widget.preferences.controlIconSize));
          }))),
      // Move next page button
      Positioned(
          right: 0,
          child: _buildControlWidgets(context,
              child: _buildWithDeferredCtrl(context, builder: (context, snapshot) {
            VoidCallback? pressEvent;

            if (snapshot.hasData) {
              pressEvent = (snapshot.data!.page?.ceil() ?? maxImgIdx) == maxImgIdx
                  ? null
                  : moveNext;
            }

            return CupertinoButton(
                onPressed: pressEvent,
                color: widget.preferences.controlIconColour,
                child:
                    Icon(CupertinoIcons.forward, size: widget.preferences.controlIconSize));
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
