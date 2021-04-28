import Flutter
import UIKit
import Datadog

public class SwiftDatadogFlutterPlugin: NSObject, FlutterPlugin {
  private var loggers: [String: Logger] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.greenbits.com/datadog_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftDatadogFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String : Any?]
    switch call.method {
      case "initWithClientToken":
        let rumApplicationId = args?["iosRumApplicationId"] as? String
        let config = buildConfiguration(
          clientToken: args!["clientToken"] as! String,
          environment: args!["environment"] as! String,
          serviceName: args!["serviceName"] as! String,
          rumApplicationId: rumApplicationId,
          useEUEndpoints: args?["useEUEndpoints"] as? NSNumber == 1
        )

        let trackingConsent = numberToTrackingConsent(args?["trackingConsent"] as? NSNumber)
        Datadog.initialize(
          appContext: .init(),
          trackingConsent: trackingConsent,
          configuration: config.build()
        )

        Datadog.verbosityLevel = .debug

        if rumApplicationId != nil {
          Global.rum = RUMMonitor.initialize()
        }

        result(true)

      case "addAttribute":
        getLogger(args)?.addAttribute(forKey: args!["key"] as! String, value: args!["value"] as! String)
        result(true)

      case "addError":
        Global.rum.addError(
          message: args!["message"] as! String,
          source: .source,
          stack: args?["stack"] as? String
        )
        result(true)

      case "addTag":
        getLogger(args)?.addTag(withKey: args!["key"] as! String, value: args!["value"] as! String)
        result(true)

      case "addUserAction" :
        let type = numberToRumActionType(args?["type"] as? NSNumber)
        if let attributes = args?["attributes"] as? Dictionary<String, Encodable> {
          Global.rum.addUserAction(
            type: type,
            name: args!["name"] as! String,
            attributes: attributes
          )
        } else {
          Global.rum.addUserAction(
            type: type,
            name: args!["name"] as! String
          )
        }
        result(true)

      case "createLogger":
        var builder = Logger.builder
            .set(serviceName: args!["serviceName"] as! String)

        if let loggerName = args?["loggerName"] as? String {
          builder = builder.set(loggerName: loggerName)
        }
        loggers[args!["identifier"] as! String] = builder.build()
        result(true)

      case "removeTag":
        getLogger(args)?.removeTag(withKey: args!["key"] as! String)
        result(true)

      case "removeAttribute":
        getLogger(args)?.removeAttribute(forKey: args!["key"] as! String)
        result(true)

      case "startView":
        Global.rum.startView(key: args!["key"] as! String)
        result(true)

      case "stopView":
        Global.rum.stopView(key: args!["key"] as! String)
        result(true)

      case "updateTrackingConsent":
        let trackingConsent = numberToTrackingConsent(args?["trackingConsent"] as? NSNumber)
        Datadog.set(trackingConsent: trackingConsent)
        result(true)

      case "log":
        let logLevel = args!["level"] as! String
        let logMessage = args!["message"] as! String
        let attributes = args?["attributes"] as? [String : Encodable]
        switch logLevel {
          case "debug":
            getLogger(args)?.debug(logMessage, attributes: attributes)
          case "info":
            getLogger(args)?.info(logMessage, attributes: attributes)
          case "notice":
            getLogger(args)?.notice(logMessage, attributes: attributes)
          case "warn":
            getLogger(args)?.warn(logMessage, attributes: attributes)
          case "error":
            getLogger(args)?.error(logMessage, attributes: attributes)
          case "critical":
            getLogger(args)?.critical(logMessage, attributes: attributes)
          default:
            return result(false);
        }
        result(true);

      default:
        result(FlutterMethodNotImplemented);
    }
  }

  private func buildConfiguration(clientToken: String, environment: String, serviceName: String, rumApplicationId: String?, useEUEndpoints: Bool) -> Datadog.Configuration.Builder {
    var config: Datadog.Configuration.Builder

    if rumApplicationId != nil {
      config = Datadog.Configuration.builderUsing(
        rumApplicationID: rumApplicationId!,
        clientToken: clientToken,
        environment: environment
      )
    } else {
      config = Datadog.Configuration.builderUsing(
        clientToken: clientToken,
        environment: environment
      )
    }

    config = config.set(serviceName: serviceName)
    if useEUEndpoints {
      config = config.set(endpoint: .eu)
    }

    return config
  }

  private func getLogger(_ args: [String : Any?]?) -> Logger? {
    guard let identifier = args?["identifier"] as? String else {
      return nil
    }
    return loggers[identifier]
  }

  private func numberToRumActionType(_ index: NSNumber?) -> RUMUserActionType {
    if index == 0 {
      return RUMUserActionType.tap
    } else if index == 1 {
      return RUMUserActionType.scroll
    } else if index == 2 {
      return RUMUserActionType.swipe
    }

    return RUMUserActionType.custom
  }

  private func numberToTrackingConsent(_ index: NSNumber?) -> TrackingConsent {
    if index == 0 {
      return TrackingConsent.granted
    } else if index == 1 {
      return TrackingConsent.notGranted
    }

    return TrackingConsent.pending
  }
}
