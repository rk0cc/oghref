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

`OgHrefMaterialCard` and `OgHrefMaterialTile` can be used depending detail completeness and capacity. There is a brief explainations for determine the suitable widget to be applied.

### `OgHrefMaterialCard`

![oghref_material_card](https://github.com/rk0cc/oghref/assets/70585816/28b4014b-e5ab-49f8-a6fe-f69043454514)


`OgHrefMaterialCard` has three two major components in a card: media and information sections where placed vertically. The media section can be either image carousel or a player if `multimedia` is activated and the given URL provides at least one metadata related with audio or video with **exact** location of the resources (in another words, no redirection allowed) and responded content type.

Image carousel has two buttons for page control, simply as move previous or next pages. And the page view will display all images resources available from metadata. The content of images will be shown in contain mode of `BoxFit` and will be cached once it loaded already.

Player is a widget for handling audio and video playback with [media_kit](https://pub.dev/packages/media_kit) library. As mentioned before, this feature only available when all audios and videos metadata have raw file URL that ensure no unsupported content type URL existed. For example, YouTube video link offers video metadata but it's location is referring to embedded player which is HTML for attaching source of  &lt;iframe&gt; element. Therefore, the widget refuses to activate multimedia playback support and keep showing image carousel.

For the information section, it contains title and descriptions if provided. Otherwise, when title omitted, URL address will be shown instead. This section also plays a role of linking given URL that it will open link when pressed.

### `OgHrefMaterialTile`

![oghref_material_tile](https://github.com/rk0cc/oghref/assets/70585816/98fa26b0-f28b-4dfb-83e0-1c66ee524326)

`OgHrefMaterialTile` is another widgets based on `ListTile` which integrated an image, title, description as well as open link features into a compact widget to reduce occupied spaces.

The image will be shown the first index of metadata only and no extra resources can be displayed unlike the card. Thus, all audios and videos resources are omitted that multimedia playback is no longer availabled in this widget in insufficient size.

## License

MIT
