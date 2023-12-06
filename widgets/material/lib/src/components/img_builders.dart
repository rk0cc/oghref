import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
Widget loadingImageMaterial(
        BuildContext context, Widget child, ImageChunkEvent? loadingProcess) =>
    loadingProcess == null
        ? child
        : const Center(child: CircularProgressIndicator());

@internal
Widget errorImageMaterial(
        BuildContext context, Object error, StackTrace? stackTrace) =>
    const Center(child: Icon(Icons.broken_image_outlined));
