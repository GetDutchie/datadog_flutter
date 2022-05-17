## This Package is DEPRECATED

This package has been deprecated in favor of [the official Datadog Flutter SDK](https://pub.dev/packages/datadog_flutter_plugin). Please see [the announcement](https://github.com/GetDutchie/datadog_flutter/issues/108) or skip ahead to [the new, official repo](https://github.com/DataDog/dd-sdk-flutter).

## 2.0.0

* Make `context` available in Android
* **BREAKING CHANGE** Remove support for Flutter 1.12 to add support Flutter 3 on Android. This only affects apps using Flutter <1.12.
* **BREAKING CHANGE** Android logs that were mapped under `Level.fine` and below are now mapped as "debug" instead of "verbose." Similarly, `Level.INFO` is now mapped to "info" instead of "debug." Log levels for Android and iOS that were `Level.SHOUT` are now mapped to "debug." While this change does not affect Flutter implementations it will affect how your logs are ingested by Datadog. (#96)
* **BREAKING CHANGE** A new pod for iOS was introduced for Crash Reporting. In order to use this pod, make sure `DatadogSDKCrashReporting` appears in your `podfile.lock`. If it does not, remove `datadog_flutter` from your `pubspec.yaml` and run `flutter pub get`. Then readd it and run `flutter pub get; pushd ios; bundle exec pod install --repo-update; popd`.

## 2.0.0-beta.4

* Make `context` available in Android

## 2.0.0-beta.2

* **BREAKING CHANGE** Remove support for Flutter 1.12 to add support Flutter 3 on Android. This only affects apps using Flutter <1.12.

## 2.0.0-beta.1

* **BREAKING CHANGE** Android logs that were mapped under `Level.fine` and below are now mapped as "debug" instead of "verbose." Similarly, `Level.INFO` is now mapped to "info" instead of "debug." Log levels for Android and iOS that were `Level.SHOUT` are now mapped to "debug." While this change does not affect Flutter implementations it will affect how your logs are ingested by Datadog. (#96)
* **BREAKING CHANGE** A new pod for iOS was introduced for Crash Reporting. In order to use this pod, make sure `DatadogSDKCrashReporting` appears in your `podfile.lock`. If it does not, remove `datadog_flutter` from your `pubspec.yaml` and run `flutter pub get`. Then readd it and run `flutter pub get; pushd ios; bundle exec pod install --repo-update; popd`.

## 1.7.4

* Support Flutter 3 on Android

## 1.7.3+2

* Revert native crash reporting support for iOS (restores 1.7.2) (#99)

## 1.7.3+1

* Fixes crash for missing pod `DatadogSDKCrashReporting` (#99)

## 1.7.3

* Adds native crash reporting support on iOS (#92)

## 1.7.2

* Permit non-`http.Request` requests to be sent through `DatadogTracingHttpClient` (#93)

## 1.7.1

* Fix empty `extraInfo` exception on iOS (#89)

## 1.7.0

* Fix incorrectly named key for `extraInfo` on `DatadogFlutter#setUserInfo` in iOS (#84)
* Bump minimum Datadog SDK to 1.11.1. Related to [DataDog/dd-sdk-android#709](https://github.com/DataDog/dd-sdk-android/issues/709) (#85)

## 1.6.0

* Acknowledge `extraInfo` arguments for Flutter Web users (#76)
* Resolve `Platform` determination for web (#77)

## 1.5.2

* Nested arrays and nested maps in attributes are supported on iOS (#62)
* **BREAKING CHANGE** all attribute maps have been updated from `Map<String, dynamic>` to `Map<String, Object>`. These `Map`s no longer support nullable values.

## 1.5.1

* Rollback minimum Datadog Flutter Android to 1.8.1 (#72)
* Rollback minimum Datadog Flutter iOS to 1.5.0 (#72)

## 1.5.0

* Update Kotlin to [reflect requried minimum version](https://docs.flutter.dev/release/breaking-changes/kotlin-version) (#68)
* Update Datadog Flutter Android to 1.11.1
* Update Datadog Flutter iOS to 1.9.0

## 1.4.1

* Uppercases `kind` for `startResourceLoading` and `stopResourceLoading` on Android (#66)

## 1.4.0

* **BREAKING CHANGE**: `DatadogRum.startResourceLoading` and `DatadogRum.stopResourceLoading` are now accessed as `DatadogRum.instnace.startResourceLoading` and `DatadogRum.instance.stopResourceLoading`
* Fix attributes in RUM and Logger for iOS. `NSNumber` (provided by [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels#codec)) is not `Encodable`
* Change `log` in native platform method handler to `loggerLog`

## 1.3.0

* Add support for Flutter web.

## 1.2.1

* Add environment configuration on Android (#42)

## 1.2.0

* Fixes a null-safe exception at the Android level when using DatadogTracing.
* Remove `addTiming` from the `DatadogObserver` and update docs to use `addTiming` _after_ the screen is interactive.
* Track page route independent of previous/next being a `PageRoute` (#40)

## 1.1.1

* **BREAKING CHANGE** `DatadogTracingHttpClient` accepts `innerClient` as a named argument instead of a positional one. To migrate, add `innerClient:` ahead of the first argument.

## 1.1.0

* **BREAKING CHANGE** `DatadogFlutter` should no longer be treated as an instantiable class; instead, access all properties statically (while admittedly a class of only class methods is poor practice, this replicates the Datadog SDKs and provides a predictable interface). Migrate the arguments from the original constructor to `DatadogFlutter.initialize`, ideally invoked before app start. For example, `DatadogFlutter(clientToken: 'abcd')` becomes `DatadogFlutter.intialize(clientToken: 'abcd')`.
* **BREAKING CHANGE** The logging functionality has been moved from `DatadogFlutter` to `DatadogLogger`. Datadog has been adding a lot of new instrumentation to their SDKs and the features should be similarly distributed between different classes.
* **BREAKING CHANGE** Due to a change in Datadog's SDK to comply with GDPR regulations, `TrackingConsent` must be `granted` to submit events or logs to Datadog. Providing `pending` will collect events but not report until the property is `granted`. Supply this value in `initialize` and, if necessary later, in `updateTrackingConsent`.
* Opt-in support has been added for [Real User Monitoring](https://docs.datadoghq.com/real_user_monitoring/), adding error, event, and screen tracking.
* Opt-in support has been added for [Tracing](https://docs.datadoghq.com/real_user_monitoring/connect_rum_and_traces/?tab=iosrum), following an HTTP request from the client to the server. Goes well with RUM.
* Multiple `DatadogLogger`s can be instantiated and persisted.
* Support EU endpoints (#4)

## 1.0.1+1

* Fix Swift error with EU endpoints

## 1.0.1

* Support configuration for EU endpoints (#4)
* Use MavenCentral instead of JCenter for dependency (#8)

## 1.0.0

* Sound null safety

## 1.0.0-nullsafety.0

* Null safety prerelease

## 0.1.0

* **BREAKING CHANGE** `DatadogFlutter` should no longer be treated as an instantiable class; instead, access all properties statically (while admittedly a class of only class methods is poor practice, this replicates the Datadog SDKs and provides a predictable interface). Migrate the arguments from the original constructor to `DatadogFlutter.initialize`, ideally invoked before app start. For example, `DatadogFlutter(clientToken: 'abcd')` becomes `DatadogFlutter.intialize(clientToken: 'abcd')`.
* **BREAKING CHANGE** The logging functionality has been moved from `DatadogFlutter` to `DatadogLogger`. Datadog has been adding a lot of new instrumentation to their SDKs and the features should be similarly distributed between different classes.
* **BREAKING CHANGE** Due to a change in Datadog's SDK to comply with GDPR regulations, `TrackingConsent` must be `granted` to submit events or logs to Datadog. Providing `pending` will collect events but not report until the property is `granted`. Supply this value in `initialize` and, if necessary later, in `updateTrackingConsent`.
* Opt-in support has been added for [Real User Monitoring](https://docs.datadoghq.com/real_user_monitoring/), adding error, event, and screen tracking.
* Opt-in support has been added for [Tracing](https://docs.datadoghq.com/real_user_monitoring/connect_rum_and_traces/?tab=iosrum), following an HTTP request from the client to the server. Goes well with RUM.
* Multiple `DatadogLogger`s can be instantiated and persisted.
* Support EU endpoints (#4)

## 0.0.4

* Use MavenCentral instead of JCenter for dependency (#7)

## 0.0.3

* Fix null pointer on Android (#3)

## 0.0.2

* Switch to Swift implementation

## 0.0.1

* Initial
