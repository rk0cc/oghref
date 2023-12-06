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
