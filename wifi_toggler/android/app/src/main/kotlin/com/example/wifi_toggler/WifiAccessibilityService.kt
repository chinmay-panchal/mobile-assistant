package com.example.wifi_toggler

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class WifiAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "WifiAgent"

        private var instance: WifiAccessibilityService? = null

        @Volatile
        private var agentRunning = false

        fun startWifiAgent() {
            val service = instance

            if (service == null) {
                Log.e(TAG, "Accessibility service is NULL")
                return
            }

            agentRunning = true
            service.startAgent()
        }
    }

    private val handler = Handler(Looper.getMainLooper())

    private var checkScheduled = false
    private var settingsOpened = false

    private enum class AgentStep {
        OPEN_SETTINGS,
        FIND_CONNECTIONS,
        FIND_WIFI,
        FIND_WIFI_SWITCH,
        VERIFY
    }

    private var currentStep = AgentStep.OPEN_SETTINGS

    override fun onServiceConnected() {
        super.onServiceConnected()

        instance = this

        Log.d(TAG, "ACCESSIBILITY SERVICE CONNECTED")
    }

    override fun onAccessibilityEvent(
        event: AccessibilityEvent
    ) {
        if (!agentRunning) return

        scheduleCheck(300)
    }

    private fun startAgent() {
        if (!agentRunning) return

        settingsOpened = false
        currentStep = AgentStep.OPEN_SETTINGS

        scheduleCheck(0)
    }

    private fun scheduleCheck(delay: Long) {
        if (!agentRunning || checkScheduled) return

        checkScheduled = true

        handler.postDelayed({
            checkScheduled = false
            inspectScreen()
        }, delay)
    }

    private fun inspectScreen() {

        if (!agentRunning) return

        val root = rootInActiveWindow

        if (root == null) {
            scheduleCheck(500)
            return
        }

        val packageName =
            root.packageName?.toString()

        Log.d(
            TAG,
            "SCREEN package=$packageName step=$currentStep"
        )

        // STEP 1: Open Settings once
        if (currentStep == AgentStep.OPEN_SETTINGS) {

            if (packageName == "com.android.settings") {

                Log.d(TAG, "Settings detected")

                currentStep =
                    AgentStep.FIND_CONNECTIONS

                scheduleCheck(300)
                return
            }

            if (!settingsOpened) {

                settingsOpened = true

                Log.d(
                    TAG,
                    "Opening Android Settings ONCE"
                )

                val intent = Intent(
                    Settings.ACTION_SETTINGS
                )

                intent.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK
                )

                startActivity(intent)

                scheduleCheck(1000)
                return
            }

            scheduleCheck(500)
            return
        }

        // STEP 2: Find Connections
        if (currentStep == AgentStep.FIND_CONNECTIONS) {

            if (packageName != "com.android.settings") {
                scheduleCheck(500)
                return
            }

            val connections =
                findNode(
                    root,
                    listOf(
                        "Connections",
                        "Connection"
                    )
                )

            if (connections != null) {

                Log.d(
                    TAG,
                    "FOUND Connections"
                )

                if (clickNodeOrParent(connections)) {

                    Log.d(
                        TAG,
                        "Connections clicked"
                    )

                    currentStep =
                        AgentStep.FIND_WIFI

                    scheduleCheck(800)
                    return
                }
            }

            Log.d(
                TAG,
                "Connections not found"
            )

            scheduleCheck(500)
            return
        }

        // STEP 3: Find Wi-Fi
        if (currentStep == AgentStep.FIND_WIFI) {

            if (packageName != "com.android.settings") {
                scheduleCheck(500)
                return
            }

            val wifi =
                findNode(
                    root,
                    listOf(
                        "Wi-Fi",
                        "Wifi",
                        "WLAN"
                    )
                )

            if (wifi != null) {

                Log.d(
                    TAG,
                    "FOUND Wi-Fi"
                )

                if (clickNodeOrParent(wifi)) {

                    Log.d(
                        TAG,
                        "Wi-Fi clicked"
                    )

                    currentStep =
                        AgentStep.FIND_WIFI_SWITCH

                    scheduleCheck(800)
                    return
                }
            }

            Log.d(
                TAG,
                "Wi-Fi not found"
            )

            scheduleCheck(500)
            return
        }

        // STEP 4: Find Wi-Fi switch
        if (currentStep == AgentStep.FIND_WIFI_SWITCH) {

            if (packageName != "com.android.settings") {
                scheduleCheck(500)
                return
            }

            val wifiSwitch =
                findWifiSwitch(root)

            if (wifiSwitch != null) {

                val isOn =
                    wifiSwitch.isChecked

                Log.d(
                    TAG,
                    "Wi-Fi switch found. isOn=$isOn"
                )

                if (!isOn) {

                    Log.d(
                        TAG,
                        "Wi-Fi already OFF"
                    )

                    stopAgent()
                    return
                }

                Log.d(
                    TAG,
                    "Clicking Wi-Fi switch"
                )

                val clicked =
                    wifiSwitch.performAction(
                        AccessibilityNodeInfo
                            .ACTION_CLICK
                    )

                Log.d(
                    TAG,
                    "Switch click=$clicked"
                )

                if (clicked) {

                    currentStep =
                        AgentStep.VERIFY

                    scheduleCheck(1000)
                    return
                }
            }

            Log.d(
                TAG,
                "Wi-Fi switch not found"
            )

            scheduleCheck(500)
            return
        }

        // STEP 5: Verify
        if (currentStep == AgentStep.VERIFY) {

            val wifiSwitch =
                findWifiSwitch(root)

            if (wifiSwitch == null) {
                scheduleCheck(500)
                return
            }

            val isOn =
                wifiSwitch.isChecked

            Log.d(
                TAG,
                "VERIFY Wi-Fi isOn=$isOn"
            )

            if (!isOn) {

                Log.d(
                    TAG,
                    "WIFI OFF SUCCESS"
                )

                stopAgent()

            } else {

                scheduleCheck(500)
            }
        }
    }

    private fun findNode(
        node: AccessibilityNodeInfo,
        targets: List<String>
    ): AccessibilityNodeInfo? {

        val text =
            node.text
                ?.toString()
                ?.trim()

        val description =
            node.contentDescription
                ?.toString()
                ?.trim()

        for (target in targets) {

            if (
                text.equals(
                    target,
                    ignoreCase = true
                ) ||
                description.equals(
                    target,
                    ignoreCase = true
                )
            ) {
                return node
            }
        }

        for (i in 0 until node.childCount) {

            val child =
                node.getChild(i)
                    ?: continue

            val result =
                findNode(
                    child,
                    targets
                )

            if (result != null) {
                return result
            }
        }

        return null
    }

    private fun clickNodeOrParent(
        node: AccessibilityNodeInfo
    ): Boolean {

        if (node.isClickable) {

            return node.performAction(
                AccessibilityNodeInfo
                    .ACTION_CLICK
            )
        }

        var parent =
            node.parent

        while (parent != null) {

            if (parent.isClickable) {

                return parent.performAction(
                    AccessibilityNodeInfo
                        .ACTION_CLICK
                )
            }

            parent = parent.parent
        }

        return false
    }

    private fun findWifiSwitch(
        node: AccessibilityNodeInfo
    ): AccessibilityNodeInfo? {

        val className =
            node.className
                ?.toString()
                ?.lowercase()
                ?: ""

        if (
            node.isCheckable &&
            (
                className == "android.widget.switch" ||
                className.contains("switch")
            )
        ) {
            return node
        }

        for (i in 0 until node.childCount) {

            val child =
                node.getChild(i)
                    ?: continue

            val result =
                findWifiSwitch(child)

            if (result != null) {
                return result
            }
        }

        return null
    }

    private fun stopAgent() {

        Log.d(
            TAG,
            "Stopping agent"
        )

        agentRunning = false
        settingsOpened = false
        currentStep = AgentStep.OPEN_SETTINGS
        checkScheduled = false

        handler.removeCallbacksAndMessages(null)
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility interrupted")
    }

    override fun onDestroy() {

        handler.removeCallbacksAndMessages(null)

        instance = null
        agentRunning = false

        super.onDestroy()
    }
}