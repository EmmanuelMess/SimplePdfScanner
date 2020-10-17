#include <jni.h>
#include <string>
#include <opencv2/core.hpp>
#include "find-cut-squares.hpp"
#include <android/bitmap.h>

using namespace cv;

/*
 * Class:     org_opencv_android_Utils
 * Method:    void nBitmapToMat2(Bitmap b, long m_addr, boolean unPremultiplyAlpha)
 */

extern "C" JNIEXPORT void JNICALL Java_org_opencv_android_Utils_nBitmapToMat2
        (JNIEnv * env, jclass, jobject bitmap, jlong m_addr, jboolean needUnPremultiplyAlpha);

Mat convertToMat(JNIEnv * env, jobject bitmap) {
    Mat mat;
    Java_org_opencv_android_Utils_nBitmapToMat2(env, nullptr, bitmap, (jlong) (&mat), false);
    return mat;
}

/*
 * Class:     org_opencv_android_Utils
 * Method:    void nMatToBitmap2(long m_addr, Bitmap b, boolean premultiplyAlpha)
 */

extern "C" JNIEXPORT void JNICALL Java_org_opencv_android_Utils_nMatToBitmap2
        (JNIEnv * env, jclass, jlong m_addr, jobject bitmap, jboolean needPremultiplyAlpha);

void convertToBitmap(JNIEnv * env, jobject bitmap, Mat mat) {
    Java_org_opencv_android_Utils_nMatToBitmap2(env, nullptr, (jlong) (&mat), bitmap, false);
}

jobject createBitmap(JNIEnv* env, jint width, jint height) {
    // setup bitmap class
    auto bitmap_class = (jclass) env->FindClass ("android/graphics/Bitmap");
    // setup create method
    jmethodID bitmap_create_method = env->GetStaticMethodID (
            bitmap_class,
            "createBitmap",
            "(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;"
            );
    // get_enum_value return jobject corresponding in our case to Bitmap.Config.ARGB_8888. (the implentation is irrelevant here)
    jclass clSTATUS    = env->FindClass("android/graphics/Bitmap$Config");
    jfieldID fidONE    = env->GetStaticFieldID(clSTATUS , "ARGB_8888", "Landroid/graphics/Bitmap$Config;");
    jobject bitmap_config_ARGB = env->GetStaticObjectField(clSTATUS, fidONE);
    // Do not forget to call DeleteLocalRef where appropriate

    // create the bitmap by calling the CreateBitmap method
    // Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    jobject bitmap =  env->CallStaticObjectMethod (
            bitmap_class,
            bitmap_create_method,
            width, height,
            bitmap_config_ARGB
            );

    return bitmap;
}

extern "C" JNIEXPORT jobject JNICALL
Java_com_emmanuelmess_simple_1pdf_1scanner_processing_MainProcessor_process(
        JNIEnv* env,
        jobject /* this */,
        jobject bitmap
) {
    Mat mat = convertToMat(env, bitmap);
    findCut(mat);
    jobject newBitmap = createBitmap(env, mat.cols, mat.rows);
    //FIXME AndroidBitmap_unlockPixels(env, bitmap);
    convertToBitmap(env, newBitmap, mat);
    return newBitmap;
}

