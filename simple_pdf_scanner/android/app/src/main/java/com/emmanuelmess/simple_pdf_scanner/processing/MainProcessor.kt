package com.emmanuelmess.simple_pdf_scanner.processing

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import org.opencv.imgproc.Imgproc.*
import java.io.ByteArrayOutputStream


object MainProcessor {
    fun startProcessing(path: String): ByteArray {
        OpenCVLoader.initDebug()//TODO use async

        val bitmap = BitmapFactory.decodeFile(path, BitmapFactory.Options().apply {
            inPreferredConfig = Bitmap.Config.ARGB_8888
        })

        val img = Mat()
        Utils.bitmapToMat(bitmap, img)
        
        val imgResult = work(img)
        
        val imgBitmap = Bitmap.createBitmap(imgResult.cols(), imgResult.rows(), Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(imgResult, imgBitmap)

        val rotated = Bitmap.createBitmap(
                imgBitmap, 0, 0, imgBitmap.width, imgBitmap.height,
                Matrix().apply { postRotate(90f) }, true)

        val byteArrayOutputStream = ByteArrayOutputStream()
        rotated.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()

        return byteArray
    }

    private fun work(input: Mat): Mat {
        val resizedInput = Mat()

        val r = 500.0 / input.height()
        val width = (input.width() * r).toInt()
        resize(input, resizedInput, Size(width.toDouble(), 500.0))

        val grey = Mat()
        cvtColor(resizedInput, grey, COLOR_RGB2GRAY)
        GaussianBlur(grey, grey, Size(5.0, 5.0), 0.0)
        
        val edged = Mat()
        Canny(grey, edged, 75.0, 200.0)

        return edged
    }
}