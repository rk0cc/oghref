import 'package:oghref_model/model.dart';

void main() async {
  // Get instance of MetaFetch then register parser
  MetaFetch.instance.register(const OpenGraphPropertyParser());

  /* 
    Retrive MetaInfo from the first supported rich information protocol
    from the first <meta> tag in sequence.
  */
  MetaInfo info =
      await MetaFetch.instance.fetchFromHttp(Uri.https("example.com"));

  // Print retrived data.
  print(info.title);
}
