#include<iostream>
#include<stdio.h>
#include<string.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/mat.hpp>

using namespace std;
using namespace cv;

int main() {

	int i,j;

	cv::Mat input;
	input = cv::imread("input.jpg", IMREAD_COLOR);

    int rows = input.rows, cols = input.cols;
    
    cv::Mat output;

    output = input;

    unsigned char *in = (unsigned char*)(input.data);
    unsigned char *out = (unsigned char*)(output.data);

    int sizeUnsignedChar = sizeof(char)*3*rows*cols;

    unsigned char *devInput, *devOutput;

    cudaMalloc((void**)&devInput, sizeUnsignedChar);
    cudaMalloc((void**)&devOutput, sizeUnsignedChar);

    cudaMemcpy( devInput, in, sizeUnsignedChar, cudaMemcpyHostToDevice);
    cudaMemcpy( devOutput, out, sizeUnsignedChar, cudaMemcpyHostToDevice);

    /*for (i=0;i<rows;i++) {
        for (j=0;j<cols;j++) {
            // output(i,j) = input(i,cols-1-j);
            out[]
        }
    }

	cv::imwrite("output.jpg",output);*//

}