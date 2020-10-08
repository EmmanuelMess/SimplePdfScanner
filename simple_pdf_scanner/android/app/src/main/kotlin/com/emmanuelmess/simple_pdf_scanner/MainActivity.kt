package com.emmanuelmess.simple_pdf_scanner

import androidx.annotation.NonNull
import com.emmanuelmess.simple_pdf_scanner.processing.MainProcessor
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
                    if (call.method == "process") {
                        MainProcessor.startProcessing(this, call.arguments as String) { image ->
                            runOnUiThread {
                                result.success(image)
                            }
                        }
                    } else {
                        result.notImplemented()
                    }
                }
    }
}
