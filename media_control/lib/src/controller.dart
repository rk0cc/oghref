import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:meta/meta.dart';

final class MediaController extends ChangeNotifier {
  double _duration = 0;
  bool _isPlaying;

  MediaController({bool autoPlay = false}) : _isPlaying = autoPlay;

  void togglePlayback() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;

  void _updateDuration(double newDuration) {
    _duration = newDuration;
    notifyListeners();
  }

  double get duration => _duration;
}

@internal
extension MediaDurationUpdater on MediaController {
  void updateDuration(double newDuration) {
    _updateDuration(newDuration);
  }
}
