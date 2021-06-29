## Unreleased

## 0.1.0

* **BREAKING CHANGE** `DatadogTracingHttpClient` accepts `innerClient` as a named argument instead of a positional one. To migrate, add `innerClient:` ahead of the first argument.

## 0.1.0+1

* **BREAKING CHANGE** `DatadogFlutter` should no longer be treated as an instantiable class; instead, access all properties statically (while admittedly a class of only class methods is poor practice, this replicates the Datadog SDKs and provides a predictable interface). Migrate the arguments from the original constructor to `DatadogFlutter.initialize`, ideally invoked before app start. For example, `DatadogFlutter(clientToken: 'abcd')` becomes `DatadogFlutter.intialize(clientToken: 'abcd')`.
* **BREAKING CHANGE** The logging functionality has been moved from `DatadogFlutter` to `DatadogLogger`. Datadog has been adding a lot of new instrumentation to their SDKs and the features should be similarly distributed between different classes.
* **BREAKING CHANGE** Due to a change in Datadog's SDK to comply with GDPR regulations, `TrackingConsent` must be `granted` to submit events or logs to Datadog. Providing `pending` will collect events but not report until the property is `granted`. Supply this value in `initialize` and, if necessary later, in `updateTrackingConsent`.
* Opt-in support has been added for [Real User Monitoring](https://docs.datadoghq.com/real_user_monitoring/), adding error, event, and screen tracking.
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
