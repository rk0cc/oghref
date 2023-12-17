# Rich information link preview in Dart with models and Flutter widgets

OgHref offers structuring website rich information link in Dart object model and render to Flutter widgets. This repository provides all packages which (planned to) publish to [pub.dev](https://pub.dev). For those repositories serves as programmes, please visit [Applications](#applications) section.

For more technical information of OgHref, please visit [wiki page](https://github.com/rk0cc/oghref/wiki).

## Packages included in this repository

* Model
* Builder
* Media control (unlisted in pub.dev)
* Widgets
    * Cupertino
    * Fluent
    * Material

## Features

* Read rich information link by inspecting `<meta>` elements of HTML `<head>` section
* Built-in support for extracting Open Graph and Twitter Card context.
* Allows further expansion on extracting context using other protocols with `<meta>` tags.

## Limitations

* Only data comes from `<meta>` tag can be recognized from built-in parser, and the property name must comes with prefix.
    * It is possible to parse non-`<meta>` data into `MetaInfo` with dedicated parser.
* All supported protocols parser only able to retrive fundamental data and disregard any additional properties stated.

## Applications

* [oghref_cmd](https://github.com/rk0cc/oghref_cmd): Command line tools for displaying metadata in website.

### Third-party repository

(No repositories available yet)

## Licenses

* AGPL-3.0 or later if republish packages based on `oghref_model`.
* MIT if publish as binary executable file or involves with Flutter.
