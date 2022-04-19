[![Pub](https://img.shields.io/pub/v/datadog_flutter.svg)](https://pub.dev/packages/datadog_flutter)

# Datadog Flutter

Community implementation of native bindings for Datadog's SDK. **This is not an official package**.

## Setup

1. Generate a [client token](https://docs.datadoghq.com/account_management/api-app-keys/#client-tokens) from Datadog through [the Settings > API  panel](https://app.datadoghq.com/account/settings#api) (under Client Tokens). If you're using RUM, do not toggle between the RUM platform client tokens.
1. Initialize:
    ```dart
    await DatadogFlutter.initialize(
      clientToken: myDatadogClientToken,
      serviceName: 'my-app-name',
      environment: 'production',
    )
    ```
1. Associate RUM and log events (optional):
    ```dart
    await DatadogFlutter.setUserInfo(id: <YOUR_USER_ID>);
    ```
1. [Acknowledge `TrackingConsent`](https://docs.datadoghq.com/logs/log_collection/ios/?tab=cocoapods#setup) at initialization or later within your application. **Events will not be logged until `trackingConsent` is `.granted`**. This value can be updated via `DatadogFlutter.updateTrackingConsent`.

:warning: Your Podfile must have `use_frameworks!` (Flutter includes this by default) and your minimum iOS target must be >= 11. This is a requirement [from the Datadog SDK](https://github.com/DataDog/dd-sdk-ios/blob/master/DatadogSDKObjc.podspec#L17).

### Flutter Web Caveats

The Datadog scripts need to be inserted in your `index.html` document. Please add both the [logging script](https://docs.datadoghq.com/logs/log_collection/javascript/#cdn-async) and the [RUM script](https://docs.datadoghq.com/real_user_monitoring/browser/#cdn-async) to [their own](example/web/index.html) `<script>` tags. **DO NOT** add the `.init` on `.onReady` code.

## Logging

In its default implementation, log data will only be transmitted to Datadog through [`Logger`](https://pub.dev/packages/logging) records. `print` statements are not guaranteed to be captured.

```dart
ddLogger = DatadogLogger(loggerName: 'orders');
// optionally set a value for HOST
// ddLogger.addAttribute('hostname', <DEVICE IDENTIFIER>);

ddLogger.addTag('restaurant_type', 'pizza');
ddLogger.removeTag('restaurant_type');

// add attribute to every log
ddLogger.addAttribute('toppings', 'extra_cheese');

// add atttributes to some logs
ddLogger.log('time to cook pizza', Level.FINE, attributes: {
  'durationInMilliseconds': timer.elapsedMilliseconds,
});
```

### Flutter Web Caveats

* `addTag` and `removeTag` are not invoked and resolve silently when using Flutter web. This is a missing feature in Datadog's JS SDK.

## Real User Monitoring

RUM adds support for error, event, and screen tracking. The integration requires additional configuration for each service.

1. [Supply an application ID](https://docs.datadoghq.com/real_user_monitoring/#getting-started) to `initialize`:
    ```dart
    await DatadogFlutter.initialize(
      clientToken: myDatadogClientToken,
      serviceName: 'my-app-name',
      environment: 'production',
      iosRumApplicationId: myiOSRumApplicationId,
      androidRumApplicationId: myAndroidRumApplicationId,
      webRumApplicationId: myWebRumApplicationId,
    )
    ```
1. Automatically track screens:
    ```dart
    MaterialApp(
      // ...your material config...
      home: HomeScreen(),
      navigatorObservers: [
        DatadogObserver(),
      ],
    );
    ```
1. Automatically report errors (on iOS deployments be sure to [upload your dSYMs](https://github.com/DataDog/datadog-ci/tree/master/src/commands/dsyms)):
    ```dart
    void main() async {
      // Capture Flutter errors automatically:
      FlutterError.onError = DatadogRum.instance.addFlutterError;

      // Catch errors without crashing the app:
      runZonedGuarded(() {
        runApp(MyApp());
      }, (error, stackTrace) {
        DatadogRum.instance.addError(error, stackTrace);
      });
    }
    ```
1. Manually track additional events (please note that [Android will only report `RUMAction.custom` events](https://github.com/GetDutchie/datadog_flutter/issues/53#issuecomment-923769393)):
    ```dart
    GestureDetector(onTap: () {
      DatadogRum.instance.addUserAction('EventTapped');
    })
    ```
1. Manually track additional errors:
    ```dart
    try {
      throw StateError();
    } catch (e, st) {
      DatadogRum.instance.addError(e, st);
    }
    ```
1. Manually track [network requests or resources](https://docs.datadoghq.com/real_user_monitoring/android/data_collected/?tab=session):
    ```dart
    await DatadogRum.startResourceLoading(
      aUniqueIdentifier,
      url: 'https://example.com',
      method: RUMResources.get,
    );
    await DatadogRum.stopResourceLoading(
      aUniqueIdentifier,
      statusCode: 500,
      errorMessage: 'Internal Server Error' ,
    )
    ```

### Flutter Web Caveats

* `addUserAction` ignores the `action` when using Flutter web.
* `updateTrackingConsent` is not invoked and fails silently when using Flutter web. This is a missing feature in Datadog's JS SDK.
* `stopView` is not invoked and fails silently when using Flutter web. This is a missing feature in Datadog's JS SDK.
* `startUserAction` and `stopStopUserAction` are not invoked and fail silently when using Flutter web. This is a missing feature in Datadog's JS SDK.
* `startResourceLoading` and `stopResourceLoading` are not invoked and resolve silently when using Flutter web. This is a missing feature in Datadog's JS SDK.
* `setUserInfo` does not support custom attributes when using Flutter web. This is due to Dart's method of strongly typing JS. Only `name`, `id`, and `email` are supported.

## Tracing

Associate your HTTP requests with your backend service. Be sure to setup (usually immediately after `DatadogFlutter.initialize`):

```dart
await DatadogTracing.initialize();
```

For one-off requests, instantiate a fresh client:

```dart
final httpClient = DatadogTracingHttpClient();
// make requests
final response = await httpClient.get(Uri(string: 'http://example.com');
```

For frameworks that use an internal client like Brick, compose the client:

```dart
RestProvider(
  client: DatadogTracingHttpClient();
)
// or compose if another client is already being used:
RestProvider(
  client: DatadogTracingHttpClient(GZipHttpClient());
)
```

## FAQ

### How do I disable logging when I'm developing locally?

By default, the `DatadogFlutter` default constructor will send all logs from `Logger` to Datadog. To ignore, set `bindOnRecord`:

```dart
DatadogLogger(bindOnRecord: false)
```

And log conditionally later:

```dart
Logger.root.onRecord.listen((record) async {
  if (shouldSendToDatadog) {
    ddLogger.onRecordCallback(record)
  } else {
    print(record);
  }
});
```
