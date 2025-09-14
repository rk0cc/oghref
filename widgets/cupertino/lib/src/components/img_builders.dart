import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:oghref_builder/widgets.dart';

@internal
mixin class CupertinoImageLoadingEvent implements ImageLoadingEvent {
  @override
  Widget onLoadingImage(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProcess,
  ) => loadingProcess == null
      ? child
      : const Center(child: CupertinoActivityIndicator());

  @override
  Widget onErrorImageLoading(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) => const Center(child: Icon(CupertinoIcons.xmark_rectangle));
}
