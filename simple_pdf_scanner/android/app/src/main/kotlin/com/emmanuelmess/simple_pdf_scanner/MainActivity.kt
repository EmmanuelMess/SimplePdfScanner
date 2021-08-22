package com.emmanuelmess.simple_pdf_scanner

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.emmanuelmess.simple_pdf_scanner/MAIN"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when(call.method) {
                        "process" -> {
                            MainProcessor.startProcessing(call.arguments as String) { image ->
                                runOnUiThread {
                                    result.success(image)
                                }
                            }
                        }
                        "getCorners" -> {
                            MainProcessor.startGetCorners(call.arguments as String) { corners ->
                                runOnUiThread {
                                    result.success(corners)
                                }
                            }
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                }
    }
}
