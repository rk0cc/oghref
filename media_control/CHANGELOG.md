## 4.0.1

* Change SDK constraint

## ~~4.0.0~~ (Retracted)

* Migration from `dart:html` to `package:web`
* Integrated selected parameters from `PlayerConfiguration` and `VideoControllerConfiguration` into `MediaPlaybackPreference`
* Disable follow redirection when evaluating media type
* New user agent string for determine media content type: `oghref_content_type_guard`

## 3.0.7

* Declare unsupported under widget testing environment.
* New client model adapted to avoid repeated construction.

## 3.0.6

* Fix retain previous widget problem when loading new context.
* Uses browser's user agent for making request in web platform.

## 3.0.5

* Drop `oghref_model` and `oghref_builder` due to unused implementation.

## 3.0.4

* Fix content broken during parsing metadata

## 3.0.3

* Resolve tofu decode issue in `oghref_model`

## 3.0.2

* Enforce UTF-8 decoding content for `oghref_model`
* Update `flutter_lints` to `^3.0.1`

## 3.0.1

* Fix `BuildContext` not offered on `onLoading` invoked.

## 3.0.0

**Major changes: This version API is backward incompatable**

* Redesigned API of `MediaPlayback`
  * Provided `onLoadFailed` as fallback option if not all `resources` are playable media type.
  * Custom theme of control widget no longer allows to implement.
* `AspectRatioValue` no longer existed

## 2.0.2

* Update builder dependency.

## 2.0.1

* Dependencies update

## 2.0.0

* Video control must be specified.
* Provide missing documents.
* Update latest media_kit components

## 1.0.0+1

* Add missing documents

## 1.0.0

* First release
