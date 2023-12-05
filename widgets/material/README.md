# Material themed rich information link widgets in Flutter

<p align="center">
    <a href="https://pub.dev/packages/oghref_material"><img alt="oghref_material version" src="https://img.shields.io/pub/v/oghref_material?style=flat-square"></a>
</p>

Providing rich information links in Material themed widgets.

## Setup

1. Add dependencies into `pubspec.yaml`:
    ```yaml
    dependencies:
        oghref_material: ^1.0.0 # Latest version
        # If custom models are used, please also add these dependencies below:
        oghref_model: ^2.0.1
    ```

1. Perform initalizations before `runApp`
    ```dart
    void main() {
        WidgetsFlutterBinding.ensureinitialized();
        OgHrefMaterialBinding.ensureinitialized();

        runApp(const App());
    }
    ```

## License

MIT