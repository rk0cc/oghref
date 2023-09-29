import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart' hide protected;
import 'package:meta/meta.dart';

import 'playlist.dart' show AudioPlaylistIterator;

mixin AudioPlaybackControlState on State {
  late final AudioPlayer _player;

  @protected
  AudioPlaylistIterator get audioPlaylist;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }
}