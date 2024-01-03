import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

/// A widget builder to handle loading image event.
@internal
Widget loadingImageCupertino(
        BuildContext context, Widget child, ImageChunkEvent? loadingProcess) =>
    loadingProcess == null
        ? child
        : const Center(child: CupertinoActivityIndicator());

/// Specify [Widget] to show when image cannot be loaded.
@internal
Widget errorImageCupertino(
        BuildContext context, Object error, StackTrace? stackTrace) =>
    const Center(child: Icon(CupertinoIcons.xmark_rectangle));
