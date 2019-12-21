#include<iostream>
#include<stdio.h>
#include<string.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace std;
using namespace cv;

int main() {

	int i,j,k;

	cv::Mat input;
	input = cv::imread("input.jpg", IMREAD_COLOR);

	unsigned char *temp = (unsigned char*)(input.data);
	int rows = input.rows , cols = input.cols;
	int process[rows][cols];
	int swap[rows][cols];
	
	k=0;
	for(i=0;i<rows;i++){
		for(j=0;j<cols;j++){
			process[i][j] = temp[k];
			k++;
		}
	}

	int size_input = sizeof(char) * 3 * img_pic.rows * img_pic.cols;
	unsigned char *dev_input;
	cudaMalloc( (void**)&dev_input, size_input);
	cudaMemcpy( dev_input, temp, size_input, cudaMemcpyHostToDevice);

	/*int colsTemp;
	for(i=0;i<rows;i++){
		k=0;
		colsTemp = cols-1;
		for(j=0;j<cols;j++){
			swap[i][k] = process[i][colsTemp];
			colsTemp--;
			k++;
		}
	}*/

	k=0;
	for(i=0;i<rows;i++){
		for(j=0;j<cols;j++){
			temp[k] = swap[i][j];
			k++;
		}
	}
	
	Mat output =  Mat(rows, cols, CV_8UC3 , temp);
	cv::imwrite("output.jpg",output);
}