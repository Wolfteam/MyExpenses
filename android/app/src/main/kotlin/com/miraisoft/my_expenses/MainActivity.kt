package com.miraisoft.my_expenses

import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

//You need a FlutterFragmentActivity to use the local_auth plugin
class MainActivity : FlutterFragmentActivity() {
    companion object {
        const val methodChannelName = "com.github.wolfteam.my_expenses"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName).setMethodCallHandler(::onMethodCall)
    }

    private fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        Log.d("onMethodCall", "[${methodChannelName}] ${call.method}")
        try {
            result.success(null)
        } catch (error: Exception) {
            Log.e("onMethodCall", methodChannelName, error)
            throw error
        }
    }
}