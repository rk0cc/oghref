import 'package:http/http.dart' show ClientException;

/// An exception implement under [ClientException] that using invalid
/// content type from given [uri].
final class ContentTypeMismatchedException implements ClientException {
  /// An [Uri] which locates to invalid content type.
  @override
  final Uri uri;

  /// Content type value from response of [uri].
  final String? receivedContentType;

  /// Specify a [Set] with MIME [String] which required for following process.
  ///
  /// It will assume as plain text if it contains empty.
  final Set<String> idealContentType;

  /// Construct an exception when using incorrect content type.
  ContentTypeMismatchedException(
      this.uri, this.receivedContentType, this.idealContentType);

  /// Message displayed to inform invalid content type should not be
  /// accepted.
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
