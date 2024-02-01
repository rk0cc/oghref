## 3.4.0

* Add `MockOgHrefClient.advance` for building responding content with different content type applied.
* Fix client does not closes after stream closed when calling `determineContentTypes()` in `IteratedUrlInfoContentTypeResolver`.
* Uses final variable assignment rather than a getter for `MockOgHrefClient.redirect`.
* `IteratedUrlInfoContentTypeResolver` uses current instance of `MetaFetch`'s client to proceed data.

## 3.3.4

* Restrict `MockOgHrefClient` accepted requesting `GET` and `HEAD` method.
    * Requesting other methods will get HTTP code 400 otherwise.
* Using cryptographically random generator if available instead of default one.
* Some client setting made from `MetaFetch` will be applied into `MockOgHrefClient`.
    * However, some setting may not affect response content.

## 3.3.3

* Add validation to `MetaFetch` that property name prefix must not be an empty string and throws `ArgumentError` otherwise.
* Add missing documentation back.

## 3.3.2

* More readability for client source codes.

## 3.3.1

* Remove `testing` library annotations.

## 3.3.0

* Create `testing` library for deploys `MockOgHrefClient` and `MetaFetchTester` in testing environment. 

## 3.2.1

* Fix `Client.close()` does absolutely nothing issue.

## 3.2.0

* Uses `MockClient` for making request for test.
    * Since testes no longer using real networking for making request from resources, `test_resources` directory is renamed to `sample` that all HTML files becomes as references of path.
    * The IP address uses for `MockClient` is `127.0.0.2`

## 3.1.0

* Redesign `MetaFetch` that enabling further extensions internally.
* Update documents.

## 3.0.1

* Fix `allowRedirect` still enabled eventhough disabled already.
* `allowRedirect` enabled by default again.

## 3.0.0

* New strucutre of instance definition
    * The instance will be stored automatically by invoking instance getter directly.
* `buildMetaInfo` and `buildAllMetaInfo` becomes private scopes.

## 2.1.3

* Add `doNotStore` annotation to `MetaPropertyParser`.
* Disguised user agent string can be get from `MetaFetch.userAgentString`.
* Provides topics

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
