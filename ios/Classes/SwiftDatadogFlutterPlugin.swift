import Flutter
import UIKit
import Datadog

public class SwiftDatadogFlutterPlugin: NSObject, FlutterPlugin {
  var logger: Logger?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.greenbits.com/datadog_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftDatadogFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let argsMap = call.arguments as! NSDictionary
    switch call.method {
      case "initWithClientToken":
        Datadog.initialize(
            appContext: .init(),
            configuration: Datadog.Configuration
                .builderUsing(
                    clientToken: argsMap.value(forKey:"clientToken") as! String,
                    environment: argsMap.value(forKey: "environment") as! String
                ).build())
        var builder = Logger.builder
            .set(serviceName: argsMap.value(forKey: "serviceName") as! String)
        if let useEUEndpoints = argsMap.value(forKey: "useEUEndpoints") as? Number {
          if useEUEndpoints == 1 {
            builder = builder.set(endpoint: .eu)
          }
        }
        if let loggerName = argsMap.value(forKey: "loggerName") as? String {
            builder = builder.set(loggerName: loggerName)
        }
        self.logger = builder.build()
        Datadog.verbosityLevel = .debug
        result(true)
      case "addTag":
        logger?.addTag(withKey: argsMap.value(forKey: "key") as! String, value: argsMap.value(forKey: "value") as! String)
        result(true)
      case "removeTag":
        logger?.removeTag(withKey: argsMap.value(forKey: "key") as! String)
        result(true)
      case "addAttribute":
        logger?.addAttribute(forKey: argsMap.value(forKey: "key") as! String, value: argsMap.value(forKey: "value") as! String)
        result(true)
      case "removeAttribute":
        logger?.removeAttribute(forKey: argsMap.value(forKey: "key") as! String)
        result(true)
      case "log":
        let logLevel = argsMap.value(forKey: "level") as! String
        let logMessage = argsMap.value(forKey: "message") as! String
        let attributes = argsMap.value(forKey: "attributes") as? [String : Encodable]
        switch logLevel {
          case "debug":
            logger?.debug(logMessage, attributes: attributes)
          case "info":
            logger?.info(logMessage, attributes: attributes)
          case "notice":
            logger?.notice(logMessage, attributes: attributes)
          case "warn":
            logger?.warn(logMessage, attributes: attributes)
          case "error":
            logger?.error(logMessage, attributes: attributes)
          case "critical":
            logger?.critical(logMessage, attributes: attributes)
          default:
            return result(false);
        }
        result(true);
      default:
        result(FlutterMethodNotImplemented);
    }
  }
}
