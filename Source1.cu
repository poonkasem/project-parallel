#include<iostream>
#include<stdio.h>
// #include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace std;
using namespace cv;

int main() {
	//std::cout << "test c++" << std::endl;
	Mat input;
	input = cv::imread("input.jpg");
	cv::imwrite("output.jpg",input);
}