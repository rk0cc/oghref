import 'package:flutter/widgets.dart';

abstract interface class ImageLoadingEvent {
  @protected
  Widget onLoadingImage(
        BuildContext context, Widget child, ImageChunkEvent? loadingProcess);

  @protected
  Widget onErrorImageLoading(
        BuildContext context, Object error, StackTrace? stackTrace);
}