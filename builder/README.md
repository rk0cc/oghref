# Abstract Flutter widget builder of rich information link.

<p align="center">
    <a href="https://pub.dev/packages/oghref_builder"><img alt="OGHref model version in pub.dev" src="https://img.shields.io/pub/v/oghref_builder?style=flat-square&logo=dart"></a>
</p>

An abstract library for building rich information link in Flutter widgets.

## Implementation

It only just define dependencies in `pubspec.yaml` and both builder and models are bundled already.

```yaml
dependencies:
  oghref_builder: # Version cosntraint
```

Then, just import it:

```dart
import 'package:oghref_builder/oghref_builder.dart';
```

However, if custom parser is required, `oghref_model` must be declared at the same time:

```yaml
dependencies:
  oghref_builder: # Version cosntraint
  oghref_model: # Version cosntraint
```

And import `buffer_parser` library along with `oghref_builder`:

```dart
import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_model/buffer_parser.dart';
```

## License

MIT
