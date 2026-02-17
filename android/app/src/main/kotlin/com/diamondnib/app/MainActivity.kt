package com.diamondnib.app

import android.content.Intent
import android.content.Context;
import android.os.Bundle
import android.util.Log
import com.ryanheise.audioservice.AudioServicePlugin;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.diamondnib.app/deeplink"
    private var initialLink: String? = null
    private var methodChannel: MethodChannel? = null

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d("MainActivity", "configureFlutterEngine called")
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    Log.d("MainActivity", "getInitialLink called, returning: $initialLink")
                    result.success(initialLink)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Handle initial intent
        handleIntent(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate called")
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("MainActivity", "onNewIntent called")
        setIntent(intent)
        handleIntent(intent)
        
        // Send to Flutter if engine is ready
        val linkString = intent.data?.toString()
        if (linkString != null) {
            methodChannel?.invokeMethod("onDeepLink", linkString)
        }
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) {
            Log.d("MainActivity", "handleIntent: intent is null")
            return
        }
        
        val action = intent.action
        val data = intent.data
        
        Log.d("MainActivity", "handleIntent - action: $action, data: $data")
        
        if (Intent.ACTION_VIEW == action && data != null) {
            initialLink = data.toString()
            Log.d("MainActivity", "Deep link stored: $initialLink")
        }
    }
}