import 'package:http/http.dart' show ClientException;

final class ContentTypeMismatchedException implements ClientException {
  @override
  final Uri uri;

  final String? receivedContentType;

  final Set<String> idealContentType;

  ContentTypeMismatchedException(
      this.uri, this.receivedContentType, this.idealContentType);

  @override
  String get message =>
      "The given content type is not accepted for application.";

  @override
  String toString() {
    StringBuffer buf = StringBuffer()
      ..write("ContentTypeMismatchedException: ")
      ..writeln(message)
      ..writeCharCode(9)
      ..write("Accepted content type: ");

    if (idealContentType.isNotEmpty) {
      buf.writeln(idealContentType);
    } else {
      buf.writeln(["text/plain"]);
    }

    buf
      ..writeCharCode(9)
      ..write("Received content type: ")
      ..writeln(receivedContentType ?? "(Unknown)");

    return buf.toString();
  }
}