import 'package:oghref_model/model.dart';

void main() async {
  final MetaFetch metaFetch = MetaFetch()
    ..register(const OpenGraphPropertyParser());

  MetaInfo info = await metaFetch.fetchFromHttp(Uri.https("example.com"));
  print(info.title);
}
