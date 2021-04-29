package com.greenbits.datadog_flutter

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.util.Log
import com.datadog.android.log.Logger
import com.datadog.android.Datadog
import com.datadog.android.core.configuration.Configuration
import com.datadog.android.core.configuration.Credentials
import com.datadog.android.privacy.TrackingConsent
import com.datadog.android.rum.RumMonitor
import com.datadog.android.rum.GlobalRum
import com.datadog.android.rum.RumActionType
import com.datadog.android.rum.RumErrorSource
import com.datadog.android.Datadog.initialize
import android.content.Context

/** DatadogFlutterPlugin */
public class DatadogFlutterPlugin: FlutterPlugin, MethodCallHandler {
  private var loggers = mutableMapOf<String, Logger>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext()
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.greenbits.com/datadog_flutter")
    channel.setMethodCallHandler(DatadogFlutterPlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic lateinit var context : Context

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      context = registrar.activity().getApplication()
      val channel = MethodChannel(registrar.messenger(), "plugins.greenbits.com/datadog_flutter")
      channel.setMethodCallHandler(DatadogFlutterPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when {
      call.method == "initWithClientToken" -> {
        val rumApplicationId = call.argument<String>("androidRumApplicationId")
        var configBuilder = Configuration.Builder(
          true,
          false,
          rumApplicationId != null,
          rumApplicationId != null
        )
        if (call.argument<Boolean>("useEUEndpoints")!!) {
          configBuilder = configBuilder.useEUEndpoints()
        }
        val config = configBuilder.build()

        val credentials = Credentials(
          call.argument<String>("clientToken")!!,
          call.argument<String>("serviceName")!!,
          call.argument<String>("flavor")!!,
          rumApplicationId,
          call.argument<String>("serviceName")!!
        )
        val consent = TrackingConsent.values()[call.argument<Int>("trackingConsent")!!]
        initialize(context, credentials, config, consent)

        Datadog.setVerbosity(Log.VERBOSE)

        if (rumApplicationId != null) {
          val monitor = RumMonitor.Builder().build()
          GlobalRum.registerIfAbsent(monitor)
        }
      }
      call.method == "createLogger" -> {
        val builder = Logger.Builder()
                .setNetworkInfoEnabled(true)
                .setServiceName(call.argument<String>("serviceName")!!)

        if (call.argument<String>("loggerName") != null) {
          builder.setLoggerName(call.argument<String>("loggerName")!!)
        }
        loggers[call.argument<String>("identifier")!!] = builder.build()
        result.success(true)
      }
      call.method == "loggerAddAttribute" -> {
        getLogger(call)?.addAttribute(call.argument<String>("key")!!, call.argument<String>("value"))
        result.success(true)
      }
      call.method == "loggerAddTag" -> {
        getLogger(call)?.addTag(call.argument<String>("key")!!, call.argument<String>("value")!!)
        result.success(true)
      }
      call.method == "loggerRemoveAttribute" -> {
        getLogger(call)?.removeAttribute(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "loggerRemoveTag" -> {
        getLogger(call)?.removeTagsWithKey(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "rumAddAttribute" -> {
        GlobalRum.addAttribute(call.argument<String>("key")!!, call.argument<String>("value"))
        result.success(true)
      }
      call.method == "rumAddError" -> {
        GlobalRum.get().addErrorWithStacktrace(
          call.argument<String>("message")!!,
          RumErrorSource.SOURCE,
          call.argument<String>("stack")!!,
          emptyMap()
        )
        result.success(true)
      }
      call.method == "rumAddUserAction" -> {
        val type = RumActionType.values()[call.argument<Int>("type")!!]
        GlobalRum.get().addUserAction(
          type,
          call.argument<String>("name")!!,
          call.argument<Map<String, Any?>>("attributes")!!
        )
        result.success(true)
      }
      call.method == "rumRemoveAttribute" -> {
        GlobalRum.removeAttribute(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "rumStartUserAction" -> {
        val type = RumActionType.values()[call.argument<Int>("type")!!]
        GlobalRum.get().startUserAction(
          type,
          call.argument<String>("name")!!,
          call.argument<Map<String, Any?>>("attributes")!!
        )
        result.success(true)
      }
      call.method == "rumStartView" -> {
        GlobalRum.get().startView(
          call.argument<String>("key")!!,
          call.argument<String>("key")!!
        )
        result.success(true)
      }
      call.method == "rumStopUserAction" -> {
        val type = RumActionType.values()[call.argument<Int>("type")!!]
        GlobalRum.get().startUserAction(
          type,
          call.argument<String>("name")!!,
          call.argument<Map<String, Any?>>("attributes")!!
        )
        result.success(true)
      }
      call.method == "rumStopView" -> {
        GlobalRum.get().stopView(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "setUserInfo" -> {
        Datadog.setUserInfo(
          call.argument<String>("id"),
          call.argument<String>("name"),
          call.argument<String>("email"),
          call.argument<Map<String, Any?>>("extraInfo")
        )
        result.success(true)
      }
      call.method == "updateTrackingConsent" -> {
        val consent = TrackingConsent.values()[call.argument<Int>("trackingConsent")!!]
        Datadog.setTrackingConsent(consent)
        result.success(true)
      }
      call.method == "log" -> {
        val logLevel = call.argument<String>("level")!!
        val logMessage = call.argument<String>("message")!!
        val attributes = call.argument<Map<String, Object>>("attributes") ?: HashMap<String, Object>();

        when (logLevel) {
          "debug" -> {
            if (attributes != null) {
              getLogger(call)?.v(logMessage, attributes = attributes)
            } else {
              getLogger(call)?.v(logMessage)
            }
          }
          "info" -> {
            if (attributes != null) {
              getLogger(call)?.d(logMessage, attributes = attributes)
            } else {
              getLogger(call)?.d(logMessage)
            }
          }
          "notice" -> {
            if (attributes != null) {
              getLogger(call)?.i(logMessage, attributes = attributes)
            } else {
              getLogger(call)?.i(logMessage)
            }
          }
          "warn" -> {
            if (attributes != null) {
              getLogger(call)?.w(logMessage, attributes = attributes)
            } else {
              getLogger(call)?.w(logMessage)
            }
          }
          "error" -> {
            if (attributes != null) {
              getLogger(call)?.e(logMessage, attributes = attributes)
            } else {
              getLogger(call)?.e(logMessage)
            }
          }
          "critical" -> {
            if (attributes != null) {
              getLogger(call)?.wtf(logMessage, attributes = attributes)
            } else {
              getLogger(call)?.wtf(logMessage)
            }
          }
          else -> {
            result.error("UNKNOWN", "unknown log level $logLevel specified", null)
          }
        }

        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun getLogger(@NonNull call: MethodCall): Logger? {
    val identifier = call.argument<String>("identifier")

    if (identifier == null) return null

    return loggers[identifier!!]
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
