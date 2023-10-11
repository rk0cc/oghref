import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

abstract mixin class MediaPlaybackController {
  Player get player;

  void togglePlay() async {
    await player.playOrPause();
  }
}

class VideoPlaybackController extends VideoController with MediaPlaybackController {
  VideoPlaybackController(super.player);
  
  
}