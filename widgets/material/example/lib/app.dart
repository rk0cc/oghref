import 'package:flutter/material.dart';
import 'package:oghref_material/oghref_material.dart';
import 'package:provider/provider.dart';

import 'theme_preference.dart';

class OgHrefMaterialExampleHome extends StatefulWidget {
  const OgHrefMaterialExampleHome({super.key});

  @override
  State<StatefulWidget> createState() => _OgHrefMaterialExampleHomeState();
}

class _OgHrefMaterialExampleHomeState extends State<OgHrefMaterialExampleHome> {
  late final TextEditingController controller;
  Uri? uri;
  bool invalid = false;
  bool multimedia = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _applyChanges() {
    setState(() {
      if (controller.text.isEmpty) {
        uri = null;
        invalid = false;
        return;
      }

      try {
        Uri parsed = Uri.parse(controller.text);

        if (!["http", "https"].contains(parsed.scheme)) {
          throw "Non-HTTP(S) URL";
        }

        uri = parsed;
        invalid = false;
      } catch (err) {
        uri = null;
        invalid = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pref = Provider.of<ThemePreference>(context);

    return Scaffold(
        appBar: AppBar(title: const Text("OgHref Material"), actions: <Tooltip>[
          Tooltip(
              message: "Switch to ${pref.darkMode ? 'light' : 'dark'} mode",
              child: IconButton(
                  onPressed: () {
                    pref.darkMode = !pref.darkMode;
                  },
                  icon: Icon(pref.darkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined))),
          Tooltip(
              message: "Use Material ${pref.materialThree ? 2 : 3} theme",
              child: IconButton(
                  onPressed: () {
                    pref.materialThree = !pref.materialThree;
                  },
                  icon: const Icon(Icons.palette_outlined))),
          Tooltip(
              message:
                  "${multimedia ? 'Disable' : 'Enable'} multimedia content",
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      multimedia = !multimedia;
                    });
                  },
                  icon: Icon(multimedia ? Icons.movie : Icons.movie_outlined)))
        ]),
        body: Column(
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(children: [
                  Expanded(
                      flex: 8,
                      child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              errorText: invalid ? "Invalid URL website" : null,
                              hintText: "https://www.example.com",
                              labelText: "URL of website"))),
                  const Spacer(),
                  Expanded(
                      flex: 2,
                      child: ElevatedButton(
                          onPressed: _applyChanges, child: const Text("Go")))
                ])),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Divider()),
            Expanded(
                child: uri == null
                    ? const SizedBox()
                    : ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        children: <Widget>[
                          OgHrefMaterialCard(uri!,
                              onLoading: (context) => const Center(
                                  child: CircularProgressIndicator()),
                              multimedia: multimedia),
                              OgHrefMaterialTile(uri!)
                        ]
                            .map((e) =>
                                Align(alignment: Alignment.center, child: e))
                            .toList(),
                      ))
          ],
        ));
  }
}
