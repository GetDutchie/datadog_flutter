#import "DatadogFlutterPlugin.h"
#import <DatadogObjc/DatadogObjc-Swift.h>

@interface DatadogFlutterPlugin ()

@property (nonatomic) DDLogger *logger;

@end

@implementation DatadogFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"plugins.greenbits.com/datadog_flutter"
                                                                binaryMessenger:[registrar messenger]];

    DatadogFlutterPlugin* instance = [[DatadogFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initWithClientToken" isEqualToString:call.method]) {
        [DDDatadog initializeWithAppContext:[[DDAppContext alloc] init]
                            configuration:[[DDConfiguration builderWithClientToken:call.arguments[@"clientToken"] environment:call.arguments[@"environment"]] build]];
        DDLoggerBuilder *builder = [DDLogger builder];
        [builder setWithServiceName:call.arguments[@"serviceName"]];
        if (![self _isNull:call.arguments[@"loggerName"]]) {
            [builder setWithLoggerName:call.arguments[@"loggerName"]];
        }
        self.logger = [builder build];
        [DDDatadog setVerbosityLevel:DDSDKVerbosityLevelDebug];
        result(@YES);
    } else if ([@"addTag" isEqualToString:call.method]) {
        [self.logger addTagWithKey:call.arguments[@"key"] value:call.arguments[@"value"]];
        result(@YES);
    } else if ([@"removeTag" isEqualToString:call.method]) {
        [self.logger removeTagWithKey:call.arguments[@"key"]];
        result(@YES);
    } else if ([@"addAttribute" isEqualToString:call.method]) {
        [self.logger addAttributeForKey:call.arguments[@"key"] value:call.arguments[@"value"]];
        result(@YES);
    } else if ([@"removeAttribute" isEqualToString:call.method]) {
        [self.logger removeAttributeForKey:call.arguments[@"key"]];
        result(@YES);
    } else if ([@"log" isEqualToString:call.method]) {
        NSString *logLevel = call.arguments[@"level"];
        NSString *logMessage = call.arguments[@"message"];
        NSDictionary *attributes = call.arguments[@"attributes"];

        if ([logLevel isEqualToString:@"debug"]) {
            if (attributes) {
                [self.logger debug:logMessage attributes:attributes];
            } else {
                [self.logger debug:logMessage];
            }
        } else if ([logLevel isEqualToString:@"info"]) {
            if (attributes) {
                [self.logger info:logMessage attributes:attributes];
            } else {
                [self.logger info:logMessage];
            }
        } else if ([logLevel isEqualToString:@"notice"]) {
            if (attributes) {
                [self.logger notice:logMessage attributes:attributes];
            } else {
                [self.logger notice:logMessage];
            }
        } else if ([logLevel isEqualToString:@"warn"]) {
            if (attributes) {
                [self.logger warn:logMessage attributes:attributes];
            } else {
                [self.logger warn:logMessage];
            }
        } else if ([logLevel isEqualToString:@"error"]) {
            if (attributes) {
                [self.logger error:logMessage attributes:attributes];
            } else {
                [self.logger error:logMessage];
            }
        } else if ([logLevel isEqualToString:@"critical"]) {
            if (attributes) {
                [self.logger critical:logMessage attributes:attributes];
            } else {
                [self.logger critical:logMessage];
            }
        }

        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// https://stackoverflow.com/a/38542407
- (BOOL)_isNull:(NSObject *)object {
    if (!object) return YES;
    else if (object == NULL) return YES;
    else if (object == [NSNull null]) return YES;
    else if ([object isKindOfClass:[NSString class]]) {
        return ([((NSString *)object)isEqualToString : @"null"]
                || [((NSString *)object)isEqualToString : @"<null>"]
                || [((NSString *)object)isEqualToString : @"(null)"]
                );
    }
    return NO;
}

@end
