import 'package:fluent_ui/fluent_ui.dart';
import 'package:oghref_fluent/oghref_fluent.dart';
import 'package:provider/provider.dart';

import 'theme_preference.dart';

class OgHrefFluentExampleHome extends StatefulWidget {
  const OgHrefFluentExampleHome({super.key});

  @override
  State<OgHrefFluentExampleHome> createState() =>
      _OgHrefFluentExampleHomeState();
}

class _OgHrefFluentExampleHomeState extends State<OgHrefFluentExampleHome> {
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

    bool? allowOpen = await showDialog(
        context: context,
        builder: (context) => ContentDialog(
                title: const Text("Open link"),
                content: Text("You are trying to open '$decodedUrl', proceed?"),
                actions: <Button>[
                  Button(
                      onPressed: () {
                        Navigator.pop<bool>(context, true);
                      },
                      child: const Text("Continue")),
                  Button(
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

    return ScaffoldPage(
        header: PageHeader(
            title: const Text("OgHref Fluent"),
            commandBar: CommandBar(
                mainAxisAlignment: MainAxisAlignment.end,
                primaryItems: <CommandBarItem>[
                  CommandBarButton(
                      onPressed: () {
                        pref.darkMode = !pref.darkMode;
                      },
                      icon: Icon(pref.darkMode
                          ? FluentIcons.clear_night
                          : FluentIcons.sunny))
                ])),
        content: NavigationView(
            content: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        flex: 8,
                        child: InfoLabel(
                            label: "URL of website",
                            child: TextBox(
                                controller: controller,
                                placeholder: "https://www.example.com",
                                decoration: BoxDecoration(
                                    border: invalid
                                        ? const Border(
                                            bottom: BorderSide(
                                                color:
                                                    Colors.errorPrimaryColor))
                                        : null)))),
                    const Spacer(),
                    Expanded(
                        flex: 2,
                        child: FilledButton(
                            onPressed: _applyChanges,
                            style: const ButtonStyle(
                                backgroundColor: _GoButtonState()),
                            child: const Text("Go")))
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
                        OgHrefFluentCard(uri!,
                            confirmation: _confirmIsOpen,
                            onLoading: (context) =>
                                const Center(child: ProgressRing()),
                            multimedia: multimedia),
                        OgHrefFluentTile(uri!,
                            confirmation: _confirmIsOpen,
                            onLoading: (context) =>
                                const Center(child: ProgressRing()))
                      ]
                          .map((e) =>
                              Align(alignment: Alignment.center, child: e))
                          .toList(),
                    ))
        ])));
  }
}

final class _GoButtonState implements ButtonState<Color?> {
  final Color baseColour = Colors.successPrimaryColor;

  const _GoButtonState();

  @override
  Color? resolve(Set<ButtonStates> states) {
    if (states.contains(ButtonStates.pressing)) {
      return baseColour;
    } else if ([ButtonStates.focused, ButtonStates.hovering]
        .any(states.contains)) {
      return baseColour.withGreen(64).withRed(32);
    } else if (states.contains(ButtonStates.none)) {
      return Colors.green.light;
    }

    return null;
  }
}
