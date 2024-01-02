## 2.0.0

* Migration of theme setting to dedicated classes.
    * All original style setting existed as widget's properties will marked as deprecated and will be removed in next major release (`3.0.0`).
    * Currently they perform as fallback preferences if style property absents.
* Control buttons from `ImageCarousel` will be visiable when either hovering or tapping widget area.
    * If shown due to tapping widget, it will hide automatically in specific seconds.
* Add preferences for `ImageCarousel` and can be speficied in `OgHrefMaterialCard`.
* Add current index of images in `ImageCarousel`.

## 1.2.2

* Fix image semantics feature does not offered.

## 1.2.1

* Implement width measurment depending on parent widget if bounded.

## 1.2.0

* Update dependencies constraints:
    * `oghref_model`: `^2.1.1`
    * `oghref_builder`: `^3.0.1`
    * `oghref_media_control`: `^3.0.5`
* Add icon for `OgHrefMaterialTile` if the website of URL failed to retrive content.
* Uses `WidthSizeMeasurment` mixin from `oghref_builder` to measure width.

## 1.1.4

* Fix content broken issue

## 1.1.3

* Resolve incorrect decoding content issues.

## 1.1.2

* Loading widget reimplementations.
* Downgrade `meta` constraint

## 1.1.1

* Drop cache image support

## 1.1.0

* Add style configuration for `OgHrefMaterialCard`
* Known issues:
    * Some website which no metadata offered may not be able to fetch fallback content.

## 1.0.1

* Remove `media_kit_video` in `pubspec.yaml` due to no API used directly

## 1.0.0

* Initial release of `oghref_material`
* Oghref packages version constraint:
    * `oghref_builder`: `^2.0.0`
    * `oghref_media_control`: `^3.0.1`
    * `oghref_model`: `^2.0.1`
