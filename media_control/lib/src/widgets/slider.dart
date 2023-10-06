import 'package:flutter/widgets.dart' hide protected;
import 'package:meta/meta.dart';

import '../controller.dart';

abstract base class MediaControlWidget extends StatefulWidget {
  final MediaController? mediaController;
  
  MediaControlWidget({super.key, this.mediaController});
  
  @override
  MediaControlWidgetStateMixin createState();
}

mixin MediaControlWidgetStateMixin<T extends MediaControlWidget> on State<T> {
  late final MediaController mediaController;
  final MediaController _defaultMediaController = MediaController();

  @override
  void initState() {
    mediaController = widget.mediaController ?? _defaultMediaController;
    super.initState();
  }

  @override
  void dispose() {
    _defaultMediaController.dispose();
    super.dispose();
  }

  @protected
  void onDurationUpdate(double newDuration) {
    setState(() {
      mediaController.updateDuration(newDuration);
    });
  }
}