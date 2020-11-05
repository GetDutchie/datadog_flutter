[![Pub](https://img.shields.io/pub/v/datadog_flutter.svg)](https://pub.dev/packages/datadog_flutter)

# Datadog Flutter

Community implementation of native bindings for Datadog's SDK. **This is not an official package**.

## Setup

1. Generate a client token from Datadog through [the Settings > API  panel](https://app.datadoghq.com/account/settings#api) (under Client Tokens).
1. Initialize:
    ```dart
      ddLogger = DatadogFlutter(
        clientToken: myDatadogClientToken,
        serviceName: 'my-app-name',
        environment: 'production',
      )
    ```

In its default implementation, log data will only be transmitted to Datadog through [`Logger`](https://pub.dev/packages/logging) records. `print` statements are not guaranteed to be captured.

It is strongly recommended to include access `DatadogFlutter` through a singleton instead of multiple instantiations.

:warning: Your Podfile must have `use_frameworks!` (Flutter includes this by default) and your minimum iOS target must be >= 11. This is a requirement [from the Datadog SDK](https://github.com/DataDog/dd-sdk-ios/blob/master/DatadogSDKObjc.podspec#L17).

## Usage

```dart
ddLogger.addTag('restaurant_type', 'pizza');
ddLogger.removeTag('restaurant_type');

// add attribute to every log
ddLogger.addAttribute('toppings', 'extra_cheese');

// add atttributes to some logs
ddLogger.log('time to cook pizza', Level.FINE, attributes: {
  'durationInMilliseconds': timer.elapsedMilliseconds,
});
```

## FAQ

### How do I disable logging when I'm developing locally?

By default, the `DatadogFlutter` default constructor will send all logs from `Logger` to Datadog. To ignore, set `bindOnRecord`:

```dart
DatadogFlutter(
  clientToken: myDatadogClientToken,
  bindOnRecord: false,
)
```

And log conditionally later:

```dart
Logger.root.onRecord.listen((record) async {
  if (shouldSendToDatadog) {
    ddLogger.onRecordCallback(record)
  }
});
```
