#include "find-cut-squares.hpp"
#include "opencv2/core.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"
#include <iostream>

using namespace cv;
using namespace std;

int thresh = 20, N = 11;
const char* wndname = "Square Detection Demo";
// helper function:
// finds a cosine of angle between vectors
// from pt0->pt1 and from pt0->pt2
inline double angle( const Point& pt1, const Point& pt2, const Point& pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1 * dx2 + dy1 * dy2) / sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

static vector<Point2f> orderPoints(const vector<Point2f>& points) {
    vector<Point2f> orderedPoints(4);
    auto sumPoint = [](const Point& pointA, const Point& pointB) {
        return (pointA.x + pointA.y) <= (pointB.x + pointB.y);
    };

    const auto [minSum, maxSum] = minmax_element(points.begin(), points.end(), sumPoint);

    orderedPoints[0] = *minSum;
    orderedPoints[2] = *maxSum;

    auto diffPoint = [](const Point& pointA, const Point& pointB) {
        return (pointA.x - pointA.y) <= (pointB.x - pointB.y);
    };

    const auto [minDiff, maxDiff] = minmax_element(points.begin(), points.end(), diffPoint);

    orderedPoints[3] = *minDiff;
    orderedPoints[1] = *maxDiff;

    return orderedPoints;
}

static void fourPointTransform(Mat& image, const vector<Point2f>& points) {
    auto orderedPoints = orderPoints(points);

    auto widthA = norm(orderedPoints[2] - orderedPoints[3]);
    auto widthB = norm(orderedPoints[1] - orderedPoints[0]);
    auto maxWidth = max(int(widthA), int(widthB));

    auto heightA = norm(orderedPoints[1] - orderedPoints[2]);
    auto heightB = norm(orderedPoints[0] - orderedPoints[3]);
    auto maxHeight = max(int(heightA), int(heightB));

    vector<Point2f> newPositions({
                                         Point2f(0, 0),
                                         Point2f(maxWidth - 1, 0),
                                         Point2f(maxWidth - 1, maxHeight - 1),
                                         Point2f(0, maxHeight - 1)
                                 });

    auto M = getPerspectiveTransform(orderedPoints, newPositions);
    warpPerspective(image, image, M, Size(maxWidth, maxHeight));
}

// returns sequence of squares detected on the image.
static void findSquares( const Mat& image, vector<vector<Point> >& squares ) {
    squares.clear();
    Mat blurred(image);
    medianBlur(image, blurred, 9);

    Mat gray0(blurred.size(), CV_8U), gray;

    vector<vector<Point> > contours;
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++) {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);

        while(squares.empty() && N < 100) {
            // try several threshold levels
            for (int l = 0; l < N; l++) {
                // hack: use Canny instead of zero threshold level.
                // Canny helps to catch squares with gradient shading
                if (l == 0) {
                    // apply Canny. Take the upper threshold from slider
                    // and set the lower to 0 (which forces edges merging)
                    Canny(gray0, gray, 10, thresh, 3);
                    // dilate canny output to remove potential
                    // holes between edge segments
                    dilate(gray, gray, Mat(), Point(-1, -1));
                } else {
                    // apply threshold if l!=0:
                    //     tgray(x,y) = gray(x,y) < (l+1)*255/N ? 255 : 0
                    gray = gray0 >= (l + 1) * 255 / N;
                }

                // find contours and store them all as a list
                findContours(gray, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);

                vector<Point> approx;
                // test each contour
                for (auto &contour : contours) {
                    // approximate contour with accuracy proportional
                    // to the contour perimeter
                    approxPolyDP(contour, approx, arcLength(contour, true) * 0.02, true);
                    // square contours should have 4 vertices after approximation
                    // relatively large area (to filter out noisy contours)
                    // and be convex.
                    // Note: absolute value of an area is used because
                    // area may be positive or negative - in accordance with the
                    // contour orientation
                    if (approx.size() == 4 &&
                        fabs(contourArea(approx)) > 1000 &&
                        isContourConvex(approx)) {
                        double maxCosine = 0;
                        for (int j = 2; j < 5; j++) {
                            // find the maximum cosine of the angle between joint edges
                            double cosine = fabs(angle(approx[j % 4], approx[j - 2], approx[j - 1]));
                            maxCosine = MAX(maxCosine, cosine);
                        }
                        // if cosines of all angles are small
                        // (all angles are ~90 degree) then write quandrange
                        // vertices to resultant sequence
                        if (maxCosine < 0.2)
                            squares.push_back(approx);
                    }
                }
            }

            N += 10;
        }
    }
}

static void removeShadows(const Mat& image, Mat &result) {
    Mat rgb_planes[3];
    split(image, rgb_planes);
    Mat dilatation;
    Mat blurred;
    Mat difference;
    Mat rgb_result[3];

    for(int i = 0; i < 3; i++) {
        Mat dilationKernel = getStructuringElement( MORPH_RECT, Size(9, 9));

        dilate(rgb_planes[i], dilatation, dilationKernel);

        medianBlur(dilatation, blurred, 21);

        absdiff(rgb_planes[i], blurred, difference);
        subtract(Scalar(255), difference, difference);

        normalize(difference, rgb_result[i], 0, 255, NORM_MINMAX, CV_8UC1);
    }

    merge(rgb_result, 3, result);
}

const float PROCESS_WIDTH = 512;
const float PROCESS_HEIGHT = 910;

static void intelliResize(const Mat& image, Mat &result, float& ratioWidth, float& ratioHeight) {
    Size newSize;

    if(image.size().width < PROCESS_WIDTH || image.size().height < PROCESS_HEIGHT) {
        newSize = image.size();
    } else if(image.size().height < image.size().width) {
        newSize = Size(PROCESS_HEIGHT, PROCESS_WIDTH);
    } else {
        newSize = Size(PROCESS_WIDTH, PROCESS_HEIGHT);
    }

    ratioWidth = image.size().width / newSize.width;
    ratioHeight = image.size().height / newSize.height;
    resize(image, result, newSize, 0, 0, INTER_AREA);
}

void getCorners(Mat& image, std::vector<Point2f> & points) {
    Mat resizedImage;
    float ratioWidth;
    float ratioHeight;
    intelliResize(image.clone(), resizedImage, ratioWidth, ratioHeight);

    vector<vector<Point> > squares;
    findSquares(resizedImage.clone(), squares);

    if(squares.empty()) {
         return;
    }

    sort(squares.begin(), squares.end(), [](const vector<Point>& a, const vector<Point>& b){
        return contourArea(a) > contourArea(b);
    });

    vector<Point>& chosenSquare = squares[0];

    points.reserve(chosenSquare.size());
    for (auto &i : chosenSquare) {
        points.emplace_back(i.x * ratioWidth, i.y * ratioHeight);
    }
}

bool findCut(Mat& image) {
    vector<Point2f> unresizedSquare;

    getCorners(image, unresizedSquare);

    if(unresizedSquare.empty()) {
        return false;
    }

    fourPointTransform(image, unresizedSquare);
    //removeShadows(copy, image);

    return true;
}