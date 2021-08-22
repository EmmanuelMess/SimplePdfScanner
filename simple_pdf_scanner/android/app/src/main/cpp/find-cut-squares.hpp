#ifndef TEST2_FIND_CUT_SQUARES_HPP
#define TEST2_FIND_CUT_SQUARES_HPP

#include <opencv2/core/mat.hpp>
#include <vector>

using namespace cv;

bool findCut(Mat & image);

void getCorners(Mat & image, std::vector<Point2f> & corners);

#endif //TEST2_FIND_CUT_SQUARES_HPP
