[![Pub](https://img.shields.io/pub/v/datadog_flutter.svg)](https://pub.dev/packages/datadog_flutter)

# Datadog Flutter

Community implementation of native bindings for Datadog's SDK. **This is not an official package**.

## Setup

1. Generate a client token from Datadog through [the Settings > API  panel](https://app.datadoghq.com/account/settings#api) (under Client Tokens).
1. Initialize:
    ```dart
      await DatadogFlutter.initialize(
        clientToken: myDatadogClientToken,
        serviceName: 'my-app-name',
        environment: 'production',
      )
    ```


:warning: Your Podfile must have `use_frameworks!` (Flutter includes this by default) and your minimum iOS target must be >= 11. This is a requirement [from the Datadog SDK](https://github.com/DataDog/dd-sdk-ios/blob/master/DatadogSDKObjc.podspec#L17).

## Logging

In its default implementation, log data will only be transmitted to Datadog through [`Logger`](https://pub.dev/packages/logging) records. `print` statements are not guaranteed to be captured.

```dart
ddLogger = DatadogLogger(serviceName: 'my-app-name');

ddLogger.addTag('restaurant_type', 'pizza');
ddLogger.removeTag('restaurant_type');

// add attribute to every log
ddLogger.addAttribute('toppings', 'extra_cheese');

// add atttributes to some logs
ddLogger.log('time to cook pizza', Level.FINE, attributes: {
  'durationInMilliseconds': timer.elapsedMilliseconds,
});
```

## Real User Monitoring

RUM adds support for error, event, and screen tracking. The integration is partial (traces are not supported) and requires additional configuration.

1. [Supply an application ID](https://docs.datadoghq.com/real_user_monitoring/#getting-started) to `initialize`:
    ```dart
      await DatadogFlutter.initialize(
        clientToken: myDatadogClientToken,
        serviceName: 'my-app-name',
        environment: 'production',
        iosRumApplicationId: myiOSRumApplicationId,
        androidRumApplicationId: myAndroidRumApplicationId,
      )
    ```
1. Acknowledge `TrackingConsent` at initialization or later within your application. **Events will not be logged until `trackingConsent` is `.granted`**. This value can be updated via `DatadogFlutter.updateTrackingConsent`.
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
1. Automatically report errors:
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
1. Manually track additional events:
    ```dart
      GestureDetector(
        onTap: () {
          DatadogRum.instance.addUserAction('EventTapped');
        }
      )
    ```
1. Manually track additional errors:
    ```dart
      try {
        throw StateError();
      } catch (e, st) {
        DatadogRum.instance.addError(e, st);
      }
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
