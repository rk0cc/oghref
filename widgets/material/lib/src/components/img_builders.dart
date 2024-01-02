import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A builder when loading content of image.
@internal
Widget loadingImageMaterial(
        BuildContext context, Widget child, ImageChunkEvent? loadingProcess) =>
    loadingProcess == null
        ? child
        : const Center(child: CircularProgressIndicator());

/// A builder when image load failed.
@internal
Widget errorImageMaterial(
        BuildContext context, Object error, StackTrace? stackTrace) =>
    const Center(child: Icon(Icons.broken_image_outlined));
