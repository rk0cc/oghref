import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as mdc;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:oghref_builder/widgets.dart';

import 'img_builders.dart';

/// Cupertino themed [ImageCarousel].
///
/// This widgets may adapts Material's [mdc.ThemeData] for third-party
/// widget as these mostly implemented under Material [Widget]s.
base class CupertinoImageCarousel extends ImageCarousel {
  CupertinoImageCarousel(
    super.images, {
    super.preferHTTPS,
    super.preferences,
    super.key,
  });

  @override
  State<ImageCarousel> createState() {
    return _CupertinoImageCarouselState();
  }
}

final class _CupertinoImageCarouselState
    extends ImageCarouselState<CupertinoImageCarousel>
    with CupertinoImageLoadingEvent {
  @override
  Widget buildCarouselContext(BuildContext context, int maxImgIdx) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        // Images
        PageView.builder(
          controller: controller,
          itemBuilder: (context, index) =>
              buildSingleImage(context, widget.images[index]),
          itemCount: widget.images.length,
        ),
        // Page indicator
        Positioned(
          bottom: 10,
          child: buildControlWidgets(
            context,
            child: buildWithDeferredCtrl(
              context,
              builder: (context, snapshot) {
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
                            color:
                                (indication.style.secondaryColour ??
                                        currentTheme.scaffoldBackgroundColor)
                                    .withValues(
                                      alpha: indication.style.opacity,
                                    ),
                          ),
                          padding: indication.style.padding,
                          child: Text(
                            "${currentPage + 1} / ${maxImgIdx + 1}",
                            style: TextStyle(
                              fontWeight: indication.style.fontWeight,
                              fontSize: indication.style.fontSize,
                              color: indication.style.primaryColour,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      case DotPageIndication():
                        // Must be wrapped into Material widget since dot indicator uses material library
                        final materialTheme = mdc.ThemeData(
                          cupertinoOverrideTheme: currentTheme,
                        );

                        return mdc.Material(
                          child: SmoothPageIndicator(
                            controller: controller,
                            count: maxImgIdx + 1,
                            effect: SlideEffect(
                              activeDotColor:
                                  indication.style.primaryColour ??
                                  materialTheme.highlightColor,
                              dotColor:
                                  indication.style.secondaryColour ??
                                  materialTheme.disabledColor,
                              dotWidth: indication.style.size.width,
                              dotHeight: indication.style.size.height,
                            ),
                          ),
                        );
                    }
                  }
                }

                return const SizedBox();
              },
            ),
          ),
        ),
        // Move previous page button
        Positioned(
          left: widget.preferences.controlButtonsSpacing,
          child: buildControlWidgets(
            context,
            child: buildWithDeferredCtrl(
              context,
              builder: (context, snapshot) {
                VoidCallback? pressEvent;

                if (snapshot.hasData) {
                  pressEvent = (snapshot.data!.page?.floor() ?? 0) == 0
                      ? null
                      : movePrevious;
                }

                return CupertinoButton(
                  onPressed: pressEvent,
                  color: widget.preferences.controlIconColour,
                  child: Icon(
                    CupertinoIcons.back,
                    size: widget.preferences.controlIconSize,
                  ),
                );
              },
            ),
          ),
        ),
        // Move next page button
        Positioned(
          right: widget.preferences.controlButtonsSpacing,
          child: buildControlWidgets(
            context,
            child: buildWithDeferredCtrl(
              context,
              builder: (context, snapshot) {
                VoidCallback? pressEvent;

                if (snapshot.hasData) {
                  pressEvent =
                      (snapshot.data!.page?.ceil() ?? maxImgIdx) == maxImgIdx
                      ? null
                      : moveNext;
                }

                return CupertinoButton(
                  onPressed: pressEvent,
                  color: widget.preferences.controlIconColour,
                  child: Icon(
                    CupertinoIcons.forward,
                    size: widget.preferences.controlIconSize,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
