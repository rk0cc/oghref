import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' show Client;
import 'package:meta/meta.dart';

@internal
Client initializeClient() => FetchClient(mode: RequestMode.cors);
