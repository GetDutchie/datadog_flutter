#import "DatadogFlutterPlugin.h"
#if __has_include(<datadog_flutter/datadog_flutter-Swift.h>)
#import <datadog_flutter/datadog_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "datadog_flutter-Swift.h"
#endif

@implementation DatadogFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDatadogFlutterPlugin registerWithRegistrar:registrar];
}
@end
