import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

final class MaterialMediaController extends StatelessWidget {
  final Player player;

  MaterialMediaController(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    final mediaDuration = player.stream.duration;
    final mediaPosition = player.stream.position;
    final isPlaying = player.stream.playing;
    void changeDuration(Duration newDuration) {
      player.seek(newDuration);
    }

    final moveNext = player.next;
    final movePrevious = player.previous;
    void muteOrUnmute() {
      player.setVolume(player.state.volume == 0 ? 100 : 0);
    }

    final playOrPause = player.playOrPause;

    switch (Theme.of(context).platform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return _MaterialMediaDesktopController(
            mediaDuration: mediaDuration,
            mediaPosition: mediaPosition,
            isPlaying: isPlaying,
            changeDuration: changeDuration,
            moveNext: moveNext,
            movePrevious: movePrevious,
            muteOrUnmute: muteOrUnmute,
            playOrPause: playOrPause);
      default:
        return _MaterialMediaMobileController(
            mediaDuration: mediaDuration,
            mediaPosition: mediaPosition,
            isPlaying: isPlaying,
            changeDuration: changeDuration,
            moveNext: moveNext,
            movePrevious: movePrevious,
            muteOrUnmute: muteOrUnmute,
            playOrPause: playOrPause);
    }
  }
}

abstract final class _MaterialMediaPlatformController extends StatefulWidget {
  final Stream<Duration> mediaDuration;
  final Stream<Duration> mediaPosition;
  final Stream<bool> isPlaying;
  final void Function(Duration) changeDuration;
  final VoidCallback moveNext;
  final VoidCallback movePrevious;
  final VoidCallback muteOrUnmute;
  final VoidCallback playOrPause;

  _MaterialMediaPlatformController(
      {required this.mediaDuration,
      required this.mediaPosition,
      required this.isPlaying,
      required this.changeDuration,
      required this.moveNext,
      required this.movePrevious,
      required this.muteOrUnmute,
      required this.playOrPause,
      super.key});

  @override
  State<_MaterialMediaPlatformController> createState();
}

final class _MaterialMediaDesktopController
    extends _MaterialMediaPlatformController {
  _MaterialMediaDesktopController(
      {required super.mediaDuration,
      required super.mediaPosition,
      required super.isPlaying,
      required super.changeDuration,
      required super.moveNext,
      required super.movePrevious,
      required super.muteOrUnmute,
      required super.playOrPause});

  @override
  State<_MaterialMediaDesktopController> createState() {
    return _MaterialMediaDesktopControllerState();
  }
}

final class _MaterialMediaDesktopControllerState extends State<_MaterialMediaDesktopController> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

final class _MaterialMediaMobileController
    extends _MaterialMediaPlatformController {
  _MaterialMediaMobileController(
      {required super.mediaDuration,
      required super.mediaPosition,
      required super.isPlaying,
      required super.changeDuration,
      required super.moveNext,
      required super.movePrevious,
      required super.muteOrUnmute,
      required super.playOrPause});

  @override
  State<_MaterialMediaMobileController> createState() {
    return _MaterialMediaMobileControllerState();
  }
}

final class _MaterialMediaMobileControllerState extends State<_MaterialMediaMobileController> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
