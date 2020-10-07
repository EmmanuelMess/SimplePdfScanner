package com.emmanuelmess.simple_pdf_scanner.processing

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.Mat
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayOutputStream


object MainProcessor {
    fun startProcessing(path: String): ByteArray {
        OpenCVLoader.initDebug()//TODO use async

        val bitmap = BitmapFactory.decodeFile(path, BitmapFactory.Options().apply {
            inPreferredConfig = Bitmap.Config.ARGB_8888
        })

        val img = Mat()
        Utils.bitmapToMat(bitmap, img)
        
        Imgproc.cvtColor(img, img, Imgproc.COLOR_RGB2BGRA)

        val imgResult: Mat = img.clone()
        Imgproc.Canny(img, imgResult, 80.0, 90.0)
        
        val imgBitmap = Bitmap.createBitmap(imgResult.cols(), imgResult.rows(), Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(imgResult, imgBitmap)

        val byteArrayOutputStream = ByteArrayOutputStream()
        imgBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()

        return byteArray
    }
}