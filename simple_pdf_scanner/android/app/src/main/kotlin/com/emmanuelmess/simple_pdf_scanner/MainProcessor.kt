package com.emmanuelmess.simple_pdf_scanner

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import java.io.ByteArrayOutputStream
import kotlin.concurrent.thread

object MainProcessor {
    init {
        System.loadLibrary("native-lib")
    }

    fun startProcessing(path: String, callback: (ByteArray) -> Unit) {
        thread {
            val bitmap = BitmapFactory.decodeFile(path, BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
            })

            val imgResult = process(bitmap)

            val matrix = Matrix().apply {
                postRotate(90f)
            }

            val rotated = Bitmap.createBitmap(imgResult, 0, 0, imgResult.width, imgResult.height, matrix, true)

            val byteArrayOutputStream = ByteArrayOutputStream()
            rotated.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()

            callback(byteArray)
        }
    }

    private external fun process(b: Bitmap): Bitmap
}