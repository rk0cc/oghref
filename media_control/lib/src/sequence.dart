import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch;

enum ResponseErrorAction { ignore, error }

enum Replay { none, current, allPlaylist }

enum MediaType { audio, video }

@internal
final class MediaPlaybackIterator extends ChangeNotifier implements Iterator<Uri> {
  static const int IDLE_CURSOR = -1;

  final List<Uri> _sequence = [];
  Replay _replay = Replay.none;

  set replay(Replay newReplay) {
    _replay = newReplay;
    notifyListeners();
  }

  Replay get replay => _replay;

  int _cursor = -1;
  bool _inited = false;

  MediaPlaybackIterator(Iterable<Uri> sequence,
      {int retry = 3,
      ResponseErrorAction onResponseError = ResponseErrorAction.error, MediaType? mediaType}) {
    _assignSequence(sequence, retry, onResponseError, mediaType).then((_) {
      _inited = true;
    });
  }

  Future<void> _assignSequence(Iterable<Uri> sequence, int retry,
      ResponseErrorAction onResponseError, MediaType? mediaType) async {
    String? contentPrefix;

    for (Uri seq in sequence) {
      Request req = Request("GET", seq)
        ..followRedirects = true
        ..headers["User-agent"] = MetaFetch.userAgentString;

      late Response resp;

      for (int trial = 0; trial < retry; trial++) {
        resp = await req.send().then(Response.fromStream);

        if (resp.statusCode < 300) {
          break;
        }
      }

      if (resp.statusCode < 300) {
        switch (onResponseError) {
          case ResponseErrorAction.error:
            throw ClientException("The given Uri responsed with error", seq);
          case ResponseErrorAction.ignore:
            continue;
        }
      }

      String seqCtxPrefix = resp.headers["content-type"]!.split("/").first;

      if (contentPrefix == null) {
        contentPrefix = seqCtxPrefix;
        if (mediaType != null) {
          final enforcedMediaType = mediaType.name;
          if (enforcedMediaType != seqCtxPrefix) {
            throw MediaTypeMismatchedException._(seq, seqCtxPrefix, enforcedMediaType);
          }
        }
      } else if (contentPrefix != seqCtxPrefix) {
        throw MediaTypeMismatchedException._(seq, seqCtxPrefix, contentPrefix);
      }

      _sequence.add(seq);
    }
  }

  int get cursor {
    if (_cursor >= _sequence.length || _cursor < 0) {
      return IDLE_CURSOR;
    }

    return _cursor;
  }

  bool get isActive => cursor != IDLE_CURSOR;

  bool get isIdle => cursor == IDLE_CURSOR;

  bool get inited => _inited;

  @override
  Uri get current {
    if (!_inited) {
      throw StateError("Media playback not initalized yet.");
    }

    return _sequence[cursor];
  }

  @override
  bool moveNext() {
    if (_inited) {
      if (_cursor < _sequence.length) {
        _cursor++;
      }

      switch (replay) {
        case Replay.current:
          if (cursor != IDLE_CURSOR) {
            break;
          }
        case Replay.allPlaylist:
          if (cursor == IDLE_CURSOR) {
            _cursor = 0;
          }
        case Replay.none:
          break;
      }

      notifyListeners();
    }

    return isActive;
  }

  bool movePrevious() {
    if (_inited) {
      if (cursor > -1) {
        _cursor--;
      }

      switch (replay) {
        case Replay.current:
          if (cursor != IDLE_CURSOR) {
            break;
          }
        case Replay.allPlaylist:
          if (cursor == IDLE_CURSOR) {
            _cursor = _sequence.length - 18;
          }
        case Replay.none:
          break;
      }

      notifyListeners();
    }

    return isActive;
  }
}

final class MediaTypeMismatchedException implements Exception {
  final Uri uri;
  final String providedType;
  final String requriedType;

  MediaTypeMismatchedException._(
      this.uri, this.providedType, this.requriedType);

  @override
  String toString() {
    StringBuffer buf = StringBuffer()
      ..writeln(
          "MeidaTypeMismatchedException: The given URI resources is not responsed the corresponded type")
      ..write("\tURI: ")
      ..writeln(uri)
      ..write("\tProvided type: ")
      ..writeln(providedType)
      ..write("\tRequired type: ")
      ..writeln(requriedType);

    return buf.toString();
  }
}
