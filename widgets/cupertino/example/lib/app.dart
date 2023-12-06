import 'package:flutter/cupertino.dart';
import 'package:oghref_cupertino/oghref_cupertino.dart';
import 'package:provider/provider.dart';

import 'theme_preference.dart';

class OgHrefCupertinoExampleHome extends StatefulWidget {
  const OgHrefCupertinoExampleHome({super.key});

  @override
  State<OgHrefCupertinoExampleHome> createState() =>
      _OgHrefCupertinoExampleHomeState();
}

final class _OgHrefCupertinoExampleHomeState
    extends State<OgHrefCupertinoExampleHome> {
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

  Future<bool> _confirmIsOpen(BuildContext context, Uri targetUrl) async {
    String decodedUrl = "$targetUrl";
    if (decodedUrl.contains("%")) {
      decodedUrl = Uri.decodeFull(decodedUrl);
    }

    bool? allowOpen = await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
                title: const Text("Open link"),
                content: Text("You are trying to open '$decodedUrl', proceed?"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop<bool>(context, true);
                      },
                      child: const Text("Continue")),
                  CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop<bool>(context, false);
                      },
                      child: const Text("Abort"))
                ]));

    return allowOpen ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final pref = Provider.of<ThemePreference>(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: const Text("OgHref Cupertino"),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CupertinoButton(
                      onPressed: () {
                        pref.darkMode = !pref.darkMode;
                      },
                      child: Icon(
                          pref.darkMode
                              ? CupertinoIcons.moon
                              : CupertinoIcons.sun_max,
                          size: 14))
                ])),
        child: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        flex: 8,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text("URL of website")),
                              CupertinoTextField(
                                  controller: controller,
                                  textInputAction: TextInputAction.go,
                                  onSubmitted: (_) {
                                    _applyChanges();
                                  },
                                  placeholder: "https://www.example.com",
                                  decoration: BoxDecoration(
                                      border: invalid
                                          ? Border.all(
                                              color: CupertinoColors
                                                  .destructiveRed)
                                          : null))
                            ])),
                    const Spacer(),
                    Expanded(
                        flex: 2,
                        child: CupertinoButton.filled(
                            onPressed: _applyChanges, child: const Text("Go")))
                  ])),
          const SizedBox(height: 16),
          Expanded(
              child: uri == null
                  ? const SizedBox()
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: <Widget>[
                        OgHrefCupertinoCard(uri!,
                            confirmation: _confirmIsOpen,
                            onLoading: (context) => const Center(
                                child: CupertinoActivityIndicator()),
                            multimedia: multimedia),
                        OgHrefCupertinoTile(uri!,
                            confirmation: _confirmIsOpen,
                            onLoading: (context) => const Center(
                                child: CupertinoActivityIndicator()))
                      ]
                          .map((e) =>
                              Align(alignment: Alignment.center, child: e))
                          .toList(),
                    ))
        ])));
  }
}
