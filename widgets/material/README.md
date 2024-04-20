# Material themed rich information link widgets in Flutter

<p align="center">
    <a href="https://pub.dev/packages/oghref_material"><img alt="oghref_material version" src="https://img.shields.io/pub/v/oghref_material?style=flat-square"></a>
</p>

Providing rich information links in Material themed widgets.

## Setup

### Basic

1. Add dependencies into `pubspec.yaml`:
    ```yaml
    dependencies:
        oghref_material: ^1.0.0 # Latest version
        # If required to design your own custom parsers, please also add these dependencies below:
        oghref_model: ^2.0.1
    ```

1. Configurate [platforms manifest files](https://github.com/rk0cc/oghref/wiki/Import-existed-theme#platform-configurations)

1. Perform initalizations before `runApp`
    ```dart
    void main() {
        WidgetsFlutterBinding.ensureinitialized();
        OgHrefMaterialBinding.ensureinitialized();

        runApp(const App());
    }
    ```

1. Either implement `OgHrefMaterialCard` or `OgHrefMaterialTile` depending your preference by referring to [example](./example/lib/app.dart)

### Advance

* If custom property parser is used, please attach the parser into `MetaFetch` between initalizations and `runApp`:

    ```dart
    MetaFetch().register(const CustomParser());
    ```

## Usages

Please refer to [wiki page](https://github.com/rk0cc/oghref/wiki/Widgets).
