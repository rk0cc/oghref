import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch;

enum ResponseErrorAction { ignore, error }

enum Replay { none, current, allPlaylist }

final class MediaPlaybackIterator implements Iterator<Uri> {
  static const int IDLE_CURSOR = -1;

  final List<Uri> _sequence = [];
  Replay replay = Replay.none;
  int _cursor = -1;
  bool _inited = false;

  MediaPlaybackIterator(Iterable<Uri> sequence,
      {int retry = 3,
      ResponseErrorAction onResponseError = ResponseErrorAction.error}) {
    _assignSequence(sequence, retry, onResponseError).then((_) {
      _inited = true;
    });
  }

  Future<void> _assignSequence(Iterable<Uri> sequence, int retry,
      ResponseErrorAction onResponseError) async {
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

  @override
  Uri get current => _sequence[cursor];

  @override
  bool moveNext() {
    if (_inited) {
      _cursor++;

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
    }

    return cursor != IDLE_CURSOR;
  }

  bool movePrevious() {
    if (_inited) {
      _cursor--;

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
    }

    return cursor != IDLE_CURSOR;
  }
}

final class MediaTypeMismatchedException implements Exception {
  final Uri uri;
  final String providedType;
  final String requriedType;

  MediaTypeMismatchedException._(this.uri, this.providedType, this.requriedType);

  @override
  String toString() {
    StringBuffer buf = StringBuffer()..writeln("MeidaTypeMismatchedException: The given URI resources is not responsed the corresponded type")
        ..write("\tURI: ")..writeln(uri)
        ..write("\tProvided type: ")..writeln(providedType)
        ..write("\tRequired type: ")..writeln(requriedType);

    return buf.toString();
  }
}
