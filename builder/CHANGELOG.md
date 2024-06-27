## 4.1.3

* Update constraint of dependencies.

## 4.1.2

* Update SDK constraint

## ~~4.1.1~~ (Retracted)

* Change version constraint of `model` package.

## 4.1.0

* Test implementation completed and features `testing` library.
    * Please read [wiki page](https://github.com/rk0cc/oghref/wiki) for writing widget test in Flutter.
* Add assertion to prevent uses real client in testing environment.
    * REMARK: The detection relys on finding `FLUTTER_TEST` in environment variable which appeared when using `flutter_test`, and it still able to be bypassed if used oridinary `test` package.
* Updated `oghref_model` version constraint to `^3.3.1`

## 4.0.0

* Update `oghref_model` version constraint to `^3.2.1`.
* ~~Widget tests presents now.~~ **(Update at 2024-01-06: Due to complexity setup of testing environment, no testes will be run from library forever)**
* Performing widget test becomes possible (technically).

## 3.1.0

* Add `BoxConstraint` to measure width if parent widget has finite width already.
* Update minimum version bound of `oghref_model` to `2.1.2`

## 3.0.2

* Hide `protected` metadata which shipped from Flutter.

## 3.0.1

* Fix loading widget not appeared when previous result has been loaded and attempted to load new data.

## 3.0.0

* `OgHrefBuilder` marked as astract base class along with `OgHrefBuilderState` for customize builder behaviour.
    * The origin constructor has been moved to `OgHrefBuilder.updatable`.
* Reimplement updatable and run once builders under `OgHrefBuilderState`.
    * `AsyncMemorizer` is no longer be used that dependency of `async` library has been removed.
* Update `oghref_model` to `^2.1.0`.

## 2.0.5

* Simply building href procedure

## 2.0.4

* Update `oghref_model` to `^2.0.5` to enforce UTF-8 decoding.

## 2.0.3

* Update `oghref_model` to `^2.0.4` to enforce UTF-8 decoding.

## 2.0.2

* Update `oghref_model` to `^2.0.3` to enforce UTF-8 decoding.

## 2.0.1

* Update `oghref_model` to `^2.0.2` to tackle Twitter Card does not ship issue

## 2.0.0

* Support for handling multiple `MetaInfo`
* Added confirmation procedure before opening url.
* Bundled with responsive calculator.

## 1.2.1

* Fix keep fetching issue when resizing widget.

## 1.2.0

* Fix content unchanged when given `Uri` updated.
* Offer `OgHrefBuilder.runOnce` that prevent content changes when widget rebuild.

## 1.1.0

* Upgrade model to `1.2.0`

## 1.0.1

* Pump `oghref_model` to at least `1.1.1`
* Provide `key` parameter back to `OgHrefBuilder`

## 1.0.0

* Provide builder widget and function type defintions of rich information link.
