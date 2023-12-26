## 2.1.3

* Add `doNotStore` annotation to `MetaPropertyParser`.
* Disguised user agent string can be get from `MetaFetch.userAgentString`.

## 2.1.2

* Fix decode error if original String displayed normal already.

## 2.1.1

* Revert redirection disable as default

## 2.1.0

* `MetaFetch.allowRedirect` is enabled by default
* Added timeout options with `MetaFetch.timeout` and `MetaFetch.changeTimeout(int seconds)` for get and change preference.
* Change `MetaFetch.changeUserAgent` from nullable parameter to optional parameter.
* Provide `MetaFetch.disguiseUserAgent` for making request using web browser provided user agent.
* `MetaFetch.fetchFromHttp(Uri url)` and `MetaFetch.fetchAllFromHttp(Uri url)` will thrown errors if applied.
    * All exceptions are export publicly in case of catching thrown objects by specific types.

## 2.0.5

* Move UTF-8 decode process during parsing property

## 2.0.4

* Response body will be decoded by UTF-8.

## 2.0.3

* Enforce every decoded content using UTF-8

## 2.0.2

* Fix Twitter Card absent in library issue
* Lint

## 2.0.1

* Downgrade `meta` version constraint that ensure it can be implemented with Flutter.

## 2.0.0

* Added `MetaFetch.fetchAllFromHttp` for fetching all existed protocol in HTML document.
* Twitter Card property parser supported
* Dependencies updates

## 1.2.0

* Remove all assigners implementing with one of the model.

## 1.1.2

* Allow `MetaFetch` follow redirection (disabled by default).
* Uses all lower case for getting response header.

## 1.1.1

* Annotate `MetaFetch.buildMetaInfo` for testing only

## 1.1.0

* Allow specify primary prefix which will be resolved rather than following `<meta>` sequences
* Fix XHTML cannot be retrived issue

## 1.0.0

* Fix last assigned audio, video and image does not added into `MetaInfo`
* Test implemented

## 1.0.0-beta.2

* Use record pair contains property and content
* Fix incorrect initalize condition of audio section in Open Graph Protocol
* Still not fully tested

## 1.0.0-beta.1

* Release module, parser and fetch libraries
* Untested yet
