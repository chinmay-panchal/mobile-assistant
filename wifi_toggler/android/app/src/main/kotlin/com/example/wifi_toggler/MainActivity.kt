package com.example.wifi_toggler

import android.content.Intent
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityManager
import android.accessibilityservice.AccessibilityServiceInfo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL =
        "com.yourapp/wifi_toggle"

    private val TAG =
        "WifiToggler"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {

        super.configureFlutterEngine(
            flutterEngine
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "checkAccessibility" -> {

                    result.success(
                        isAccessibilityServiceEnabled()
                    )
                }

                "openAccessibilitySettings" -> {

                    try {

                        startActivity(
                            Intent(
                                Settings.ACTION_ACCESSIBILITY_SETTINGS
                            )
                        )

                        result.success(null)

                    } catch (e: Exception) {

                        result.error(
                            "ACCESSIBILITY_SETTINGS",
                            e.message,
                            null
                        )
                    }
                }

                /*
                 * Start our generic WiFi agent.
                 */
                "startWifiAgent" -> {

                    Log.d(
                        TAG,
                        "Starting WiFi agent"
                    )

                    WifiAccessibilityService
                        .startWifiAgent()

                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isAccessibilityServiceEnabled():
        Boolean {

        val manager =
            getSystemService(
                ACCESSIBILITY_SERVICE
            ) as AccessibilityManager

        val services =
            manager.getEnabledAccessibilityServiceList(
                AccessibilityServiceInfo
                    .FEEDBACK_ALL_MASK
            )

return services.any { serviceInfo ->

    serviceInfo.resolveInfo.serviceInfo.packageName == packageName &&
    serviceInfo.resolveInfo.serviceInfo.name ==
        "com.example.wifi_toggler.WifiAccessibilityService"
}
    }
}