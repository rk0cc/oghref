# Object definition of OGHref

<p align="center">
    <a href="https://pub.dev/packages/oghref_model"><img alt="OGHref model version in pub.dev" src="https://img.shields.io/pub/v/oghref_model?style=flat-square&logo=dart"></a>
</p>

This library provides structure of rich information link and parser from HTML
documentations.

## Usages

#### Import dependencies

1. Add `oghref_model` into `pubspec.yaml`
    ```yaml
    dependencies:
        oghref_model: # Latest stable version
    ```
1.  Import package
    ```dart
    import 'package:oghref_model/model.dart';
    ```
1. If custom parser implementations required, please also import `buffer_parser.dart`
    ```dart
    import 'package:oghref_model/buffer_parser.dart';
    ```

#### Implementations

See [example](./example/main.dart);

## License

AGPL 3.0 or later (For import dedicatedly)

MIT (For import with widgets)
