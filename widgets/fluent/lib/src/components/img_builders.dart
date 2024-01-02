import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:meta/meta.dart';

/// A [Widget] builder for building loading image until completed.
@internal
Widget loadingImageFluent(
        BuildContext context, Widget child, ImageChunkEvent? loadingProcess) =>
    loadingProcess == null ? child : const Center(child: ProgressRing());

/// A [Widget] builder for building error widgets once load failed.
@internal
Widget errorImageFluent(
        BuildContext context, Object error, StackTrace? stackTrace) =>
    const Center(child: Icon(FluentIcons.image_off_20_regular));
