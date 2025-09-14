import 'package:flutter/widgets.dart';

/// An enumerable class for specifying preference of indicator in [ImageCarousel].
///
/// It inherited by two classes with custom definitions of [style]
/// to satisify apperences which namely [DotPageIndication]
/// and [TextPageIndication]. Then, assign one of them into
/// [ImageCarouselPreferences.pageIndication].
@immutable
sealed class ImageCarouselPageIndication<
  T extends ImageCarouselPageIndicationStyle
> {
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
  const ImageCarouselPageIndicationStyle({
    this.primaryColour,
    this.secondaryColour,
  });
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
  const DotPageIndication({
    DotPageIndicationStyle style = const DotPageIndicationStyle(),
  }) : super._(style);
}

/// Style preference for [DotPageIndication] which applied from
/// [PageViewDotIndicator].
final class DotPageIndicationStyle extends ImageCarouselPageIndicationStyle {
  static const Size _DEFAULT_SIZE = Size(12, 12);

  /// Set [Size] of indicator when reaching current index.
  ///
  /// Default value is `12*12`.
  final Size size;

  /// Apply theme preference in [DotPageIndication].
  const DotPageIndicationStyle({
    super.primaryColour,
    super.secondaryColour,
    this.size = _DEFAULT_SIZE
  });
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
  const TextPageIndication({
    TextPageIndicationStyle style = const TextPageIndicationStyle(),
  }) : super._(style);
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
  /// If the original [Color] applied [Color.withValues] already,
  /// it will be overridden to [opacity] value.
  ///
  /// Default value is `0.7`.
  final double opacity;

  /// Specify padding of [Text] inside the [Container].
  final EdgeInsetsGeometry padding;

  /// Apply theme preference in [TextPageIndication].
  const TextPageIndicationStyle({
    super.primaryColour,
    super.secondaryColour,
    this.fontSize = 10,
    this.fontWeight = FontWeight.w300,
    this.opacity = 0.7,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
  });
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
  const ImageCarouselPreferences({
    this.controlIconSize = 18,
    this.controlButtonsSpacing = 5,
    this.pageChangeDuration = const Duration(milliseconds: 500),
    this.pageChangeCurve = Curves.easeInOut,
    this.showControlDuration = const Duration(milliseconds: 250),
    this.showControlCurve = Curves.easeOutSine,
    this.controlVisibleDuration = const Duration(seconds: 5),
    this.pageIndication = const DotPageIndication(),
    this.controlIconColour,
  });
}