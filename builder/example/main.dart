/*
  This library can be uses in various theme of widget apps.

  In this example, it implement under Material.
*/
import 'package:flutter/material.dart';
import 'package:oghref_builder/oghref_builder.dart';

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  Widget _onRetrived(
      BuildContext context, MetaInfo metaInfo, VoidCallback openLink) {
    return ListTile(onTap: openLink, title: Text(metaInfo.title ?? ""));
  }

  Widget _onFetchFailed(
      BuildContext context, Object exception, VoidCallback openLink) {
    return ListTile(onTap: openLink, title: const Text("Error"));
  }

  @override
  Widget build(BuildContext context) {
    return OgHrefBuilder(Uri.parse("example.com"),
        onRetrived: _onRetrived, onFetchFailed: _onFetchFailed);
  }
}
