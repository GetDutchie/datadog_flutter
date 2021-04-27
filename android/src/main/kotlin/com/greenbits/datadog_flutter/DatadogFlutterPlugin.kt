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
import com.datadog.android.Datadog.initialize
import android.content.Context

/** DatadogFlutterPlugin */
public class DatadogFlutterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var logger: Logger

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
        var configBuilder = Configuration.Builder(
          call.argument<Boolean>("logsEnabled")!!,
          false,
          call.argument<Boolean>("crashReportsEnabled")!!,
          call.argument<Boolean>("rumEnabled")!!
        )
        if (call.argument<Boolean>("useEUEndpoints")!!) {
          configBuilder = configBuilder.useEUEndpoints()
        }
        val config = configBuilder.build()

        val credentials = Credentials(
          call.argument<String>("clientToken")!!,
          call.argument<String>("serviceName")!!,
          call.argument<String>("flavor")!!,
          context.packageName
        )
        val consent = TrackingConsent.values()[call.argument<Int>("trackingConsent")!!]
        initialize(context, credentials, config, consent)
        val builder = Logger.Builder()
          .setNetworkInfoEnabled(true)
          .setServiceName(call.argument<String>("serviceName")!!)

        if (call.argument<String>("loggerName") != null) {
          builder.setLoggerName(call.argument<String>("loggerName")!!)
        }
        logger = builder.build()
        Datadog.setVerbosity(Log.VERBOSE)

        if (call.argument<Boolean>("rumEnabled")!!) {
          val monitor = RumMonitor.Builder().build()
          GlobalRum.registerIfAbsent(monitor)
        }
      }
      call.method == "addTag" -> {
        logger.addTag(call.argument<String>("key")!!, call.argument<String>("value")!!)
        result.success(true)
      }
      call.method == "removeTag" -> {
        logger.removeTagsWithKey(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "addAttribute" -> {
        logger.addAttribute(call.argument<String>("key")!!, call.argument<String>("value"))
        result.success(true)
      }
      call.method == "removeAttribute" -> {
        logger.removeAttribute(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "updateTrackingConsent" -> {
        val consent = TrackingConsent.values()[call.argument<Int>("trackingConsent")!!]
        Datadog.setTrackingConsent(consent)
        result.success(true)
      }
      call.method == "startView" -> {
        GlobalRum.get().startView(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "stopView" -> {
        GlobalRum.get().stopView(call.argument<String>("key")!!)
        result.success(true)
      }
      call.method == "addUserAction" -> {
        val type = RumActionType.values()[call.argument<Int>("type")!!]
        GlobalRum.get().addUserAction(type, call.argument<String>("name")!!, call.argument<Map<String, Any?>>("attributes")!!)
        result.success(true)
      }
      call.method == "log" -> {
        val logLevel = call.argument<String>("level")!!
        val logMessage = call.argument<String>("message")!!
        val attributes = call.argument<Map<String, Object>>("attributes") ?: HashMap<String, Object>();

        when (logLevel) {
          "debug" -> {
            if (attributes != null) {
              logger.v(logMessage, attributes = attributes)
            } else {
              logger.v(logMessage)
            }
          }
          "info" -> {
            if (attributes != null) {
              logger.d(logMessage, attributes = attributes)
            } else {
              logger.d(logMessage)
            }
          }
          "notice" -> {
            if (attributes != null) {
              logger.i(logMessage, attributes = attributes)
            } else {
              logger.i(logMessage)
            }
          }
          "warn" -> {
            if (attributes != null) {
              logger.w(logMessage, attributes = attributes)
            } else {
              logger.w(logMessage)
            }
          }
          "error" -> {
            if (attributes != null) {
              logger.e(logMessage, attributes = attributes)
            } else {
              logger.e(logMessage)
            }
          }
          "critical" -> {
            if (attributes != null) {
              logger.wtf(logMessage, attributes = attributes)
            } else {
              logger.wtf(logMessage)
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

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
