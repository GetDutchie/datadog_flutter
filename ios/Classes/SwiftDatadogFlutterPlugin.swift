import Flutter
import UIKit
import Datadog
import Foundation
import AnyCodable
import DatadogCrashReporting

public class SwiftDatadogFlutterPlugin: NSObject, FlutterPlugin {
  private var loggers: [String: Logger] = [:]
  private var traces: [String: OTSpan] = [:]

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

      case "loggerLog":
        let logLevel = args!["level"] as! String
        let logMessage = args!["message"] as! String
        let attributes = encodeAttributes(args?["attributes"] as? String)

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

      case "loggerAddAttribute":
        getLogger(args)?.addAttribute(
          forKey: args!["key"] as! String,
          value: args!["value"] as! String
        )
        result(true)

      case "loggerAddTag":
        getLogger(args)?.addTag(
          withKey: args!["key"] as! String,
          value: args!["value"] as! String
        )
        result(true)

      case "loggerCreateLogger":
        var builder = Logger.builder

        if let loggerName = args?["loggerName"] as? String {
          builder = builder.set(loggerName: loggerName)
        }
        loggers[args!["identifier"] as! String] = builder.build()
        result(true)

      case "loggerRemoveAttribute":
        getLogger(args)?.removeAttribute(forKey: args!["key"] as! String)
        result(true)

      case "loggerRemoveTag":
        getLogger(args)?.removeTag(withKey: args!["key"] as! String)
        result(true)

      case "resourceStartLoading":
        guard let key = args?["key"] as? String,
              let method = args?["method"] as? String,
              let url = args?["url"] as? String,
              let rumMethod = RUMMethod.init(rawValue: method) else {
          return result(false)
        }

        let attributes = args?["attributes"] as? String
        if attributes?.isEmpty ?? true {
          Global.rum.startResourceLoading(resourceKey: key, httpMethod: rumMethod, urlString: url)
        } else {
          Global.rum.startResourceLoading(
            resourceKey: key,
            httpMethod: rumMethod,
            urlString: url,
            attributes: encodeAttributes(attributes!)!
          )
        }
        result(true)

      case "resourceStopLoading":
        guard let key = args?["key"] as? String else {
          return result(false)
        }

        let attributes = args?["attributes"] as? String
        if let errorMessage = args?["errorMessage"] as? String {
          if attributes?.isEmpty ?? true {
            Global.rum.stopResourceLoadingWithError(
              resourceKey: key,
              errorMessage: errorMessage
            )
          } else {
            Global.rum.stopResourceLoadingWithError(
              resourceKey: key,
              errorMessage: errorMessage,
              attributes: encodeAttributes(attributes!)!
            )
          }
        } else {
          if let kind = args?["kind"] as? String,
             let resourceType = RUMResourceType.init(rawValue: kind) {
            if attributes?.isEmpty ?? true {
              Global.rum.stopResourceLoading(
                resourceKey: key,
                statusCode: args?["statusCode"] as? Int,
                kind: resourceType
              )
            } else {
              Global.rum.stopResourceLoading(
                resourceKey: key,
                statusCode: args?["statusCode"] as? Int,
                kind: resourceType,
                attributes: encodeAttributes(attributes!)!
              )
            }
          }
        }
        result(true)

      case "rumAddAttribute":
        Global.rum.addAttribute(
          forKey: args!["key"] as! String,
          value: args!["value"] as! String
        )
        result(true)

      case "rumAddError":
        Global.rum.addError(
          message: args!["message"] as! String,
          source: .source,
          stack: args?["stack"] as? String
        )
        result(true)

      case "rumAddTiming":
        Global.rum.addTiming(name: args!["name"] as! String)
        result(true)

      case "rumAddUserAction" :
        let type = numberToRumActionType(args?["type"] as? NSNumber)
        let attributes = encodeAttributes(args?["attributes"] as? String)
        if attributes?.isEmpty ?? true {
          Global.rum.addUserAction(
            type: type,
            name: args!["name"] as! String
          )
        } else {
          Global.rum.addUserAction(
            type: type,
            name: args!["name"] as! String,
            attributes: attributes!
          )
        }
        result(true)

      case "rumRemoveAttribute":
        Global.rum.removeAttribute(forKey: args!["key"] as! String)
        result(true)

      case "rumStartUserAction":
        let type = numberToRumActionType(args?["type"] as? NSNumber)
        let attributes = encodeAttributes(args?["attributes"] as? String)
        if attributes?.isEmpty ?? true {
          Global.rum.startUserAction(
            type: type,
            name: args!["name"] as! String
          )
        } else {
          Global.rum.startUserAction(
            type: type,
            name: args!["name"] as! String,
            attributes: attributes!
          )
        }
        result(true)

      case "rumStartView":
        Global.rum.startView(key: args!["key"] as! String)
        result(true)

      case "rumStopUserAction":
        let type = numberToRumActionType(args?["type"] as? NSNumber)
        let attributes = encodeAttributes(args?["attributes"] as? String)
        if attributes?.isEmpty ?? true {
          Global.rum.stopUserAction(
            type: type,
            name: args!["name"] as? String
          )
        } else {
          Global.rum.stopUserAction(
            type: type,
            name: args!["name"] as? String,
            attributes: attributes!
          )
        }
        result(true)

      case "rumStopView":
        Global.rum.stopView(key: args!["key"] as! String)
        result(true)

      case "setUserInfo":
        let extraInfo = encodeAttributes(args?["extraInfo"] as? String)
        Datadog.setUserInfo(
          id: args?["id"] as? String,
          name: args?["name"] as? String,
          email: args?["email"] as? String,
          extraInfo: extraInfo ?? [AttributeKey : AttributeValue]()
        )
        result(true)

      case "tracingCreateHeadersForRequest":
        guard let tracer = Global.sharedTracer as? Tracer else {
          return result([String : String]())
        }
        let writer = HTTPHeadersWriter()
        let span = tracer.startSpan(operationName: args!["resourceName"] as! String)
        if let method = args?["method"] as? String {
          span.setTag(key: "http.method", value: method)
        }
        if let url = args?["url"] as? String {
          span.setTag(key: "http.url", value: url)
        }
        tracer.inject(spanContext: span.context, writer: writer)
        let headers = writer.tracePropagationHTTPHeaders
        traces[headers["x-datadog-parent-id"]!] = span
        result(writer.tracePropagationHTTPHeaders)

      case "tracingFinishSpan":
        let spanId = args!["spanId"] as! String
        let span = traces[spanId]
        if let statusCode = args?["statusCode"] as? NSNumber {
          span?.setTag(key: "http.status_code", value: statusCode.intValue)
        }
        span?.finish()
        traces.removeValue(forKey: spanId)
        result(true)

      case "tracingInitialize":
        Global.sharedTracer = Tracer.initialize(
          configuration: Tracer.Configuration(
            sendNetworkInfo: true
          )
        )
        result(true)

      case "updateTrackingConsent":
        let trackingConsent = numberToTrackingConsent(args?["trackingConsent"] as? NSNumber)
        Datadog.set(trackingConsent: trackingConsent)
        result(true)

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
      ).enableCrashReporting(using: DDCrashReportingPlugin())
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

  private func encodeAttributes(_ json: String?) -> [AttributeKey : AttributeValue]? {
    guard let strongJson = json else {
      return nil
    }

    let decoder = JSONDecoder()
    return try! decoder.decode([String: AnyCodable].self, from: strongJson.data(using: .utf8)!) as [AttributeKey : AttributeValue]
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
