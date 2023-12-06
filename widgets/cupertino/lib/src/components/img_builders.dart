import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@internal
Widget loadingImageCupertino(
        BuildContext context, Widget child, ImageChunkEvent? loadingProcess) =>
    loadingProcess == null
        ? child
        : const Center(child: CupertinoActivityIndicator());

@internal
Widget errorImageCupertino(
        BuildContext context, Object error, StackTrace? stackTrace) =>
    const Center(child: Icon(CupertinoIcons.xmark_rectangle));
