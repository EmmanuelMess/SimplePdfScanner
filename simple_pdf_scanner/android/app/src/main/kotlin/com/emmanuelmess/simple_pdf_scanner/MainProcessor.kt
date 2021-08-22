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

            if(imgResult == null) {
                val byteArrayOutputStream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
                val byteArray = byteArrayOutputStream.toByteArray()
                callback(byteArray)
                return@thread
            }
            
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

    private external fun process(b: Bitmap): Bitmap?

    fun startGetCorners(path: String, callback: (IntArray) -> Unit) {
        thread {
            val bitmap = BitmapFactory.decodeFile(path, BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
            })

            val corners = IntArray(4*2);
            getCorners(bitmap, corners)

            //swap coordinates to rotate 90 degrees
            for (i in 0 until 4) {
                val temp = corners[i*2]
                corners[i*2] = corners[i*2+1]
                corners[i*2+1] = temp
            }

            callback(corners)
        }
    }

    private external fun getCorners(b: Bitmap, a: IntArray)
}