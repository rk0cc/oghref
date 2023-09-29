import 'package:http/http.dart'
    hide delete, get, patch, post, put, read, readBytes, head, runWithClient;
import 'package:meta/meta.dart';
import 'package:oghref_builder/oghref_builder.dart' show MetaFetch;

enum ReplayPreference { none, all, once }

abstract final class MediaPlaylistIterator implements Iterator<Uri> {
  final List<Uri> _playlist = [];
  int _cursor = -1;
  ReplayPreference replay = ReplayPreference.none;

  MediaPlaylistIterator(Iterable<Uri> playlist) {
    _assign(playlist);
  }

  @nonVirtual
  void _assign(Iterable<Uri> playlist) async {
    for (Uri resourceUrl in playlist) {
      Request req = Request("GET", resourceUrl)
        ..headers["User-Agent"] = MetaFetch.userAgentString
        ..followRedirects = true;

      Response resp = await Response.fromStream(await req.send());
      if (resp.statusCode == 200) {
        String contentType = resp.headers["Content-type"]!;
        if (verifyType(contentType)) {
          _playlist.add(resourceUrl);
        }
      }
    }
  }

  @protected
  bool verifyType(String contentType);

  @override
  Uri get current => _playlist[_cursor];

  @override
  bool moveNext() {
    int nextCursor = _cursor + 1;

    if (nextCursor >= 0 && nextCursor < _playlist.length) {
      if (replay != ReplayPreference.once) {
        _cursor++;
      }
      return true;
    }

    switch (replay) {
      case ReplayPreference.once:
        _cursor = 0;
        return true;
      case ReplayPreference.all:
        _cursor = -1;
      case ReplayPreference.none:
        break;
    }

    return false;
  }
}

final class AudioPlaylistIterator extends MediaPlaylistIterator {
  AudioPlaylistIterator(super.playlist);

  @override
  bool verifyType(String contentType) =>
      contentType.split("/").first.toLowerCase() == "audio";
}

final class VideoPlaylistIterator extends MediaPlaylistIterator {
  VideoPlaylistIterator(super.playlist);

  @override
  bool verifyType(String contentType) =>
      contentType.split("/").first.toLowerCase() == "video";
}
