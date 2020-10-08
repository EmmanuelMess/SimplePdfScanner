package com.emmanuelmess.simple_pdf_scanner.processing

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.core.Core.mixChannels
import org.opencv.core.CvType.CV_8U
import org.opencv.imgproc.Imgproc.*
import java.io.ByteArrayOutputStream
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.sqrt


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
        
        val squares = mutableListOf<MatOfPoint2f>()

        val pyr = Mat()
        val timg = Mat()
        val gray0 = Mat(resizedInput.size(), CV_8U)
        val gray = Mat()

        pyrDown(resizedInput, pyr, Size((resizedInput.cols() / 2).toDouble(), (resizedInput.rows() / 2).toDouble()));
        pyrUp(pyr, timg, resizedInput.size());

        val contours = ArrayList<MatOfPoint>()
        val approx = MatOfPoint2f()

        // find squares in every color plane of the image
        for(c in 0 until 3) {
            mixChannels(listOf(timg), listOf(gray0), MatOfInt(c, 0))

            val N = 3
            val thresh = 0
            for(l in 0 until N) {
                // hack: use Canny instead of zero threshold level.
                // Canny helps to catch squares with gradient shading
                if( l == 0 ) {
                    // apply Canny. Take the upper threshold from slider
                    // and set the lower to 0 (which forces edges merging)
                    Canny(gray0, gray, 0.0, thresh.toDouble(), 5);
                    // dilate canny output to remove potential
                    // holes between edge segments
                    dilate(gray, gray, Mat());
                } else {
                    // apply threshold if l!=0:
                    //     tgray(x,y) = gray(x,y) < (l+1)*255/N ? 255 : 0
                    // gray = gray0 >= (l+1)*255/N;
                    threshold(gray0, gray, ((l + 1) * 255 / N).toDouble(), 255.0, 0)
                }

                // find contours and store them all as a list
                findContours(gray, contours, Mat(), RETR_LIST, CHAIN_APPROX_SIMPLE)

                for(contour in contours) {
                    val cont = MatOfPoint2f(*contour.toArray())
                    approxPolyDP(cont, approx, arcLength(cont, true) * 0.02, true)

                    val app = approx.toArray()

                    if(approx.total() == 4L && abs(contourArea(approx)) > 1000 && isContourConvex(MatOfPoint(*approx.toArray()))) {
                        var maxCosine = 0.0
                        for (j in 2..4) {
                            // find the maximum cosine of the angle between joint edges
                            val cosine: Double = abs(angle(app[j % 4], app[j - 2], app[j - 1]))
                            maxCosine = max(maxCosine, cosine)
                        }
                        // if cosines of all angles are small
                        // (all angles are ~90 degree) then write quandrange
                        // vertices to resultant sequence
                        // if cosines of all angles are small
                        // (all angles are ~90 degree) then write quandrange
                        // vertices to resultant sequence
                        if (maxCosine < 0.3) squares.add(approx)
                    }
                }
            }
        }

        for(square in squares) {
            val sq = MatOfPoint(*square.toArray())
            polylines(resizedInput, listOf(sq),true, Scalar(0.0,255.0,0.0), 3, LINE_AA)
        }
        
        return resizedInput
    }

    private fun angle(pt1: Point, pt2: Point, pt0: Point): Double {
        val dx1 = pt1.x - pt0.x
        val dy1 = pt1.y - pt0.y
        val dx2 = pt2.x - pt0.x
        val dy2 = pt2.y - pt0.y
        return (dx1 * dx2 + dy1 * dy2) / sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10)
    }
}