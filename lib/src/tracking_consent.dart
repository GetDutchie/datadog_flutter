/// To be compliant with the GDPR regulation, the SDK requires the
/// trackingConsent value at initialization
enum TrackingConsent {
  /// The SDK starts collecting the data and sends it to Datadog.
  granted,

  /// The SDK does not collect any data: logs, traces, and RUM
  /// events are not sent to Datadog.
  notGranted,

  /// The SDK starts collecting and batching the data but does
  /// not send it to Datadog. The SDK waits for the new tracking consent
  /// value to decide what to do with the batched data.
  pending,
}
